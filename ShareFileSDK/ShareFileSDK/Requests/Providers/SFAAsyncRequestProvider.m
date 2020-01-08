#import "SFAAsyncRequestProviderProtected.h"
#import "SFABaseRequestProviderProtected.h"
#import "SFAUtils.h"
#import "SFAJSONToODataMapper.h"
#import "NSHTTPURLResponse+sfapi.h"
#import "NSURL+sfapi.h"
#import "SFAWebAuthenticationError.h"
#import "SFAOAuthError.h"
#import "SFAAsyncOperationScheduledError.h"
#import "SFAODataRequestError.h"
#import "SFAHttpResponseActionAsyncCallback.h"
#import "NSDictionary+sfapi.h"
#import "SFAModelClassMapper.h"
#import "NSString+sfapi.h"

@interface SFAAsyncRequestProvider ()

@end

@implementation SFAAsyncRequestProvider

- (instancetype)initWithSFAClient:(SFAClient *)client {
    self = [super initWithSFAClient:client];
    return self;
}

- (id <SFATransferTask> )taskWithQuery:(id <SFAQuery> )query callbackQueue:(NSOperationQueue *)queue completionCallback:(SFATaskCompletionCallback)ccb cancelCallback:(SFATaskCancelCallback)canCb {
    SFAHttpTask *task = [[SFAHttpTask alloc] initWithQuery:query delegate:self contextObject:nil callbackQueue:queue client:self.sfaClient];
    task.completionCallback = ccb;
    task.cancelCallback = canCb;
    return task;
}

#pragma mark - HttpTaskDelegate

- (NSURLRequest *)task:(SFAHttpTask *)task needsRequestForQuery:(id <SFAQuery> )query usingContextObject:(NSMutableDictionary **)contextObject {
    return [self _task:task needsRequestForQuery:query usingContextObject:contextObject];
}

- (NSURLRequest *)task:(SFAHttpTask *)task willRedirectToRequest:(NSURLRequest *)request httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject {
    NSMutableDictionary *dict = *contextObject;
    NSMutableURLRequest *redirectRequest = [request mutableCopy];
    SFAuthenticationContext *authContext = [SFAUtils nilForNSNull:dict[SFAAuthContextKey]];
    
    // Allow auth manager to save credentials/mark credentials as valid, if we get here
    [self.sfaClient.authHandler finishRequest:httpRequestResponseDataContainer authContext:authContext];
    // Prepare the new request
    [self.sfaClient.authHandler prepareRequest:redirectRequest authContext:authContext interactiveHandler:task.interactiveHandler];
    
    return redirectRequest;
}

- (void)task:(SFAHttpTask *)task receivedAuthChallenge:(NSURLAuthenticationChallenge *)challenge httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject completionHandler:(void (^)(SFIURLAuthChallengeDisposition, NSURLCredential *))completionHandler {
    [self _task:task receivedAuthChallenge:challenge httpRequestResponseDataContainer:httpRequestResponseDataContainer usingContextObject:contextObject completionHandler:completionHandler];
}

- (SFAHttpHandleResponseReturnData *)task:(SFAHttpTask *)task needsResponseHandlingForQuery:(id <SFAQuery> )query httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject;
{
    return [self _task:task needsResponseHandlingForQuery:query httpRequestResponseDataContainer:httpRequestResponseDataContainer usingContextObject:contextObject];
}

#pragma mark - End Of Section

- (SFAHttpHandleResponseReturnData *)task:(SFAHttpTask *)task authHandlingForQuery:(id <SFAQuery> )query httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextDictionary:(NSMutableDictionary *)contextObject {
    // Fetch data from context
    NSMutableDictionary *dict = contextObject;
    
    SFAuthenticationContext *authContext = [SFAUtils nilForNSNull:dict[SFAAuthContextKey]];
    [dict setObject:[SFAUtils nullForNil:nil] forKey:SFAAction];
    
    __weak id <SFAAuthHandling> weakAuth = self.sfaClient.authHandler;
    __weak SFAAsyncRequestProvider *weakSelf = self;
    
    SFAHttpResponseActionAsyncCallback *callback = [[SFAHttpResponseActionAsyncCallback alloc] initWithAsyncBlock: ^(SFAHttpResponseAsyncCallbackBlock callbackBlock) {
                                                        [weakAuth handleUnauthorizedResponse:httpRequestResponseDataContainer
                                                                                 authContext:authContext
                                                                           completionHandler: ^(SFAAuthHandling_ResponseResult result) {
                                                             SFAHttpHandleResponseReturnData *returnData = nil;
                                                             
                                                             if (result == SFAAuthHandling_Retry) {
                                                                 returnData = [weakSelf retryActionUsingContextDictionary:dict];
                                                             }
                                                             else {
                                                                 returnData = [weakSelf task:task standardResponseHandlingForQuery:query httpRequestResponseDataContainer:httpRequestResponseDataContainer usingContextDictionary:dict];
                                                             }
                                                             
                                                             if (callbackBlock) {
                                                                 callbackBlock(returnData);
                                                             }
                                                         }];
                                                    }];
                                                    
    return [[SFAHttpHandleResponseReturnData alloc] initWithReturnValue:callback andHttpHandleResponseAction:SFAHttpHandleResponseActionAsyncCallback];
}

