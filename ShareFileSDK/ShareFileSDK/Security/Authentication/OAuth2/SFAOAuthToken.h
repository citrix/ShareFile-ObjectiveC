#import "SFAOAuthResponseBase.h"
/**
 *  The SFAOAuthToken class represents access, refresh token of OAuth2 Authentication.
 */
@interface SFAOAuthToken : SFAOAuthResponseBase <NSSecureCoding>
/**
 *  NSString representing access token.
 */
@property (nonatomic, strong) NSString *accessToken;
/**
 *  NSString representing referesh token.
 */
@property (nonatomic, strong) NSString *refreshToken;
/**
 *  NSString representing token type.
 */
@property (nonatomic, strong) NSString *tokenType;
/**
 *  Creates NSURL with subdomain and api control plane
 *
 *  @return Returns NSURL created by subdomain and api control plane.
 */
- (NSURL *)getUrl;

/**
 *  Check token for equality
 *
 *  @param token OAuth token to compare
 *
 *  @return Boolean indicating equality
 */
- (BOOL)isEqualToOAuthToken:(SFAOAuthToken *)token;

@end
