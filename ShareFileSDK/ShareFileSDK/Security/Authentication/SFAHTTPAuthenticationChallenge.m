#import "SFAHTTPAuthenticationChallenge.h"
#import "SFAHTTPAuthenticationChallengeProtected.h"
#import "SFAOAuth2Credential.h"

NSString *const kSFNSURLAuthenticationMethodOAuth2 = @"OAuth2";
NSString *const kSFNSURLAuthenticationMethodConsumerConnector = @"ConsumerConnector";  // CCP2
NSString *const kSFNSURLAuthenticationMethodBearer = @"Bearer";  // V3 API Bearer auth

@implementation SFAHTTPAuthenticationChallenge

- (void)internalInitWithAuthMethod:(NSString *)authMethod isProxy:(BOOL)isProxy {
    self.authenticationRetryCount = 0;
    
    if (!self.protectionSpace) {
        //create the protectionSpace
        NSString *protocol = nil;
        NSString *lowerScheme = self.url.scheme.lowercaseString;
        if ([lowerScheme isEqualToString:@"http"]) {
            protocol = NSURLProtectionSpaceHTTP;
        }
        else if ([lowerScheme isEqualToString:@"https"]) {
            protocol = NSURLProtectionSpaceHTTPS;
        }
        else {
            protocol = lowerScheme;
        }
        
        NSNumber *port = self.url.port;
        if (!port) {
            if ([protocol isEqualToString:NSURLProtectionSpaceFTP]) {
                port = [NSNumber numberWithInteger:21];
            }
            else if ([protocol isEqualToString:NSURLProtectionSpaceHTTPS]) {
                port = [NSNumber numberWithInteger:443];
            }
            else {
                port = [NSNumber numberWithInteger:80];
            }
        }
        
        if (isProxy) {
            self.protectionSpace = [[NSURLProtectionSpace alloc] initWithProxyHost:self.url.host.lowercaseString port:[port integerValue] type:[protocol isEqualToString:NSURLProtectionSpaceHTTPSProxy] ? NSURLProtectionSpaceHTTPSProxy : NSURLProtectionSpaceHTTPProxy realm:nil authenticationMethod:authMethod];
        }
        else {
            self.protectionSpace = [[NSURLProtectionSpace alloc] initWithHost:self.url.host.lowercaseString port:[port integerValue] protocol:protocol realm:nil authenticationMethod:authMethod];
        }
    }
    
    self.authMethod = authMethod;
}

- (instancetype)initWithAuthMethod:(NSString *)authMethod originalRequestURL:(NSURL *)originalURL andURL:(NSURL *)url isProxy:(BOOL)isProxy {
    self = [super init];
    if (self) {
        self.originalRequestURL = originalURL;
        self.url = url;
        [self internalInitWithAuthMethod:authMethod isProxy:isProxy];
    }
    return self;
}

- (instancetype)initWithAuthMethod:(NSString *)authMethod originalRequestURL:(NSURL *)originalURL andFormsURL:(NSURL *)formsUrl andTokenURL:(NSURL *)tokenUrl isProxy:(BOOL)isProxy {
    self = [super init];
    if (self) {
        self.originalRequestURL = originalURL;
        self.formsURL = formsUrl;
        self.tokenURL = tokenUrl;
        [self internalInitWithAuthMethod:authMethod isProxy:isProxy];
    }
    return self;
}

- (instancetype)initWithChallenge:(NSURLAuthenticationChallenge *)challenge withURL:(NSURL *)url originalRequestURL:(NSURL *)originalURL {
    self = [super init];
    if (self) {
        self.authenticationRetryCount = (NSUInteger)[challenge previousFailureCount];
        self.originalRequestURL = originalURL;
        self.url = url;
        self.protectionSpace = challenge.protectionSpace;
        
        [self internalInitWithAuthMethod:challenge.protectionSpace.authenticationMethod isProxy:[challenge.protectionSpace isProxy]];
    }
    return self;
}

- (BOOL)isoAuth2OrBearerType {
    BOOL oAuth2OrBearerType = NO;
    
    if (self.authMethod) {
        // Specialized credential validation (non-standard auth type)
        if ([self.authMethod isEqualToString:kSFNSURLAuthenticationMethodBearer] ||
            [self.authMethod isEqualToString:kSFNSURLAuthenticationMethodOAuth2]) {
            oAuth2OrBearerType = YES;
        }
    }
    return oAuth2OrBearerType;
}

- (BOOL)isCredentialValidForAuthentication:(NSURLCredential *)credential {
    BOOL credentialValid = NO;
    
    if (self.authMethod) {
        // Specialized credential validation (non-standard auth type)
        if ([credential isKindOfClass:[SFAOAuth2Credential class]] &&
            ([self.authMethod isEqualToString:kSFNSURLAuthenticationMethodBearer] ||
             [self.authMethod isEqualToString:kSFNSURLAuthenticationMethodOAuth2])) {
            SFAOAuth2Credential *oauthCred = (SFAOAuth2Credential *)credential;
            if (oauthCred.oAuthToken.accessToken) {
                credentialValid = YES;
            }
        }
    }
    else {
        // Generic credential validation (standard auth type)
        if ((credential.user.length > 0 && credential.password.length > 0)) {
            credentialValid = YES;
        }
    }
    return credentialValid;
}

- (NSString *)realm {
    return self.protectionSpace.realm;
}

@end
