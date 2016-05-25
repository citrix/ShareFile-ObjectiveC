#import "SFAOAuth2Credential.h"

@implementation SFAOAuth2Credential

@synthesize oAuthToken = _oAuthToken;

+ (NSString *)credentialType {
    return SFABearer;
}

- (instancetype)initWithOAuthToken:(SFAOAuthToken *)token {
    self = [super initWithUser:@"" password:token.accessToken persistence:NSURLCredentialPersistenceNone];
    if (self) {
        _oAuthToken = token;
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (BOOL)isEqualToCredential:(NSURLCredential *)credential {
    BOOL isEqual = [super isEqualToCredential:credential];
    
    if (isEqual && [credential isKindOfClass:[SFAOAuth2Credential class]]) {
        SFAOAuth2Credential *oauthCred = (SFAOAuth2Credential *)credential;
        isEqual = [self.oAuthToken isEqualToOAuthToken:oauthCred.oAuthToken];
    }
    
    return isEqual;
}

- (BOOL)isUsable {
    // OAuth can technically work without a username, but we need a valid
    // token (password) or refresh token + subdomain and CP
    return (self.password.length > 0 || self.oAuthToken.refreshToken.length > 0) && self.oAuthToken.subdomain && self.oAuthToken.apiControlPlane;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _oAuthToken = [aDecoder decodeObjectOfClass:[SFAOAuthToken class] forKey:@"oauthToken"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:_oAuthToken forKey:@"oauthToken"];
}

@end