- (SFAHttpHandleResponseReturnData *)retryActionUsingContextDictionary:(NSMutableDictionary *)dict {
    SFAEventHandlerResponse *action = [SFAEventHandlerResponse eventHandlerResponseWithAction:SFAEventHandlerResponseActionRetry];
    
    [dict setObject:[SFAUtils nullForNil:action] forKey:SFAAction];
    
    return [[SFAHttpHandleResponseReturnData alloc] initWithReturnValue:nil andHttpHandleResponseAction:SFAHttpHandleResponseActionReExecute];
}

- (SFAHttpHandleResponseReturnData *)task:(SFAHttpTask *)task standardResponseHandlingForQuery:(id <SFAQuery> )query httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextDictionary:(NSMutableDictionary *)contextObject;
{
    // Fetch data from context
    NSMutableDictionary *dict = contextObject;
    SFAEventHandlerResponse *action = nil;
    int retryCount = ((NSNumber *)dict[SFARetryCount]).intValue;
    SFAApiRequest *apiRequest = [SFAUtils nilForNSNull:dict[SFAApiRequestString]];
    
    SFAResponse *resp = [self handleResponseForQuery:query apiRequest:apiRequest httpRequestResponseDataContainer:httpRequestResponseDataContainer retryCount:retryCount++];
    // Can return resp with action or value(could be ODataObject subclass,
    // SFIError...etc)
    if (resp.value != nil) {
        if ([resp.value isKindOfClass:[SFIODataObject class]]) {
            if ([resp.value isKindOfClass:[SFIRedirection class]] && ![query.responseClass isSubclassOfClass:[SFIRedirection class]]) {
                SFIRedirection *redirection = (SFIRedirection *)resp.value;
                if (![[httpRequestResponseDataContainer.request.URL getAuthority] isEqualToString:[redirection.Uri getAuthority]]) {
                    action = [self.sfaClient onChangeDomainWithRequest:httpRequestResponseDataContainer.request redirection:redirection];
                }
                else {
                    action = [SFAEventHandlerResponse eventHandlerResponseWithRedirection:redirection];
                }
            }
            else {
                return [[SFAHttpHandleResponseReturnData alloc] initWithReturnValue:resp.value andHttpHandleResponseAction:SFAHttpHandleResponseActionComplete];
            }
        }
        else { // if anything else including SFIError
            return [[SFAHttpHandleResponseReturnData alloc] initWithReturnValue:resp.value andHttpHandleResponseAction:SFAHttpHandleResponseActionComplete];
        }
    }
    else {
        action = resp.action;
    }
    
    if (action != nil && (action.action == SFAEventHandlerResponseActionRetry || action.action == SFAEventHandlerResponseActionRedirect)) {
        // need to loop back
        [dict setObject:[SFAUtils nullForNil:action] forKey:SFAAction];
        [dict setObject:[NSNumber numberWithInt:retryCount] forKey:SFARetryCount];
        
        return [[SFAHttpHandleResponseReturnData alloc] initWithReturnValue:nil andHttpHandleResponseAction:SFAHttpHandleResponseActionReExecute];
    }
    else {
        // Default
        return [[SFAHttpHandleResponseReturnData alloc] initWithReturnValue:nil andHttpHandleResponseAction:SFAHttpHandleResponseActionComplete];
    }
}

#pragma mark - Protected Functions

