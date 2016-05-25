#import <Foundation/Foundation.h>
#import "SFAAuthHandling.h"
#import "SFACredentialStatusTracking.h"
#import "SFACredentialCache.h"

/**
 * Base auth handler that authentication handlers may inherit from if desired.
 * The base handler includes general authentication challenge logic as well as
 * default handling to check a credential cache and apply Bearer or Basic auth
 * credentials to a request.
 */
@interface SFABaseAuthHandler : NSObject <SFAAuthHandling>

/**
 *  Credential store for auth handler. Base auth handler assumes the existence of a
 *  store however it does not initalize a specific store implementation.
 *  Setup is left to inheriting classes, else the reference will be nil.
 */
@property (strong) NSObject <SFACredentialCache> *credentialStore;

/**
 *  Initalize an authentication context. If an existing context is supplied, it will be returned.
 *
 *  @param existingContext Existing auth context, if any
 *
 *  @return Authentication Context for current task
 */
- (SFAuthenticationContext *)initalizeContext:(SFAuthenticationContext *)existingContext;

/**
 *  Register an authentication challenge parser
 *
 *  @param parserClass Auth parser classname
 */
- (void)registerAuthChallengeParser:(NSString *)parserClass;

/**
 *  Remove an authentication challenge parser
 *
 *  @param parserClass Auth parser classname
 */
- (void)removeAuthChallengeParser:(NSString *)parserClass;
/**
 *  A helper method that initalizes an authentication context. If an existing context is supplied, it will be returned.
 *
 *  @param existingContext Existing auth context, if any
 *
 *  @return New Authentication Context
 */
+ (SFAuthenticationContext *)initializeContextFromExistingContext:(SFAuthenticationContext *)existingContext;

@end
