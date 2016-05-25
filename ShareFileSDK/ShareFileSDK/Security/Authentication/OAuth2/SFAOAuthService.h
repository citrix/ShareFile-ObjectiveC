#import <Foundation/Foundation.h>
#import "SFApiQuery.h"
#import "SFAOAuthAuthorizationCode.h"
#import "SFAOAuthToken.h"
/**
 * The SFAOAuthService protocol provides methods for getting quries for various OAuth grant types.
 */
@protocol SFAOAuthService <NSObject>
/**
 *  NSString containing clientId
 */
@property (nonatomic, strong) NSString *clientId;
/**
 *  NSString containing clientSecret.
 */
@property (nonatomic, strong) NSString *clientSecret;
/**
 *  Creates OAuth query with grant type authorization_code.
 *
 *  @param code SFAOAuthAuthorizationCode representing Authorization Code obtained in first step of OAuth2 authentication.
 *
 *  @return Returns SFApiQuery object.
 */
- (SFApiQuery *)tokenQueryFromAuthorizationCode:(SFAOAuthAuthorizationCode *)code;
/**
 *  Creates refersh OAuth token query from SFAOAuthToken with grant type refresh_token.
 *
 *  @param token SFAOAuthToken stored from earlier authentication.
 *
 *  @return Returns SFApiQuery object.
 */
- (SFApiQuery *)refreshOAuthTokenQuery:(SFAOAuthToken *)token;
/**
 *  Creates token query of grant type saml2-bearer with provided parameters.
 *
 *  @param samlAssertion           NSString containing assertion.
 *  @param subdomain               NSString containing subdomain.
 *  @param applicationControlPlane NSString containing application control plane.
 *
 *  @return Returns SFApiQuery object.
 */
- (SFApiQuery *)tokenQueryFromSamlAssertion:(NSString *)samlAssertion subdomain:(NSString *)subdomain applicationControlPlane:(NSString *)applicationControlPlane;
/**
 *  Creates request query for given username and password with grant type password
 *
 *  @param username                NSString containing username.
 *  @param password                NSString containing password.
 *  @param subdomain               NSString containing subdomain.
 *  @param applicationControlPlane NSString containing application control plane.
 *
 *  @return Returns SFApiQuery object.
 */
- (SFApiQuery *)passwordGrantRequestQueryForUsername:(NSString *)username password:(NSString *)password subdomain:(NSString *)subdomain applicationControlPlane:(NSString *)applicationControlPlane;
/**
 *  Creates authorization url from given parameter.
 *
 *  @param domain                NSString containing domain.
 *  @param responseType          NSString containing responseType.
 *  @param clientId              NSString containing clientId. Can be nil if clientId is set in OAuthService object.
 *  @param redirectUrl           NSString containg redirect url.
 *  @param state                 NSString containg state.
 *  @param additionalQueryParams NSString containing additional query params.
 *  @param subdomain             NSString containng subdomain.
 *
 *  @return Returns NSString representing Authorization URL.
 */
- (NSString *)authorizationUrlForDomain:(NSString *)domain responseType:(NSString *)responseType clientId:(NSString *)clientId redirectUrl:(NSString *)redirectUrl state:(NSString *)state additionalQueryParams:(NSDictionary *)additionalQueryParams subdomain:(NSString *)subdomain;

@end
/**
 *  The SFAOAuthService class implements SFAOAuthService protocol and is provided for convenience.
 */
@interface SFAOAuthService : NSObject <SFAOAuthService>
/**
 *  Reference to client conforming to SFAClient protocol.
 */
@property (nonatomic, weak) id <SFAClient> client;
/**
 *  Initializes SFAOAuthService with client, clientId and clientSceret.
 *
 *  @param client       An object conforming to SFAClient protocol.
 *  @param clientId     The string containing clientId.
 *  @param clientSecret The string containing clientSecret. Can be nil.
 *
 *  @return Returns SFAOAuthService object or nil if an object could not be created for some reason.
 */
- (instancetype)initWithSFAClient:(id <SFAClient> )client clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

@end
