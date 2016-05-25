#import "SFAError.h"
/**
 *  String constant for error language key in user info dictionary.
 */
extern NSString *const kSFAErrorLanguage;
/**
 *  The SFAODataRequestError class is used to inform API user about an error in OData Request.
 */
@interface SFAODataRequestError : SFAError
/**
 *  NSString containing language.
 */
@property (strong, nonatomic, readonly) NSString *language;
/**
 *  Initializes SFAODataRequestError instance with given dictionary.
 *
 *  @param dictionary A dictionary.
 *  @param response a response that originated this error.
 *
 *  @return Returns initialized SFAODataRequestError object or nil if an object could not be created for some reason.
 */
+ (instancetype)errorWithDictionary:(NSDictionary *)dictionary response:(NSHTTPURLResponse *)response;

@end
