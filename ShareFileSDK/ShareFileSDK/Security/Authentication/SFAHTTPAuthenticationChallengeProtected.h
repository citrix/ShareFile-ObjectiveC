#import "SFAHTTPAuthenticationChallenge.h"
#import "NSURLCredential+SFACredential.h"

@interface SFAHTTPAuthenticationChallenge ()
{
}

@property (nonatomic, assign, readwrite) NSUInteger authenticationRetryCount;
@property (nonatomic, copy, readwrite) NSURL *originalRequestURL;
@property (nonatomic, copy, readwrite) NSURL *url;
@property (nonatomic, copy, readwrite) NSURL *formsURL;
@property (nonatomic, copy, readwrite) NSURL *tokenURL;
@property (nonatomic, copy, readwrite) NSURLProtectionSpace *protectionSpace;

@property (nonatomic, readwrite, strong) NSString *authMethod;

- (BOOL)isoAuth2OrBearerType;
- (BOOL)isCredentialValidForAuthentication:(NSURLCredential *)credential;
@end
