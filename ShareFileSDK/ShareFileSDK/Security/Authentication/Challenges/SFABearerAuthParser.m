#import "SFABearerAuthParser.h"
#import "SFAHTTPAuthenticationChallenge.h"
#import "NSHTTPURLResponse+sfapi.h"
#import "NSString+sfapi.h"
#import "SFAuthenticationContext.h"

@implementation SFABearerAuthParser

- (SFAHTTPAuthenticationChallenge *)authChallengeWithResponseContainer:(SFAHttpRequestResponseDataContainer *)container
                                                           authContext:(SFAuthenticationContext *)authContext {
    if (container && [container.response isUnauthorizedCode]) {
        BOOL bearerAuth = NO;
        
        NSString *authHeaderValue = container.response.allHeaderFields[SFAWWWAuthenticate];
        
        if (authHeaderValue.length > 0) {
            NSArray *authFields = [authHeaderValue componentsSeparatedByString:@" "];
            if (authFields.count == 1) {
                if ([(NSString *)[authFields objectAtIndex:0] compare:@"bearer" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    bearerAuth = YES;
                }
                if (bearerAuth) {
                    SFAHTTPAuthenticationChallenge *challenge = [[SFAHTTPAuthenticationChallenge alloc]
                                                                 initWithAuthMethod:kSFNSURLAuthenticationMethodBearer
                                                                 originalRequestURL:[authContext.originalRequestURL copy]
                                                                             andURL:[container.response URL]
                                                                            isProxy:[[container.response URL] isProxy]];
                    return challenge;
                }
            }
        }
    }
    
    return nil;
}

@end
