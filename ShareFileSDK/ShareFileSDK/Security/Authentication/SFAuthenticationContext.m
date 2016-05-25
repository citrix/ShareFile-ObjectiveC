#import "SFAuthenticationContext.h"

@implementation SFAuthenticationContext

- (id)copyWithZone:(NSZone *)zone {
    SFAuthenticationContext *copiedContext = [[SFAuthenticationContext alloc] init];
    
    copiedContext.challengeCount = self.challengeCount;
    
    copiedContext.originalRequestURL = self.originalRequestURL;
    copiedContext.lastRequestURL = self.originalRequestURL;
    copiedContext.lastAppliedCredential = self.lastAppliedCredential;
    copiedContext.authenticationChallenge = self.authenticationChallenge;
    
    copiedContext.interactiveCredentialCache = [self.interactiveCredentialCache copy];
    copiedContext.contextCredentialCache = [self.contextCredentialCache copy];
    copiedContext.interactiveHandler = self.interactiveHandler;
    return copiedContext;
}

@end
