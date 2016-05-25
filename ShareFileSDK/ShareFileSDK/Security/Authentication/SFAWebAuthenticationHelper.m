#import "SFAWebAuthenticationHelper.h"
#import "NSString+sfapi.h"

@interface SFAWebAuthenticationHelper ()

@property (nonatomic) NSURL *completionUrl;

@end

@implementation SFAWebAuthenticationHelper

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.completionUrl = url;
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (NSDictionary *)isComplete:(NSURL *)navigationUrl {
    if ([navigationUrl.absoluteString hasPrefix:_completionUrl.absoluteString]) {
        NSString *queryString = navigationUrl.query;
        NSDictionary *queryStringDictionary = [queryString queryStringDictionary];
        return queryStringDictionary;
    }
    return nil;
}

@end
