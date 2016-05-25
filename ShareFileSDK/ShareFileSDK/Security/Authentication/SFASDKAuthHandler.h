#import "SFABaseAuthHandler.h"
#import "SFAInteractiveAuthHandling.h"

@class SFAOAuthService;

/**
 * SDK Auth handler extends the base to add support for OAuth refresh.
 */
@interface SFASDKAuthHandler : SFABaseAuthHandler

- (instancetype)initWithOAuthService:(SFAOAuthService *)oauthService;

@end
