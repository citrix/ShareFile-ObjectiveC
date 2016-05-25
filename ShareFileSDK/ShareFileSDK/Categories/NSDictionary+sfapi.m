#import "NSDictionary+sfapi.h"
#import "SFAHttpRequestUtils.h"
#import "SFAOAuthAuthorizationCode.h"
#import "SFAOAuthError.h"

@implementation NSDictionary (sfapi)

- (id <SFAOAuthResponse> )convertToOAuthResponse {
    id <SFAOAuthResponse> response = nil;
    if (self[SFACode]) {
        response = [SFAOAuthAuthorizationCode new];
    }
    else if (self[SFAAccessToken]) {
        response = [SFAOAuthToken new];
    }
    else if (self[SFAErrorString]) {
        response = [SFAOAuthError new];
    }
    else {
        response = [SFAOAuthResponseBase new];
    }
    [response fillWithDictionary:self];
    return response;
}

- (id)objectForKey:(id)aKey andClass:(Class)objectClass {
    id result = nil;
    
    @try {
        id o = [self objectForKey:aKey];
        if ([o isKindOfClass:objectClass]) {
            result = o;
        }
    }
    @catch (NSException *ex)
    {
    }
    
    return result;
}

- (void)addHttpBodyDataForMutableRequest:(NSMutableURLRequest *)request {
    [SFAHttpRequestUtils addFormDataWithParameters:self toURLRequest:request];
}

@end
