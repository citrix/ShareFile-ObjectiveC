#import "SFAUtils.h"

@interface SFAOAuthResponseBase ()

@end

@implementation SFAOAuthResponseBase

@synthesize properties = _properties;

- (void)fillWithDictionary:(NSDictionary *)values;
{
    NSMutableDictionary *mutableValues = [values mutableCopy];
    long expVal = ((NSNumber *)[SFAUtils nilForNSNull:[mutableValues objectForKey:SFAExpiresIn]]).longValue;
    if (expVal) {
        self.expiresAt = [[NSDate date] timeIntervalSince1970] + expVal;
        [mutableValues removeObjectForKey:SFAExpiresIn];
    }
    NSString *value = [SFAUtils nilForNSNull:[mutableValues objectForKey:SFAAppCp]];
    if (value) {
        self.applicationControlPlane = value;
        [mutableValues removeObjectForKey:SFAAppCp];
    }
    
    value = [SFAUtils nilForNSNull:[mutableValues objectForKey:SFAApiCp]];
    if (value) {
        self.apiControlPlane = value;
        [mutableValues removeObjectForKey:SFAApiCp];
    }
    
    value = [SFAUtils nilForNSNull:[mutableValues objectForKey:SFASubDomain]];
    if (value) {
        self.subdomain = value;
        [mutableValues removeObjectForKey:SFASubDomain];
    }
    
    self.properties = [mutableValues copy];
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [self init];
    if (self) {
        _expiresAt = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:SFAExpiresIn] doubleValue];
        _applicationControlPlane = [aDecoder decodeObjectOfClass:[NSString class] forKey:SFAAppCp];
        _apiControlPlane = [aDecoder decodeObjectOfClass:[NSString class] forKey:SFAApiCp];
        _subdomain = [aDecoder decodeObjectOfClass:[NSString class] forKey:SFASubDomain];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(_expiresAt) forKey:SFAExpiresIn];
    [aCoder encodeObject:_applicationControlPlane forKey:SFAAppCp];
    [aCoder encodeObject:_apiControlPlane forKey:SFAApiCp];
    [aCoder encodeObject:_subdomain forKey:SFASubDomain];
}

@end
