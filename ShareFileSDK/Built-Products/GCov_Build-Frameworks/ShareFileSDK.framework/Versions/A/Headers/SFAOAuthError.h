#import "SFAOAuthResponse.h"
#import "SFAError.h"
/**
 *  The SFAOAuthError class represents error occuring during OAuth Authentication.
 */
@interface SFAOAuthError : SFAError <SFAOAuthResponse>
/**
 *  NSString containing OAuth error
 */
@property (nonatomic, strong) NSString *error;
/**
 *  NSString containing OAuth error description.
 */
@property (nonatomic, strong) NSString *errorDescription;
/**
 *  Initializes SFAOAuthError with given NSDictionary and error type SFAErrorTypeOAuthError.
 *
 *  @param values NSDictionary to fill properties.
 *
 *  @return Returns SFAOAuthError object or nil if an object could not be created for some reason.
 */
+ (instancetype)errorWithDictionary:(NSDictionary *)values;

@end
