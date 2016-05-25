#import "NSURLCredential+SFACredential.h"

@implementation NSURLCredential (SFACredential)

+ (NSString *)credentialType {
    return @"NSURLCredential";
}

- (NSString *)credentialType {
    return [[self class] credentialType];
}

- (NSURLCredential *)userNameOnlyRepresentation {
    return [[[self class] alloc] initWithUser:self.user password:@"" persistence:self.persistence];
}

@end
