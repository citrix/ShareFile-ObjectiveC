#import "SFAAsyncUploaderBaseProtected.h"
#import "SFAUploaderBaseProtected.h"
#import "SFAUtils.h"
#import "SFACryptoUtils.h"
#import "SFAFilePart.h"
#import "SFAApiResponse.h"

@interface SFAAsyncUploaderBase ()

@end

@implementation SFAAsyncUploaderBase

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)fileUpConfig andExpirationDays:(int)expirationDays {
    self = [super initWithSFAClient:client uploadSpecificationRequest:uploadSpecificationRequest filePath:filePath andExpirationDays:expirationDays];
    if (self) {
        self.config = fileUpConfig ? fileUpConfig :[SFAFileUploaderConfig new];
    }
    return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#if TARGET_OS_IPHONE
- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset fileUploaderConfig:(SFAFileUploaderConfig *)fileUpConfig andExpirationDays:(int)expirationDays {
    self = [super initWithSFAClient:client uploadSpecificationRequest:uploadSpecificationRequest asset:asset andExpirationDays:expirationDays];
    if (self) {
        self.config = fileUpConfig ? fileUpConfig :[SFAFileUploaderConfig new];
    }
    return self;
}

#endif

- (SFApiQuery *)createUpload:(SFAUploadSpecificationRequest *)uploadSpecificationRequest {
    SFApiQuery *query = [self uploadSpecificationQuery];
    return query;
}

#pragma Protected

- (void)checkResumeAsync {
    if ([self.uploadSpecification.IsResume intValue] == 1) {
        if (![self.uploadSpecification.ResumeFileHash isEqualToString:[self calculateHashOfNextNBytes:self.uploadSpecification.ResumeOffset]]) {
            self.uploadSpecification.ResumeIndex = @0;
            self.uploadSpecification.ResumeOffset = @0;
        }
        else {
            unsigned long long number = [self.uploadSpecification.ResumeIndex unsignedLongLongValue] + 1;
            self.uploadSpecification.ResumeIndex = [NSNumber numberWithUnsignedLongLong:number];
        }
    }
}

- (NSString *)calculateHashOfNextNBytes:(NSNumber *)count {
    NSMutableString *hashVal = [NSMutableString new];
    NSInputStream *inputStream = nil;
#if TARGET_OS_IPHONE
    if (!self.asset) {
#endif
    inputStream = [self.fileHandler streamForRead];
    [inputStream open];
#if TARGET_OS_IPHONE
}

long long assetBytesOffset = 0;
#endif
    NSUInteger countVal = [count unsignedIntegerValue];
    uint8_t *buffer = malloc(SFAMaxBufferLength);
    while (countVal > 0) {
        NSUInteger bytesToRead = countVal < SFAMaxBufferLength ? countVal : SFAMaxBufferLength;
        NSInteger readStatus = 0;
        NSUInteger bytesRead = 0;
        NSError *error = nil;
#if TARGET_OS_IPHONE
        ALAssetRepresentation *rep = self.asset.defaultRepresentation;
        if (self.asset) {
            bytesRead = [rep getBytes:buffer fromOffset:assetBytesOffset length:bytesToRead error:&error];
        }
        else {
#endif
        readStatus = [inputStream read:buffer maxLength:bytesToRead];
        bytesRead = readStatus >= 0 ? (NSUInteger)readStatus : 0;
#if TARGET_OS_IPHONE
    }
#endif
        if (readStatus < 0 || bytesRead <= 0 || error) {
            // incase some error occured or full file is read.
            break;
        }
        else if (bytesRead > 0) {
            NSData *dataToEncode = [NSData dataWithBytes:(const void *)buffer length:bytesRead];
            [hashVal appendString:[SFACryptoUtils md5StringWithData:dataToEncode]];
        }
#if TARGET_OS_IPHONE
        assetBytesOffset += bytesRead;
#endif
        countVal -= bytesRead;
    }
    free(buffer);
    return [hashVal copy];
}

#pragma clang diagnostic pop

- (id <SFATransferTask> )uploadAsyncWithTransferData:(NSDictionary *)transferMetadata callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback progressCallback:(SFATransferTaskProgressCallback)progressCallback {
    NSAssert(NO, @"uploadAsyncWithTransferData Implementation Not Found");
    return nil;
}

- (id <SFATransferTask> )uploadAsyncWithCallbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback progressCallback:(SFATransferTaskProgressCallback)progressCallback {
    return [self uploadAsyncWithTransferData:nil callbackQueue:callbackQueue completionCallback:completionCallback cancelCallback:cancelCallback progressCallback:progressCallback];
}

- (id <SFATransferTask> )uploadBackgroundAsyncWithTaskDelegate:(id <SFAURLSessionTaskDelegate> )delegate callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback;
{
    NSAssert(NO, @"uploadBackgroundAsyncWitURLSessionTaskDelegate not supported for this uploader.");
    return nil;
}

- (id)uploadResponseAsync:(SFAHttpRequestResponseDataContainer *)dataContainer {
    NSAssert(NO, @"uploadResponseAsync Implementation Not Found");
    return nil;
}

- (id <SFAQuery> )queryForURLSession:(NSURLSession *)session task:(NSURLSessionTask *)task {
    NSAssert(NO, @"queryForURLSession Implementation Not Found");
    return nil;
}

#pragma mark - SFAURLSessionTaskHttpDelegate

- (NSURLSessionTask *)URLSession:(NSURLSessionTask *)session taskNeedsNewTask:(NSURLSessionTask *)task {
    NSAssert(NO, @"taskNeedsNewTask Implementation Not Found");
    return nil;
}

- (SFAHttpHandleResponseReturnData *)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needsResponseHandlingForHttpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject {
    // We handle using SFAHttpTaskDelegate methods where only type is treates as id.
    id <SFAQuery> query = [self queryForURLSession:session task:task];
    return [self _task:task needsResponseHandlingForQuery:query httpRequestResponseDataContainer:httpRequestResponseDataContainer usingContextObject:contextObject];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task receivedAuthChallenge:(NSURLAuthenticationChallenge *)challenge httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary *__autoreleasing *)contextObject completionHandler:(void (^)(SFURLAuthChallengeDisposition, NSURLCredential *))completionHandler {
    [self _task:task receivedAuthChallenge:challenge httpRequestResponseDataContainer:httpRequestResponseDataContainer usingContextObject:contextObject completionHandler:completionHandler];
}

#pragma mark - HttpTaskDelegate

- (NSURLRequest *)task:(SFAHttpTask *)task needsRequestForQuery:(id <SFAQuery> )query usingContextObject:(NSMutableDictionary **)contextObject {
    NSAssert(NO, @"NeedsRequestForQuery Implementation Not Found.");
    return nil;
}

- (void)task:(SFAHttpTask *)task receivedAuthChallenge:(NSURLAuthenticationChallenge *)challenge httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject completionHandler:(void (^)(SFURLAuthChallengeDisposition, NSURLCredential *))completionHandler {
    [self _task:task receivedAuthChallenge:challenge httpRequestResponseDataContainer:httpRequestResponseDataContainer usingContextObject:contextObject completionHandler:completionHandler];
}

- (SFAHttpHandleResponseReturnData *)task:(SFAHttpTask *)task needsResponseHandlingForQuery:(id <SFAQuery> )query httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject {
    return [self _task:task needsResponseHandlingForQuery:query httpRequestResponseDataContainer:httpRequestResponseDataContainer usingContextObject:contextObject];
}

- (NSURLRequest *)task:(SFAHttpTask *)task willRedirectToRequest:(NSURLRequest *)request httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject {
    NSMutableDictionary *dict = *contextObject;
    NSMutableURLRequest *redirectRequest = [request mutableCopy];
    SFAuthenticationContext *authContext = [SFAUtils nilForNSNull:dict[SFAAuthContextKey]];
    
    // Allow auth manager to save credentials/mark credentials as valid, if we get here
    [self.client.authHandler finishRequest:httpRequestResponseDataContainer authContext:authContext];
    // Prepare the new request
    [self.client.authHandler prepareRequest:redirectRequest authContext:authContext interactiveHandler:task.interactiveHandler];
    
    return redirectRequest;
}

#pragma mark - Generic Handling For SFAHttpTaskDelegate and SFAURLSessionTaskDelegate

- (SFAHttpHandleResponseReturnData *)_task:(id)task needsResponseHandlingForQuery:(id <SFAQuery> )query httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject {
    // Fetch data from context
    NSMutableDictionary *dict = *contextObject;
    
    // Post request handling code.
    // Pass the completed response through the auth handler to save cookies, mark credentials as good, etc
    SFAAuthHandling_ResponseResult authResponse = [self.client.authHandler finishRequest:httpRequestResponseDataContainer authContext:[SFAUtils nilForNSNull:dict[SFAAuthContextKey]]];
    
    int retryCount = ((NSNumber *)dict[SFARetryCount]).intValue;
    SFAFilePart *part = dict[SFAFilePartString];
    
    id uploadResponse = [self uploadResponseAsync:httpRequestResponseDataContainer];
    if ([uploadResponse isKindOfClass:[SFAApiResponse class]]) {
        SFAApiResponse *resp = uploadResponse;
        resp.value = [NSNumber numberWithUnsignedLong:[part.data length]];
    }
    SFAHttpHandleResponseAction responseAction = uploadResponse && authResponse != SFAAuthHandling_Retry ? SFAHttpHandleResponseActionComplete : SFAHttpHandleResponseActionReExecute;
    if (retryCount >= 4) {
        responseAction = SFAHttpHandleResponseActionComplete;
        uploadResponse = [SFAError errorWithMessage:SFAUploadError type:SFAErrorTypeUploadError];
    }
    else if (!uploadResponse) {
        retryCount++;
    }
    
    [dict setObject:[NSNumber numberWithInt:retryCount] forKey:SFARetryCount];
    
    return [[SFAHttpHandleResponseReturnData alloc] initWithReturnValue:uploadResponse andHttpHandleResponseAction:responseAction];
}

- (void)_task:(id)task receivedAuthChallenge:(NSURLAuthenticationChallenge *)challenge httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject completionHandler:(void (^)(SFURLAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSMutableDictionary *dict = *contextObject;
    
    [self.client.authHandler handleAuthChallenge:challenge httpContainer:httpRequestResponseDataContainer authContext:[SFAUtils nilForNSNull:dict[SFAAuthContextKey]] completionHandler:completionHandler];
}

@end
