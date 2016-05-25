#import "SFABaseRequestProviderProtected.h"
#import "SFAApiRequest.h"
#import "NSDictionary+sfapi.h"
#import "SFAJSONToODataMapper.h"

@interface SFABaseRequestProvider ()

@end

@implementation SFABaseRequestProvider

- (instancetype)init
{
    return [self initWithSFAClient:nil]; // initWithShare...will throw.
}

#pragma mark - Protected Method

- (instancetype)initWithSFAClient:(SFAClient *)client
{
    self = [super init];
    if (self)
    {
        [self setSfaClient:client]; // need error handling.
    }
    return self;
}

- (NSURLRequest *)buildRequest:(SFAApiRequest *)apiRequest
{
    NSURL *uri = [apiRequest composedUrl];
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:uri cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:self.sfaClient.configuration.httpTimeout];
#if ShareFile
    if (self.sfaClient.zoneAuthentication != nil)
    {
        uri = [self.sfaClient.zoneAuthentication signUrl:uri];
        mutableRequest.URL = uri;
    }
#endif
    if (self.sfaClient.configuration.useHttpMethodOverride)
    {
        mutableRequest.HTTPMethod = SFAPost;
        [mutableRequest setValue:apiRequest.httpMethod forHTTPHeaderField:SFAXHttpMethodOverride];
    }
    else
    {
        if (apiRequest.httpMethod && apiRequest.httpMethod.length > 0 && [apiRequest.httpMethod isEqualToString:SFAGet] && apiRequest.body)
        {
            [apiRequest setHttpMethod:SFAPost];
        }
        mutableRequest.HTTPMethod = apiRequest.httpMethod;
    }
    if (self.sfaClient.configuration.acceptLanguageHeader != nil)
    {
        [mutableRequest setValue:[self.sfaClient.configuration.acceptLanguageHeader copy] forHTTPHeaderField:SFAAcceptLanguage];
    }
    
    if(self.sfaClient.configuration.clientCapabilities) {
        NSMutableDictionary *metadataDictionary = [SFAJSONToODataMapper metadataDictionaryWithURI:uri];
        NSString *providerId = [metadataDictionary objectForKey:kSFOdataMetadataKey_Provider];
        NSArray *providerClientCapabilities = [self.sfaClient.configuration.clientCapabilities objectForKey:providerId];
        
        // If we have client capabilities registered for this provider type, add them to the client capabilities header
        if(providerClientCapabilities) {
            for(NSString *clientCapability in providerClientCapabilities) {
                [mutableRequest addValue:clientCapability forHTTPHeaderField:SFAXClientCapabilities];
            }
        }
    }
    
    [self logApiRequestURL:apiRequest];
    
    for (NSString *headerKey in apiRequest.headerCollection)
    {
        NSString *headerVal = [apiRequest.headerCollection objectForKey:headerKey];
        [mutableRequest addValue:headerVal forHTTPHeaderField:headerKey];
    }
    
    if (apiRequest.body)
    {
        [mutableRequest setValue:SFAApplicationJson forHTTPHeaderField:SFAccept];
        [self dataWithObject:apiRequest.body forRequest:mutableRequest];
    }
    else if ([apiRequest.httpMethod isEqualToString:SFAPost])
    {
        mutableRequest.HTTPBody = [NSData new];
    }
    
    return [mutableRequest copy];
}

- (void)setSfaClient:(SFAClient *)client
{
    NSAssert(client != nil, @"Passed parameter client can not be nil.");
    _sfaClient = client;
}

- (void)dataWithObject:(id<SFAHttpBodyDataProvider>)body forRequest:(NSMutableURLRequest *)request
{
    [body addHttpBodyDataForMutableRequest:request];
}

- (void)logApiRequest:(SFAApiRequest *)apiRequest headers:(NSString *)headers
{
    [self logApiRequestURL:apiRequest];
    if(self.sfaClient.loggingProvider.isDebugEnabled)
    {
        if(self.sfaClient.configuration.logHeaders)
        {
            [self.sfaClient.loggingProvider debugWithFormat:@"Headers: %@", headers];
        }
        if(apiRequest.body != nil)
        {
            [self.sfaClient.loggingProvider debugWithFormat:@"Content:\n%@",apiRequest.body];
        }
    }
}

- (void)logApiRequestURL:(SFAApiRequest *)request
{
    NSString *requestUrl = [request composedUrl].absoluteString;
    if(!self.sfaClient.configuration.logPersonalInformation)
    {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\b[A-Z0-9]{8}(?:-[A-F0-9]{4}){3}-[A-F0-9]{12}\b" options:NSRegularExpressionCaseInsensitive error:&error];
        if(error)
        {
            return;
        }
        requestUrl = [regex stringByReplacingMatchesInString:requestUrl options:0 range:NSMakeRange(0, requestUrl.length) withTemplate:@"^***^"];
    }
    if(self.sfaClient.loggingProvider.isDebugEnabled)
    {
        [self.sfaClient.loggingProvider debugWithFormat:@"%@ %@", request.httpMethod, requestUrl];
    }
}

- (void)logResponseWithHttpRequestResponseContainer:(SFAHttpRequestResponseDataContainer *)container responseObj:(id)responseObj
{
    if(self.sfaClient.loggingProvider.isDebugEnabled)
    {
        [self.sfaClient.loggingProvider debugWithFormat:@"Response Code: %ld", container.response.statusCode];
        if(container.error)
        {
            [self.sfaClient.loggingProvider debugWithFormat:@"Response Error: %@", container.error];
        }
        if(self.sfaClient.configuration.logHeaders)
        {
            [self.sfaClient.loggingProvider debugWithFormat:@"Response Headers: %@", container.response.allHeaderFields];
        }
        if(responseObj != nil)
        {
            [self.sfaClient.loggingProvider debugWithFormat:@"Content:\n%@", responseObj];
        }
    }
}

@end
