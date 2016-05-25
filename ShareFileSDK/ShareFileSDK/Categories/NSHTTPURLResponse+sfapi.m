#import "NSHTTPURLResponse+sfapi.h"

@implementation NSHTTPURLResponse (sfapi)

- (BOOL)isSuccessCode {
    NSInteger code = self.statusCode;
    if (code >= 200 && code <= 299) {
        return YES;
    }
    return NO;
}

- (BOOL)isUnauthorizedCode {
    if (self.statusCode == 401) {
        return YES;
    }
    return NO;
}

- (BOOL)isTimeout {
    if (self.statusCode == 408) {
        return YES;
    }
    return NO;
}

- (BOOL)isGatewayTimeout {
    if (self.statusCode == 504) {
        return YES;
    }
    return NO;
}

- (BOOL)isProxyAuthenticationRequiredCode {
    if (self.statusCode == 407) {
        return YES;
    }
    return NO;
}

@end
