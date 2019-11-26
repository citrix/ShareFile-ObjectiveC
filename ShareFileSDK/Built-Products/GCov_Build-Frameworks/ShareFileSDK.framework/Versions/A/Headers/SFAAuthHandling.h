#import <Foundation/Foundation.h>
#import "SFAHttpRequestResponseDataContainer.h"
#import "SFAAuthEnums.h"
#import "SFAInteractiveAuthHandling.h"
#import "SFACredentialStatusTracking.h"

@class SFAuthenticationContext;

@protocol SFAAuthHandling <NSObject>

/**
 *  Prepares a request, attaching any available authentication and cookies as needed,
 *  performs any housekeeping, such as clearing stale PCC cookies.
 *  A credential that cannot be added directly to the request will instead be returned.
 *
 *  @param req                Pending URLRequest
 *  @param authContext        Current auth context
 *  @param interactiveHandler Interactive handler (if any) for this task
 *
 *  @return Auth context for this new request. If an existing context was supplied, it will be modified and returned
 */
- (SFAuthenticationContext *)prepareRequest:(NSMutableURLRequest *)req
                                authContext:(SFAuthenticationContext *)authContext
                         interactiveHandler:(NSObject <SFAInteractiveAuthHandling> *)interactiveHandler;
                         
/**
 *  Auth call for housekeeping after a call has completed.
 *  If the connection failed, the credential used will be marked as invalid.
 *
 *  @param container   HTTP container for finished connection
 *  @param authContext Current auth context
 *
 *  @return Result directing response handler if an auth action is necessary
 */
- (SFAAuthHandling_ResponseResult)finishRequest:(SFAHttpRequestResponseDataContainer *)container
                                    authContext:(SFAuthenticationContext *)authContext;
                                    
/**
 *  Handle a 401 response from a finished connection. We are using our own
 *  SFHTTPAuthChallenge and SFCredential objects here rather than defaults because we
 *  support more forms of auth, such as OAuth and PCC.
 *
 *  @param container         Current HTTP response container
 *  @param authContext       Current auth context
 *  @param completionHandler Completion handler to call after Credential is acquired
 */
- (void)handleUnauthorizedResponse:(SFAHttpRequestResponseDataContainer *)container
                       authContext:(SFAuthenticationContext *)authContext
                 completionHandler:(void (^)(SFAAuthHandling_ResponseResult result))completionHandler;
                 
/**
 *  Handle a given authentication challenge for a connection. Store relevant challenge
 *  properties for later, when we handle them on connection completion.
 *
 *  @param challenge   Current auth challenge
 *  @param container   Current HTTP response container
 *  @param authContext Current auth context
 *  @param completionHandler Completion block to call with auth challenge result
 */
- (void)handleAuthChallenge:(NSURLAuthenticationChallenge *)challenge
              httpContainer:(SFAHttpRequestResponseDataContainer *)container
                authContext:(SFAuthenticationContext *)authContext
          completionHandler:(void (^)(SFURLAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;
          
@optional

/**
 *  This is currently only used by & implemented by SFABaseAuthHandler.
 */
@property (strong) NSObject <SFACredentialStatusTracking> *credentialTracker;

@end
