#import "SFABaseAuthHandler.h"

@interface SFABaseAuthHandler ()

@property (nonatomic, strong) NSMutableArray *authParserClasses;

/**
 *  Internal initalization for class.
 */
- (void)internalInit __attribute__((objc_requires_super));

/**
 *  Determine if a given credential is the default placeholder credential or not.
 *
 *  @param credential Credential to check
 *
 *  @return BOOL indicating whether the credential is the default empty cred
 */
- (BOOL)isRealCredential:(NSURLCredential *)credential;

/**
 *  Internal handler for processing a finished response after a 401
 *
 *  @param httpContainer   Current HTTP response container
 *  @param authContext     Current authentication context
 *
 *  @return Enum indicating if the auth handler can handle given 401
 */
- (SFAAuthHandling_ResponseResult)processUnauthorizedReponse:(SFAHttpRequestResponseDataContainer *)httpContainer
                                                 authContext:(SFAuthenticationContext *)authContext;
                                                 
/**
 *  Internal handler for processing a finished success response
 *
 *  @param httpContainer   Current HTTP response container
 *  @param authContext     Current authentication context
 *
 *  @return Enum indicating auth handler response
 */
- (SFAAuthHandling_ResponseResult)processAuthSuccess:(SFAHttpRequestResponseDataContainer *)httpContainer
                                         authContext:(SFAuthenticationContext *)authContext;
/**
 *  Internal handler for async auth challenge handling
 *
 *  @param httpContainer     Current HTTP response container
 *  @param authContext       Current authentication context
 *  @param completionHandler Completion block that will be called after auth challenger attempts to handle the challenge
 *
 *  @return BOOL indicating if the authentication challenge was handled
 */
- (BOOL)internalHandleUnauthorizedResponse:(SFAHttpRequestResponseDataContainer *)httpContainer
                               authContext:(SFAuthenticationContext *)authContext
                         completionHandler:(void (^)(SFAAuthHandling_ResponseResult))completionHandler;
                         
/**
 *  Retrieve a credential from context and cred storage, for the given request.
 *
 *  @param req            Request that needs credentials
 *  @param context        Auth context for current task
 *  @param challenged     Is this a credential to respond to an auth challenge
 *  @param includeInvalid Should a credential marked SFACredential_StatusInvalid be allowed?
 *
 *  @return Credential for request, if any
 */
- (NSURLCredential *)credentialForRequest:(NSURLRequest *)req
                              authContext:(SFAuthenticationContext *)context
                            wasChallenged:(BOOL)challenged
                           includeInvalid:(BOOL)includeInvalid;
                           
@end
