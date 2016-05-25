#import "SFAConsumerConnectorAuthParser.h"
#import "SFAHTTPAuthenticationChallenge.h"
#import "NSHTTPURLResponse+sfapi.h"
#import "NSString+sfapi.h"
#import "SFAuthenticationContext.h"

@implementation SFAConsumerConnectorAuthParser

- (SFAHTTPAuthenticationChallenge *)authChallengeWithResponseContainer:(SFAHttpRequestResponseDataContainer *)container
                                                           authContext:(SFAuthenticationContext *)authContext {
    if (container && [container.response isUnauthorizedCode]) {
        NSString *formsURLString = nil;
        NSString *tokenURLString = nil;
        
        NSString *authHeaderValue = container.response.allHeaderFields[SFAWWWAuthenticate];
        
        if (authHeaderValue.length > 0) {
            NSArray *authFields = [authHeaderValue componentsSeparatedByString:@" "];
            if (authFields.count == 4) {
                if ([(NSString *)[authFields objectAtIndex:0] compare:@"forms" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    formsURLString = (NSString *)[authFields objectAtIndex:1];
                }
                if ([(NSString *)[authFields objectAtIndex:2] compare:@"token" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    tokenURLString = (NSString *)[authFields objectAtIndex:3];
                }
                if (formsURLString.length > 0 && tokenURLString.length > 0) {
                    SFAHTTPAuthenticationChallenge *challenge = [[SFAHTTPAuthenticationChallenge alloc]
                                                                 initWithAuthMethod:kSFNSURLAuthenticationMethodConsumerConnector
                                                                 originalRequestURL:[authContext.originalRequestURL copy]
                                                                        andFormsURL:[formsURLString URL]
                                                                        andTokenURL:[tokenURLString URL]
                                                                            isProxy:[[container.response URL] isProxy]];
                    return challenge;
                }
            }
        }
    }
    
    return nil;
}

@end