- (SFAResponse *)handleResponseForQuery:(id <SFAQuery> )query apiRequest:(SFAApiRequest *)apiRequest httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)container retryCount:(int)retryCount {
    SFAError *error;
    id obj = nil;
    error = [self checkAsyncOperationScheduledWith:container];
    if (!error) {
        if ([container.response isSuccessCode] && !container.error) {
            obj = [self handleSuccessResponseForQuery:query apiRequest:apiRequest httpRequestResponseDataContainer:container error:&error];
        }
        else {
            SFAEventHandlerResponse *act = [self handleNonSuccessResponseForQuery:query apiRequest:apiRequest httpRequestResponseDataContainer:container retryCount:retryCount error:&error];
            if (!error) {
                return [SFAResponse createAction:act];
            }
        }
    }
    if (error) {
        return [SFAResponse createSuccess:error];
    }
    else {
        return [SFAResponse createSuccess:obj];
    }
}

- (id)handleSuccessResponseForQuery:(id <SFAQuery> )query apiRequest:(SFAApiRequest *)apiRequest httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)container error:(SFAError **)error {
    [self logResponseWithHttpRequestResponseContainer:container responseObj:[[NSString alloc] initWithData:container.data encoding:NSUTF8StringEncoding]];
    if (container.data.length <= 0) { // we have nothing to return.
        return nil;
    }
    
    if ([container.response.allHeaderFields[SFAContentType] hasPrefix:SFAApplicationJson]) {
        NSError *jsonError;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:container.data options:kNilOptions error:&jsonError];
        id obj = nil;
        if (jsonError) {
            *error = [SFAError errorWithMessage:[NSString stringWithFormat:@"%@:%@", SFAErrorParsingResponse, jsonError] type:SFAErrorTypeInvalidResponseError domain:SFADomainInvalidResponseError code:container.error.code userInfo:container.error.userInfo];
            return nil;
        }
        
        // check for redirection... should we also check for async response??
        // also, is odata.type the only thing we need to check? Do we need to check odata.metadata as well
        NSString *parsedModelName = [(NSString *)[jsonDictionary objectForKey:SFAODataTypeKey andClass:[NSString class]] stringByReplacingOccurrencesOfString:kSFOdataModelPrefix withString:@""];
        
        if ([parsedModelName isEqualToString:@"Redirection"]) {
            // caller should know how to handle redirection, even if it expected some other object type
            SFIRedirection *redirection = [[SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFIRedirection class]] new];
            [redirection setPropertiesWithJSONDictionary:jsonDictionary];
            obj = redirection;
        }
        else if (query.isODataFeed) {
            obj = [[SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFIODataFeed class]] new];
            [obj setPropertiesWithJSONDictionary:jsonDictionary];
        }
        else {
            // Try to make object from meta data
            obj = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:jsonDictionary];
            // if object was not created try responseClass.
            if (!obj && query.responseClass) {
                obj = [query.responseClass new];
                if ([obj conformsToProtocol:@protocol(SFAOAuthResponse)]) {
                    [((id < SFAOAuthResponse >)obj)fillWithDictionary:jsonDictionary];
                }
                else if ([obj isKindOfClass:[NSObject class]]) {
                    [obj setPropertiesWithJSONDictionary:jsonDictionary];
                }
                else {
                    *error = [SFAError errorWithMessage:SFAInvalidClassFormat type:SFAErrorTypeInvalidResponseError domain:SFAInvalidClass code:0 userInfo:nil];
                    return nil;
                }
            }
        }
        
        return obj;
    }
    else {
        return container.data;
    }
}

