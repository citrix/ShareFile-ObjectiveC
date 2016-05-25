#import "SFAOAuthResponse.h"
/**
 *  The SFAOAuthResponseBase class conforms to SFAOAuthResponse protocol and is base class of all OAuth reponses.
 */
@interface SFAOAuthResponseBase : NSObject <SFAOAuthResponse, NSSecureCoding>
/**
 *  NSString representing user's ShareFile Application control plane.
 */
@property (nonatomic, strong) NSString *applicationControlPlane;
/**
 *  NSString representing user's ShareFile API control plane.
 */
@property (nonatomic, strong) NSString *apiControlPlane;
/**
 *  NSString string representing user's ShareFile subdomian.
 */
@property (nonatomic, strong) NSString *subdomain;
/**
 *  NSTimeInterval representing expiration time in seconds.
 */
@property (nonatomic) NSTimeInterval expiresAt;

@end
