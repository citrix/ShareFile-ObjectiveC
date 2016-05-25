#import "SFAApiRequest.h"
#import "SFAApiRequestProtected.h"
#import "NSString+sfapi.h"

@implementation SFAApiRequest

#pragma mark - Protected Methods

- (void)setQueryBase:(SFAQueryBase *)queryBase {
    _queryBase = queryBase;
}

- (NSString *)queryStringForUrl {
    if (self.queryStringCollection.count > 0) {
        NSMutableString *string = [NSMutableString new];
        id <NSFastEnumeration> enumerable = [self.queryStringCollection collectionAsFastEnumrable];
        for (SFAODataParameter *parameter in enumerable) {
            NSString *val = parameter.value != nil ? parameter.value : @"";
            [string appendFormat:@"%@=%@&", [parameter.key escapeString], [val escapeString]];
        }
        if (string.length > 0) {
            return [string substringToIndex:string.length - 1];
        }
    }
    return nil;
}

#pragma mark - Public Methods

- (instancetype)init {
    self = [super init];
    if (self) {
        _queryStringCollection = [SFAODataParameterCollection new];
        _headerCollection = [NSMutableDictionary new];
    }
    return self;
}

+ (BOOL)isUrl:(NSString *)urlString {
    if (![urlString isValidURL]) {
        return NO;
    }
    if ([urlString hasPrefix:@"http://"]) {
        return YES;
    }
    if ([urlString hasPrefix:@"https://"]) {
        return YES;
    }
    return NO;
}

+ (SFAApiRequest *)apiRequestFromQuery:(SFAQueryBase *)queryBase {
    NSString *ids = [queryBase.ids description];
    NSString *action = queryBase.action.actionName;
    SFAODataParameterCollection *actionParameters = queryBase.action.parameters;
    SFAODataParameterCollection *queryString = queryBase.queryString;
    NSString *entityType = queryBase.from;
    id <SFAClient> client = queryBase.client;
    NSArray *subActions = queryBase.subActions;
    NSURL *queryBaseUrl = queryBase.baseUrl;
    
    NSMutableString *url = [NSMutableString new];
    if ([self isUrl:ids]) {
        [url appendString:ids];
    }
    else {
        NSURL *baseUrl = queryBaseUrl != nil ? queryBaseUrl : client.baseUrl;
        NSAssert(baseUrl != nil, SFAFormatBaseUrlNil);
        NSString *trimmedUrl = [baseUrl.absoluteString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]]; // Trims both ends.
        [url appendFormat:@"%@/%@", trimmedUrl, entityType];
        if (ids != nil && ids.length > 0) {
            [url appendFormat:@"(%@)", [queryBase.ids toStringForUri]];
        }
    }
    
    if (action.length > 0) {
        [url appendFormat:@"/%@", action];
        if (actionParameters.count > 0) {
            [url appendString:@"("];
            [url appendString:[actionParameters toStringForUri]];
            [url appendString:@")"];
        }
    }
    if (subActions.count > 0) {
        for (SFAODataAction *subAction in subActions) {
            [url appendFormat:@"/%@", subAction.actionName];
            
            if (subAction.parameters.count > 0) {
                [url appendString:@"("];
                [url appendString:[subAction.parameters toStringForUri]];
                [url appendString:@")"];
            }
        }
    }
    SFAApiRequest *apiRequest = [[SFAApiRequest alloc] init];
    apiRequest.url = [NSURL URLWithString:url];
    apiRequest.queryBase = queryBase;
    apiRequest.httpMethod = queryBase.httpMethod;
    apiRequest.body = queryBase.body;
    if ([queryBase conformsToProtocol:@protocol(SFAReadOnlyODataQuery)]) {
        id <SFAReadOnlyODataQuery> readOnlyODataQuery = (id <SFAReadOnlyODataQuery> )queryBase;
        int skip = readOnlyODataQuery.skip;
        int top = readOnlyODataQuery.top;
        id <SFAFilter> filter = readOnlyODataQuery.filter;
        NSString *select = [readOnlyODataQuery.selectProperties componentsJoinedByString:@","];
        NSString *expand = [readOnlyODataQuery.expandProperties componentsJoinedByString:@","];
        if (select != nil && select.length > 0) {
            [apiRequest.queryStringCollection addOrUpdateObject:[[SFAODataParameter alloc] initWithKey:SFAKeySelect value:select]];
        }
        if (expand != nil && expand.length > 0) {
            [apiRequest.queryStringCollection addOrUpdateObject:[[SFAODataParameter alloc] initWithKey:SFAKeyExpand value:expand]];
        }
        if (top > 0) {
            [apiRequest.queryStringCollection addOrUpdateObject:[[SFAODataParameter alloc] initWithKey:SFAKeyTop value:[NSString stringWithFormat:@"%d", top]]];
        }
        if (skip > 0) {
            [apiRequest.queryStringCollection addOrUpdateObject:[[SFAODataParameter alloc] initWithKey:SFAKeySkip value:[NSString stringWithFormat:@"%d", skip]]];
        }
        if (filter != nil) {
            [apiRequest.queryStringCollection addOrUpdateObject:[[SFAODataParameter alloc] initWithKey:SFAKeyFilter value:[filter description]]];
        }
    }
    if (queryString != nil) {
        id <NSFastEnumeration> enumerable = [queryString collectionAsFastEnumrable];
        for (SFAODataParameter *kvp in enumerable) {
            [apiRequest.queryStringCollection addOrUpdateObject:[[SFAODataParameter alloc] initWithKey:kvp.key value:kvp.value]];
        }
    }
    apiRequest.headerCollection = [queryBase.headers mutableCopy];
    return apiRequest;
}

- (NSURL *)composedUrl {
    if (self.composed) {
        return self.url;
    }
    NSString *queryString = [self queryStringForUrl];
    NSRange range = [self.url.absoluteString rangeOfString:@"?"];
    NSString *bridgeChar = @"";
    if (range.location == NSNotFound) {
        bridgeChar = @"?";
    }
    else {
        bridgeChar = @"&";
    }
    return (queryString == nil || queryString.length <= 0) ? self.url :[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", self.url.absoluteString, bridgeChar, queryString]];
}

@end