- (SFAEventHandlerResponse *)handleNonSuccessResponseForQuery:(id <SFAQuery> )query apiRequest:(SFAApiRequest *)apiRequest httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)container retryCount:(int)retryCount error:(SFAError **)error {
    [self logResponseWithHttpRequestResponseContainer:container responseObj:nil];
    SFAEventHandlerResponse *action = [self.sfaClient onErrorWithDataContainer:container retryCount:retryCount];
    
    if (action != nil && action.action == SFAEventHandlerResponseActionFailWithError) {
        if ([container.response isTimeout] || [container.response isGatewayTimeout]) {
            *error = [SFAError errorWithMessage:[NSString stringWithFormat:@"%@\r\n%ld: %@", container.request.URL.absoluteString, (long)container.response.statusCode, SFARequestTimeout] type:SFAErrorTypeHttpRequestError domain:SFADomainHttpReqError code:container.response.statusCode underlyingError:container.error userInfo:nil];
            
            [self.sfaClient.loggingProvider errorWithError:*error format:@""];
            return nil;
        }
        
        // Placing this above auth failed for request,
        // as it's a more specific auth failure case.
        if ([container.response isProxyAuthenticationRequiredCode]) {
            *error = [SFAError errorWithMessage:[NSString stringWithFormat:@"%@: %ld", SFAErrorProxyAuthFailed, (long)container.response.statusCode] type:SFAErrorTypeProxyAuthenticationError domain:SFADomainProxyAuthFailed code:container.response.statusCode underlyingError:container.error userInfo:nil];
            [self.sfaClient.loggingProvider errorWithError:*error format:@""];
            return nil;
        }
        
        if ([SFAUtils didAuthFailForRequest:container]) {
            BOOL authCanceled = [SFAUtils wasAuthCanceledForRequest:container];
            
            NSString *message = authCanceled ? SFAErrorAuthChallengeCanceled :
                                [NSString stringWithFormat:@"%@  %@: %ld", SFAErrorAuthenticationFailed, SFACode, (long)container.response.statusCode];
                                
            NSString *wwAuthString = container.response.allHeaderFields[SFAWWWAuthenticate];
            NSURL *reqURL = container.request.URL;
            NSError *underlyingError = container.error;
            
            if (authCanceled) {
                *error = [SFAWebAuthenticationError challengeCanceledWithMessage:message
                                                   wwwAuthenticationHeaderString:wwAuthString
                                                                      requestURL:reqURL
                                                                 underlyingError:underlyingError];
            }
            else {
                *error = [SFAWebAuthenticationError errorWithMessage:message
                                       wwwAuthenticationHeaderString:wwAuthString
                                                          requestURL:reqURL
                                                     underlyingError:underlyingError];
            }
            
            [self.sfaClient.loggingProvider errorWithError:*error format:@""];
            return nil;
        }
        
        if (container.response.allHeaderFields[SFAContentLength] != nil && ((NSString *)container.response.allHeaderFields[SFAContentLength]).intValue == 0) {
            *error = [SFAError errorWithMessage:SFAErrorResponseContent type:SFAErrorTypeUnableToRetrieveHttpContentError domain:SFAContentLengthError code:0 underlyingError:container.error userInfo:nil];
            
            [self.sfaClient.loggingProvider errorWithError:*error format:@""];
            return nil;
        }
        
        SFAError *errorToReturn = nil;
        NSError *jsonError;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:container.data options:kNilOptions error:&jsonError];
        //
        NSString *rawString = [[NSString alloc] initWithData:container.data encoding:NSUTF8StringEncoding];
        if (!jsonError && (query.responseClass == nil || [query.responseClass isSubclassOfClass:[SFIODataObject class]])) {
            errorToReturn = [SFAODataRequestError errorWithDictionary:jsonDictionary response:container.response];
        }
        //
        else if (!jsonError && query.responseClass == [SFAOAuthToken class]) {
            SFAOAuthError *oauthError = [SFAOAuthError errorWithDictionary:jsonDictionary];
            errorToReturn = oauthError;
        }
        else {
            errorToReturn = [SFAError errorWithMessage:rawString
                                                  type:SFAErrorTypeInvalidResponseError
                                                domain:SFAErrorInvalidResponse
                                                  code:container.response.statusCode
                                       underlyingError:container.error userInfo:nil];
        }
        if (errorToReturn) {
            *error = errorToReturn;
            return nil;
        }
    }
    return action;
}

- (SFAError *)checkAsyncOperationScheduledWith:(SFAHttpRequestResponseDataContainer *)container {
    if (container.response.statusCode == 202) {
        if ([[container.response.allHeaderFields[SFAContentType] lowercaseString] rangeOfString:SFAApplicationJson].location != NSNotFound) {
            NSError *jsonError;
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:container.data options:kNilOptions error:&jsonError];
            if (!jsonError) {
                SFIAsyncOperation *operation = [SFIAsyncOperation new];
                [operation setPropertiesWithJSONDictionary:jsonDictionary];
                return [SFAAsyncOperationScheduledError errorWithScheduleAsyncOperation:operation];
            }
        }
    }
    return nil;
}

