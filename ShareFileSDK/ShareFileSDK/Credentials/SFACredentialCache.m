#import "SFACredentialCache.h"
#import "NSURLCredential+sfapi.h"
#import "SFACredentialCacheProtected.h"
#import "SFAOAuth2Credential.h"

@implementation SFACredentialAuthorityContainer

- (instancetype)init {
    self = [super init];
    if (self) {
        _credential = [[NSURLCredential alloc] initWithUser:@"" password:@"" persistence:NSURLCredentialPersistenceNone];
    }
    return self;
}

+ (SFACredentialAuthorityContainer *)defaultCredentialContainer {
    static SFACredentialAuthorityContainer *container;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^
                  { container = [[SFACredentialAuthorityContainer alloc] init]; });
    return container;
}

#pragma mark - NSSecureCoding

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _credential = [aDecoder decodeObjectOfClass:[NSURLCredential class] forKey:@"credential"];
        _originalURL = [aDecoder decodeObjectOfClass:[NSURL class] forKey:@"originalURL"];
        _key = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"key"];
        _authenticationType = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"authenticationType"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_credential forKey:@"credential"];
    [aCoder encodeObject:_originalURL forKey:@"originalURL"];
    [aCoder encodeObject:_key forKey:@"key"];
    [aCoder encodeObject:_authenticationType forKey:@"authenticationType"];
}

#pragma mark - NSCopying
- (instancetype)copyWithZone:(NSZone *)zone {
    SFACredentialAuthorityContainer *copy = [[[self class] alloc] init];
    
    if (copy) {
        copy.credential = [_credential copy];
        copy.originalURL = [_originalURL copy];
        copy.key = [_key copy];
        copy.authenticationType = [_authenticationType copy];
    }
    
    return copy;
}

- (NSString *)description {
    BOOL isOauthCred = [self.credential isKindOfClass:[SFAOAuth2Credential class]];
    return [NSString stringWithFormat:@"key: %@; type: %@, credUser: %@; hasCredPassword: %@", self.key, isOauthCred ? @"oAuth" : @"standard", self.credential.user, self.credential.hasPassword ? @"yes" : @"no"];
}

@end

@implementation SFACredentialCache

//This is needed as we are implementing getter ourselves for a read-only property.
@synthesize credentials = _credentials;

- (NSMutableDictionary *)credentials {
    if (!_credentials) {
        _credentials = [NSMutableDictionary new];
    }
    return _credentials;
}

#pragma mark - Public Methods

- (void)enumerateCredentialsWithBlock:(void (^)(NSURLCredential *, NSURL *, NSString *))block {
    if (block) {
        @synchronized(self)
        {
            [[self credentials] enumerateKeysAndObjectsUsingBlock: ^(id key, NSMutableArray *obj, BOOL *stop) {
                 [obj enumerateObjectsUsingBlock: ^(SFACredentialAuthorityContainer *obj, NSUInteger idx, BOOL *stop) {
                      block(obj.credential, obj.originalURL, obj.authenticationType);
                  }];
             }];
        }
    }
}

- (void)addCredential:(NSURLCredential *)credential forUrl:(NSURL *)url authType:(NSString *)authType;
{
    @synchronized(self)
    {
        [self internalAddCredential:credential forURL:url key:[self keyFromURL:url] authType:authType];
    }
}
- (void)removeCredentialForUrl:(NSURL *)url authType:(NSString *)authType {
    @synchronized(self)
    {
        [self removeCredentialContainerForKey:[self keyFromURL:url] authType:authType];
    }
}

- (void)removeCredential:(NSURLCredential *)credential forUrl:(NSURL *)url authType:(NSString *)authType {
    @synchronized(self)
    {
        // Get the saved credential
        NSURLCredential *cachedCred = [[self credentialContainerWithKey:[self keyFromURL:url] authType:authType] credential];
        
        if (credential == cachedCred || (cachedCred && [cachedCred isEqualToCredential:credential])) {
            [self removeCredentialContainerForKey:[self keyFromURL:url] authType:authType];
        }
    }
}

