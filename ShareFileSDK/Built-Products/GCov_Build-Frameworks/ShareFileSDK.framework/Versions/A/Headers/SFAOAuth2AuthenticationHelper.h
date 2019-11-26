#import <Foundation/Foundation.h>
#import "SFAOAuthResponse.h"
/**
 * The SFAOAuth2AuthenticationHelper class is provides methods for tracking if authentication was completed and parse out
 * response from the URLs.
 */
@interface SFAOAuth2AuthenticationHelper : NSObject
/**
 *  Initializes SFAOAuth2AuthenticationHelper with given completion url.
 *
 *  @param url NSURL completion URL.
 *
 *  @return Returns initialized SFAOAuth2AuthenticationHelper or nil if an object could not be created for some reason.
 */
- (instancetype)initWithUrl:(NSURL *)url;
/**
 *  Checks if navigation URL contains completion URL as prefix. If YES then returns object conforming SFAOAuthResponse.
 *
 *  @param navigationUrl A url for navigation.
 *
 *  @return Returns SFAOAuthResponse or nil if navigation URL does not contain completion URL as prefix.
 */
- (id <SFAOAuthResponse> )isComplete:(NSURL *)navigationUrl;

@end