// For Both URL Session Task and HTTP Task
- (NSURLRequest *)_task:(id)task needsRequestForQuery:(id <SFAQuery> )query usingContextObject:(NSMutableDictionary **)contextObject {
    // Fetch data from context
    NSMutableDictionary *dict = (*contextObject) ? :[NSMutableDictionary dictionary];
    SFAEventHandlerResponse *action = [SFAUtils nilForNSNull:dict[SFAAction]];
    int retryCount = ((NSNumber *)[SFAUtils nilForNSNull:dict[SFARetryCount]]).intValue;
    SFAuthenticationContext *authContext = [SFAUtils nilForNSNull:dict[SFAAuthContextKey]];
    // Make ApiRequest
    
    SFAApiRequest *apiRequest = [SFAApiRequest apiRequestFromQuery:(SFAQueryBase *)query];
    if (action.redirection.Uri) {
        apiRequest.composed = YES;
        
        if (action.redirection.Root.length > 0) {
            //If the redirection.Root is not empty AND the redirection.Uri does not have a root, append the root.
            NSURLComponents *comps = [NSURLComponents componentsWithURL:action.redirection.Uri resolvingAgainstBaseURL:NO];
            
            NSString *percentEncodedRoot = [NSString stringWithFormat:@"root=%@", [action.redirection.Root escapeString]];
            NSString *percentEncodedQuery = comps.percentEncodedQuery;
            
            if (percentEncodedQuery == nil) {
                comps.percentEncodedQuery = percentEncodedRoot;
            }
            else if ([percentEncodedQuery rangeOfString:@"root=" options:NSCaseInsensitiveSearch].length == 0) {
                comps.percentEncodedQuery = [percentEncodedQuery stringByAppendingFormat:@"&%@", percentEncodedRoot];
            }
            
            action.redirection.Uri = comps.URL;
        }
        
        apiRequest.url = action.redirection.Uri;
        
        apiRequest.httpMethod = action.redirection.Method ? action.redirection.Method : SFAGet;
        //Redirection object may return GET as a method and a non-nil Body, we do a sanity check here so SDK does not run into problems later.
        apiRequest.body = [apiRequest.httpMethod caseInsensitiveCompare:SFAGet] == NSOrderedSame ? nil : action.redirection.Body;
    }
    // Make Url Request
    NSMutableURLRequest *httpRequestMessage = [[self buildRequest:apiRequest] mutableCopy];
    NSObject <SFAInteractiveAuthHandling> *interactiveHandler = nil;
    if ([task isKindOfClass:[SFAHttpTask class]]) {
        interactiveHandler = ((SFAHttpTask *)task).interactiveHandler;
    }
    authContext = [self.sfaClient.authHandler prepareRequest:httpRequestMessage authContext:authContext interactiveHandler:interactiveHandler];
    
    [httpRequestMessage setValue:self.sfaClient.configuration.toolName forHTTPHeaderField:SFAXSFApiTool];
    [httpRequestMessage setValue:self.sfaClient.configuration.toolVersion forHTTPHeaderField:SFAXSFAPIToolVersion];
    
    // Put data back in context
    [dict setObject:@(retryCount) forKey:SFARetryCount];
    [dict setObject:[SFAUtils nullForNil:action] forKey:SFAAction];
    [dict setObject:[SFAUtils nullForNil:apiRequest] forKey:SFAApiRequestString];
    [dict setObject:[SFAUtils nullForNil:authContext] forKey:SFAAuthContextKey];
    
    *contextObject = dict;
    return [httpRequestMessage copy];
}

- (void)_task:(id)task receivedAuthChallenge:(NSURLAuthenticationChallenge *)challenge httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject completionHandler:(void (^)(SFIURLAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSMutableDictionary *dict = *contextObject;
    
    [self.sfaClient.authHandler handleAuthChallenge:challenge httpContainer:httpRequestResponseDataContainer authContext:[SFAUtils nilForNSNull:dict[SFAAuthContextKey]] completionHandler:completionHandler];
}

- (SFAHttpHandleResponseReturnData *)_task:(id)task needsResponseHandlingForQuery:(id <SFAQuery> )query httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject;
{
    // Fetch data from context
    NSMutableDictionary *dict = *contextObject;
    
    // Post request handling code.
    // Pass the completed response through the auth handler to save cookies, mark credentials as good, etc
    SFAAuthHandling_ResponseResult authResponse = [self.sfaClient.authHandler finishRequest:httpRequestResponseDataContainer authContext:[SFAUtils nilForNSNull:dict[SFAAuthContextKey]]];
    
    if (authResponse == SFAAuthHandling_Continue || authResponse == SFAAuthHandling_Cancel) {
        return [self task:task standardResponseHandlingForQuery:query httpRequestResponseDataContainer:httpRequestResponseDataContainer usingContextDictionary:dict];
    }
    else if (authResponse == SFAAuthHandling_Retry) {
        // Instant replay, apply those creds
        return [self retryActionUsingContextDictionary:dict];
    }
    else {
        return [self task:task authHandlingForQuery:query httpRequestResponseDataContainer:httpRequestResponseDataContainer usingContextDictionary:dict];
    }
}

@end
