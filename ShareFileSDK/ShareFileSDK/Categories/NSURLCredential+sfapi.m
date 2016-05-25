#import "NSURLCredential+sfapi.h"

@implementation NSURLCredential (sfapi)

- (BOOL)isEqualToCredential:(NSURLCredential *)credential {
    // Simple cases
    if (!credential) {
        return NO;
    }
    
    BOOL isEqual = self == credential;
    // Check properties
    if (!isEqual) {
        isEqual = self.user == credential.user || [self.user isEqualToString:credential.user];
        isEqual &= self.password == credential.password || [self.password isEqualToString:credential.password];
    }
    
    return isEqual;
}

- (BOOL)isUsable {
    // If a credential has a username, it should also have a password.
    // If there is no username, don't use this criteria.
    // Instead let the credential fail elsewhere.
    if (self.user.length > 0) {
        return self.password.length > 0;
    }
    return YES;
}

@end
