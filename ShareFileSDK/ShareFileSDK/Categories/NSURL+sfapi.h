#import <Foundation/Foundation.h>

@interface NSURL (sfapi)

- (NSString *)authority;
- (NSString *)getAuthority;

/**
 *  Construct a comperable protection space for the current URL.
 *
 *  @param authenticationMethod Auth method for protection space
 *  @param relm                 Optional realm, if the server has more than one protection space
 *  @param isProxy              Boolean indicating whether protection space is a proxy
 *
 *  @return NSURLProtectionSpace representation of URL
 */
- (NSURLProtectionSpace *)protectionSpaceWithAuthenticationMethod:(NSString *)authenticationMethod realm:(NSString *)realm isProxy:(BOOL)isProxy;
@end
