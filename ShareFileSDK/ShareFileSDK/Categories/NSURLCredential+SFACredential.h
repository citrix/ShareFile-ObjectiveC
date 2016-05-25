#import <Foundation/Foundation.h>
#import "NSURLCredential+sfapi.h"

@interface NSURLCredential (SFACredential)

+ (NSString *)credentialType;

- (NSString *)credentialType;
- (NSURLCredential *)userNameOnlyRepresentation;

@end