- (NSURLCredential *)credentialWithURL:(NSURL *)url authenticationType:(NSString *)authenticationType {
    NSURLCredential *cred = nil;
    @synchronized(self)
    {
        SFACredentialAuthorityContainer *credAuthority = [self credentialContainerWithKey:[self keyFromURL:url] authType:authenticationType];
        if (credAuthority != [SFACredentialAuthorityContainer defaultCredentialContainer]) {
            cred = [[self credentialContainerWithKey:[self keyFromURL:url] authType:authenticationType] credential];
        }
    }
    return cred;
}

#pragma mark - Private Methods

- (NSString *)keyFromURL:(NSURL *)url {
    return [url.host lowercaseString];
}

- (NSString *)keyFromProtectionSpace:(NSURLProtectionSpace *)ps {
    NSMutableString *key = [NSMutableString new];
    [key appendString:SFAPS];
    if (ps.protocol && ps.protocol.length > 0) {
        [key appendFormat:@"|%@:%@", SFAProtocol, ps.protocol];
    }
    if (ps.host && ps.host.length > 0) {
        [key appendFormat:@"|%@:%@", SFAHost, ps.host];
    }
    if (ps.port > 0) {
        [key appendFormat:@"|%@:%ld", SFAPort, (long)ps.port];
    }
    if (ps.realm && ps.realm.length > 0) {
        [key appendFormat:@"|%@:%@", SFARealm, ps.realm];
    }
    if (ps.proxyType && ps.proxyType.length > 0) {
        [key appendFormat:@"|%@:%@", SFAProxyType, ps.proxyType];
    }
    return [key copy];
}

- (SFACredentialAuthorityContainer *)credentialContainerWithKey:(NSString *)key authType:(NSString *)authType {
    SFACredentialAuthorityContainer *credentialContainer = nil;
    NSArray *containerList = [self.credentials objectForKey:key];
    if (containerList && containerList.count > 0) {
        if (!authType || authType.length <= 0) {
            credentialContainer = containerList[0];
        }
        else {
            for (SFACredentialAuthorityContainer *credentialItem in containerList) {
                if ([[credentialItem authenticationType] caseInsensitiveCompare:authType] == NSOrderedSame) {
                    credentialContainer = credentialItem;
                }
            }
        }
    }
    return credentialContainer ? credentialContainer :[SFACredentialAuthorityContainer defaultCredentialContainer];
}

- (void)internalAddCredential:(NSURLCredential *)credential forURL:(NSURL *)url key:(NSString *)key authType:(NSString *)authType {
    if (!key) {
        return;
    }
    
    SFACredentialAuthorityContainer *existingCredentialContainer = [self credentialContainerWithKey:key authType:authType];
    if (existingCredentialContainer != [SFACredentialAuthorityContainer defaultCredentialContainer]) {
        [self removeCredentialContainer:existingCredentialContainer];
    }
    
    NSMutableArray *containerList = [self.credentials objectForKey:key];
    if (!containerList) {
        containerList = [[NSMutableArray alloc] init];
    }
    SFACredentialAuthorityContainer *credentialContainer = [[SFACredentialAuthorityContainer alloc] init];
    [credentialContainer setAuthenticationType:authType];
    [credentialContainer setKey:key];
    [credentialContainer setCredential:credential];
    [credentialContainer setOriginalURL:url];
    [containerList addObject:credentialContainer];
    self.credentials[key] = containerList;
}

- (void)removeCredentialContainerForKey:(NSString *)key authType:(NSString *)authType;
{
    SFACredentialAuthorityContainer *existingCredentials = [self credentialContainerWithKey:key authType:authType];
    if (existingCredentials && existingCredentials != [SFACredentialAuthorityContainer defaultCredentialContainer]) {
        [self removeCredentialContainer:existingCredentials];
    }
}

- (void)removeCredentialContainer:(SFACredentialAuthorityContainer *)container {
    NSMutableArray *containerList = [NSMutableArray arrayWithArray:[self.credentials objectForKey:container.key]];
    if (containerList && containerList.count > 0) {
        [containerList removeObject:container];
        self.credentials[container.key] = containerList;
    }
}

- (void)copyInto:(SFACredentialCache *)cache {
    @synchronized(self)
    {
        cache->_credentials = [_credentials mutableCopy];
    }
}

- (instancetype)copyWithZone:(NSZone *)zone {
    SFACredentialCache *copy = [[self.class alloc] init];
    @synchronized(self)
    {
        copy->_credentials = [_credentials mutableCopy];
    }
    return copy;
}

@end
