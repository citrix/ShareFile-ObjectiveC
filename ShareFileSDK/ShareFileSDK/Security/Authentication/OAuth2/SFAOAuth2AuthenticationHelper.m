#import "SFAOAuth2AuthenticationHelper.h"
#import "NSString+sfapi.h"
#import "NSDictionary+sfapi.h"

@interface SFAOAuth2AuthenticationHelper ()

@property (nonatomic, strong) NSString *completionUrl;

@end

@implementation SFAOAuth2AuthenticationHelper

- (instancetype)initWithUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        self.completionUrl = url.absoluteString;
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (id <SFAOAuthResponse> )isComplete:(NSURL *)navigationUrl {
    NSRange range = [navigationUrl.absoluteString rangeOfString:_completionUrl];
    BOOL startsWith = range.location != NSNotFound && range.location == 0;
    if (startsWith) {
        NSString *queryString = navigationUrl.query;
        NSDictionary *queryStringDictionary = [queryString queryStringDictionary];
        id <SFAOAuthResponse> response = [queryStringDictionary convertToOAuthResponse];
        return response;
    }
    return nil;
}

@end
