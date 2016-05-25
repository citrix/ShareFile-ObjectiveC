#import <Foundation/Foundation.h>
#import "SFAError.h"

extern NSString *const kSFAWebAuthenticationErrorDomain;
/**
 *  String constant for authentication header  key in user info dictionary.
 */
extern NSString *const kSFAErrorWWWAuthenticateHeader;
/**
 *  String constant for error request url  key in user info dictionary.
 */
extern NSString *const kSFAErrorRequestURL;

/**
 *  Failed authentication error code.
 */
extern NSInteger const kSFAWebAuthenticationErrorCode_Failed;

/**
 *  Auth failed/canceled due to a canceled auth challenge.
 */
extern NSInteger const kSFAWebAuthenticationErrorCode_ChallengeCancelled;

/**
 *  The SFAWebAuthenticationError is used to inform if HTTP request failed due to Authentication Error.
 */
@interface SFAWebAuthenticationError : SFAError
/**
 *  A string containing authentication header.
 */
@property (nonatomic, strong, readonly) NSString *wwwAuthenticateHeader;
/**
 *  URL for request.
 */
@property (nonatomic, strong, readonly) NSURL *requestUrl;

/**
 *  Initalizes SFAWebAuthenticationError instance with provided parameters.
 *
 *  @param message NSString representing error message.
 *  @param header  NSString containing authentication header.
 *  @param url     URL for request.
 *  @param error   underlying error, if any
 *
 *  @return Returns initialized SFAWebAuthenticationError object or nil if an object could not be created for some reason.
 */
+ (instancetype) errorWithMessage:(NSString *)message
    wwwAuthenticationHeaderString:(NSString *)header
                       requestURL:(NSURL *)url underlyingError:(NSError *)error;
                       
/**
 *  Initalizes SFAWebAuthenticationError indicating that the
 *  auth challenge was canceled instance with provided parameters.
 *
 *  @param message NSString representing error message.
 *  @param header  NSString containing authentication header.
 *  @param url     URL for request.
 *  @param error   underlying error, if any
 *
 *  @return Returns initialized SFAWebAuthenticationError object or nil if an object could not be created for some reason.
 */
+ (instancetype)challengeCanceledWithMessage:(NSString *)message
               wwwAuthenticationHeaderString:(NSString *)header
                                  requestURL:(NSURL *)url
                             underlyingError:(NSError *)error;
                             
@end
