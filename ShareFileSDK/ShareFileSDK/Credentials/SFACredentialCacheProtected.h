#import "SFACredentialCache.h"

#pragma mark - CredentialAuthorityContainer

@interface SFACredentialAuthorityContainer ()

@property (nonatomic, strong) NSString *key;

+ (SFACredentialAuthorityContainer *)defaultCredentialContainer;

@end

#pragma mark - CredentialCache

@interface SFACredentialCache ()

@property (nonatomic, readonly, strong) NSMutableDictionary *credentials;

- (NSString *)keyFromURL:(NSURL *)url;
- (NSString *)keyFromProtectionSpace:(NSURLProtectionSpace *)ps;
- (SFACredentialAuthorityContainer *)credentialContainerWithKey:(NSString *)key authType:(NSString *)authType;
- (void)internalAddCredential:(NSURLCredential *)credential forURL:(NSURL *)url key:(NSString *)key authType:(NSString *)authType;
- (void)removeCredentialContainerForKey:(NSString *)key authType:(NSString *)authType;
- (void)removeCredentialContainer:(SFACredentialAuthorityContainer *)container;

@end
