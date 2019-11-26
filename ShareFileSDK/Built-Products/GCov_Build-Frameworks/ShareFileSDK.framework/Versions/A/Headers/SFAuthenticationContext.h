#import <Foundation/Foundation.h>
#import "SFACredentialCache.h"
#import "SFAHTTPAuthenticationChallenge.h"
#import "SFAInteractiveAuthHandling.h"

/**
 *  Authentication context for ongoing HTTPTasks.
 *  Used for keeping state while handling auth for a HTTPTask.
 */
@interface SFAuthenticationContext : NSObject <NSCopying>

/**
 *  Number of times the current context has seen an authentication challenge
 */
@property (nonatomic, assign) NSUInteger challengeCount;

/**
 *  Original request URL associated with the authentication context
 */
@property (nonatomic, copy) NSURL *originalRequestURL;

/**
 *  Most recent request URL for authentication context.
 *  May differ from original URL, if there was a redirect, etc.
 */
@property (nonatomic, copy) NSURL *lastRequestURL;

/**
 *  Last credential applied to a request in this auth context
 */
@property (nonatomic, copy) NSURLCredential *lastAppliedCredential;

/**
 *  Last credential applied to a request in this auth context
 */
@property (nonatomic, copy) NSURLCredential *lastCandidateCredential;

/**
 *  Current authentication challenge for this context
 */
@property (nonatomic, strong) SFAHTTPAuthenticationChallenge *authenticationChallenge;

/**
 *  Temporary credential cache for creds supplied through user
 *  interaction. Credentials in this cache take presidence over both
 *  the request cache and the auth handler's own credential store,
 *  credentials from this cache are not checked for validity before.
 *  being applied
 *  Upon an auth failure, a bad credential here will be removed to
 *  ensure it is not applied next time.
 */
@property (nonatomic, strong) NSObject <SFACredentialCache> *interactiveCredentialCache;

/**
 *  Temporary credential cache for current context. Credentials in
 *  this cache are applied when a request is prepared, if the credential is
 *  not known to be invalid.
 */
@property (nonatomic, strong) NSObject <SFACredentialCache> *contextCredentialCache;

/**
 *  Interactive handler (if any) for the current task
 */
@property (nonatomic, weak) NSObject <SFAInteractiveAuthHandling> *interactiveHandler;

/**
 *  Specifies if the auth context is associated with a background request.
 */
@property (nonatomic, readwrite) BOOL backgroundRequest;

@end
