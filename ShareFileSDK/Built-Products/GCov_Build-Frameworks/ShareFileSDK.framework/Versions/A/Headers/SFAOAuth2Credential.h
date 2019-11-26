#import <Foundation/Foundation.h>
#import "SFAOAuthToken.h"
#import "NSURLCredential+SFACredential.h"

@interface SFAOAuth2Credential : NSURLCredential <NSSecureCoding>

@property (strong, nonatomic, readonly) SFAOAuthToken *oAuthToken;

- (instancetype)initWithOAuthToken:(SFAOAuthToken *)token;

@end
