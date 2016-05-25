#import "SFAOAuthError.h"
#import "SFAUtils.h"

@implementation SFAOAuthError

@synthesize properties = _properties;

- (NSDictionary *)userInfo {
    if ([super userInfo]) {
        return [super userInfo];
    }
    else {
        return self.properties;
    }
}

- (void)fillWithDictionary:(NSDictionary *)values;
{
    NSMutableDictionary *mutableValues = [values mutableCopy];
    NSString *value = [SFAUtils nilForNSNull:[mutableValues objectForKey:SFAErrorString]];
    if (value) {
        self.error = value;
        [mutableValues removeObjectForKey:SFAErrorString];
    }
    else {
        self.error = @"";
    }
    value = [SFAUtils nilForNSNull:[mutableValues objectForKey:SFAErrorDescription]];
    if (value) {
        self.errorDescription = value;
        [mutableValues removeObjectForKey:SFAErrorDescription];
    }
    else {
        self.errorDescription = @"";
    }
    self.properties = [mutableValues copy];
}

+ (instancetype)errorWithDictionary:(NSDictionary *)values {
    SFAOAuthError *err = [[self class] errorWithMessage:@"" type:SFAErrorTypeOAuthError domain:SFAOAuthErrorString code:0 userInfo:nil];
    [err fillWithDictionary:values];
    return err;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@ %@: %@", SFADescriptionError, self.error, SFADescription, self.errorDescription];
}

@end
