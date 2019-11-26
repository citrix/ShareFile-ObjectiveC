#import "SFAOAuthResponseBase.h"
/**
 *  The SFAOAuthAuthorizationCode class represents Authorization Code of OAuth2 Authentication.
 */
@interface SFAOAuthAuthorizationCode : SFAOAuthResponseBase
/**
 *  NSString containing authorization code.
 */
@property (nonatomic, strong) NSString *code;
/**
 *  NSString containing authorization state.
 */
@property (nonatomic, strong) NSString *state;
/**
 *  Initializes SFAOAuthAuthorizationCode properties from provided NSDictionary.
 *
 *  @param values NSDictionary to fill properties.
 *
 *  @return Returns initialized SFAOAuthAuthorizationCode object or nil if an object could not be created for some reason.
 */
+ (SFAOAuthAuthorizationCode *)createFromDictionary:(NSDictionary *)values;

@end
