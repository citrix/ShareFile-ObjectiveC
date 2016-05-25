#import "SFASDKAuthHandler.h"

@class SFAOAuthService;

@interface SFASDKAuthHandler ()

@property (nonatomic, strong) NSMutableDictionary *authTasks;
@property (nonatomic, strong) NSObject *lock;
@property (nonatomic, strong) SFAOAuthService *oauthService;

@end
