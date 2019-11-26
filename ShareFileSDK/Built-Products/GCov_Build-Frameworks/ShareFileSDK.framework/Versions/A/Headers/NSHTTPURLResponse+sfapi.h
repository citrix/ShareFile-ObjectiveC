#import <Foundation/Foundation.h>

@interface NSHTTPURLResponse (sfapi)

- (BOOL)isSuccessCode;
- (BOOL)isUnauthorizedCode;
- (BOOL)isTimeout;
- (BOOL)isGatewayTimeout;
- (BOOL)isProxyAuthenticationRequiredCode;

@end
