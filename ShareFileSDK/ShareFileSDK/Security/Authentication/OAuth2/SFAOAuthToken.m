#import "SFAUtils.h"

@implementation SFAOAuthToken

- (void)fillWithDictionary:(NSDictionary *)values;
{
    NSMutableDictionary *mutableValues = [values mutableCopy];
    NSString *value = [SFAUtils nilForNSNull:[mutableValues objectForKey:SFAAccessToken]];
    if (value) {
        self.accessToken = value;
        [mutableValues removeObjectForKey:SFAAccessToken];
    }
    value = [SFAUtils nilForNSNull:[mutableValues objectForKey:SFARefreshToken]];
    if (value) {
        self.refreshToken = value;
        [mutableValues removeObjectForKey:SFARefreshToken];
    }
    value = [SFAUtils nilForNSNull:[mutableValues objectForKey:SFATokenType]];
    if (value) {
        self.tokenType = value;
        [mutableValues removeObjectForKey:SFATokenType];
    }
    [super fillWithDictionary:[mutableValues copy]];
}

- (NSURL *)getUrl {
    // Subdomain is saved as a lower case string here because while the platform will accept either,
    // it returns itemURIs with a lower case subdomain. Matching against a given item to
    // the account base later requires the baseURI to agree.
    NSString *urlPath = [[NSString stringWithFormat:@"https://%@.%@/sf/v3/", self.subdomain, self.apiControlPlane] lowercaseString];
    NSURL *url = [[NSURL alloc] initWithString:urlPath];
    return url;
}

- (BOOL)isEqualToOAuthToken:(SFAOAuthToken *)token {
    // Simple cases
    if (!token) {
        return NO;
    }
    
    BOOL isEqual = self == token;
    // Check properties
    if (!isEqual) {
        isEqual = self.accessToken == token.accessToken || [self.accessToken isEqualToString:token.accessToken];
        isEqual &= self.refreshToken == token.refreshToken || [self.refreshToken isEqualToString:token.refreshToken];
        isEqual &= self.tokenType == token.tokenType || [self.tokenType isEqualToString:token.tokenType];
    }
    
    return isEqual;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _accessToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:SFAAccessToken];
        _refreshToken = [aDecoder decodeObjectOfClass:[NSString class] forKey:SFARefreshToken];
        _tokenType = [aDecoder decodeObjectOfClass:[NSString class] forKey:SFATokenType];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_accessToken forKey:SFAAccessToken];
    [aCoder encodeObject:_refreshToken forKey:SFARefreshToken];
    [aCoder encodeObject:_tokenType forKey:SFATokenType];
}

@end
