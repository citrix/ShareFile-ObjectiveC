#import "SFAOAuthAuthorizationCode.h"
#import "SFAUtils.h"

@implementation SFAOAuthAuthorizationCode

+ (SFAOAuthAuthorizationCode *)createFromDictionary:(NSDictionary *)values {
    SFAOAuthAuthorizationCode *authorizationCode = [[SFAOAuthAuthorizationCode alloc] init];
    [authorizationCode fillWithDictionary:values];
    return authorizationCode;
}

- (void)fillWithDictionary:(NSDictionary *)values;
{
    NSMutableDictionary *mutableValues = [values mutableCopy];
    NSString *value = [SFAUtils nilForNSNull:[mutableValues objectForKey:SFACode]];
    if (value) {
        self.code = value;
        [mutableValues removeObjectForKey:SFACode];
    }
    value = [SFAUtils nilForNSNull:[mutableValues objectForKey:SFAState]];
    if (value) {
        self.state = value;
        [mutableValues removeObjectForKey:SFAState];
    }
    
    [super fillWithDictionary:[mutableValues copy]];
}

@end
