#import <Foundation/Foundation.h>
/**
   The SFAWebAuthenticationHelper is helper class for performing web based OAuth2 Authentication. Also see SFAOAuth2AuthenticationHelper.
 */
@interface SFAWebAuthenticationHelper : NSObject
/**
 *  Initialize SFAWebAuthenticationHelper with given URL
 *
 *  @param url NSURL representing redirect/completion URL.
 *
 *  @return Returns initialized SFAWebAuthenticationHelper object or nil if an object could not be created for some reason.
 */
- (instancetype)initWithURL:(NSURL *)url;
/**
 *  Checks if passed URL's prefix matches redirect/completion URL then returns query string dictionary.
 *
 *  @param navigationUrl NSURL to be matched.
 *
 *  @return Returns query string dictionary or nil if navigation URL's prefix does not match redirect/completion URL.
 */
- (NSDictionary *)isComplete:(NSURL *)navigationUrl;

@end
