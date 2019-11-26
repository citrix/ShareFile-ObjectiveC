#import <Foundation/Foundation.h>

@protocol SFACredentialCache <NSObject, NSCopying>

/**
 *  Add a given credential to the cache.
 *  Any existing credential for this URL/AuthType will be removed.
 *
 *  @param credential New credential to add
 *  @param url        URL where credential is valid
 *  @param authType   Authentication type for credential, or nil for default/first available
 */
- (void)addCredential:(NSURLCredential *)credential forUrl:(NSURL *)url authType:(NSString *)authType;

/**
 *  Remove any existing credential for URL/AuthType combination.
 *
 *  @param url      URL for credential
 *  @param authType Authentication type for credential, or nil for first available
 */
- (void)removeCredentialForUrl:(NSURL *)url authType:(NSString *)authType;

/**
 *  Remove a specific credential for a URL/AuthType combo.
 *
 *  @param credential Credential to remove
 *  @param url        URL for credential
 *  @param authType   Authentication type for credential, or nil for first available
 */
- (void)removeCredential:(NSURLCredential *)credential forUrl:(NSURL *)url authType:(NSString *)authType;

/**
 *  Retrieve a credential for a URL/AuthType combination
 *
 *  @param url                URL for credential
 *  @param authenticationType Authentication type for credential, or nil for first available
 *
 *  @return a credential if found, otherwise nil
 */
- (NSURLCredential *)credentialWithURL:(NSURL *)url authenticationType:(NSString *)authenticationType;

/**
 *  Iterate over all of the credentials managed by this cache.
 */
- (void)enumerateCredentialsWithBlock:(void (^)(NSURLCredential *credential, NSURL *url, NSString *authType))block;

@optional
/**
 *  (optional) persist this credential
 *
 *  @param cred NSURLCredential to persist
 *  @note  persistence mechanism may ignore the cred parameter and perist all credentials - depends on implementation
 */
- (void)persist:(NSURLCredential *)cred;

@end

// Credential Container/////////////////////////////////////////
@interface SFACredentialAuthorityContainer : NSObject <NSCopying, NSSecureCoding>

@property (nonatomic, strong) NSURLCredential *credential;
@property (nonatomic, strong) NSURL *originalURL;
@property (nonatomic, strong) NSString *authenticationType;

+ (SFACredentialAuthorityContainer *)defaultCredentialContainer;

@end
////////////////////////////////////////////////////////////////

// Credential Cache/////////////////////////////////////////////
@interface SFACredentialCache : NSObject <SFACredentialCache>

- (void)copyInto:(SFACredentialCache *)cache;

@end
////////////////////////////////////////////////////////////////
