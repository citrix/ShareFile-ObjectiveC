#import <Foundation/Foundation.h>
#import "SFAOAuthResponse.h"
#import "SFAHttpBodyDataProvider.h"

@interface NSDictionary (sfapi) <SFAHttpBodyDataProvider>

- (id <SFAOAuthResponse> )convertToOAuthResponse;
- (id)objectForKey:(id)aKey andClass:(Class)objectClass;

@end
