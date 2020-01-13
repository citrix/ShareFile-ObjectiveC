#import "SFAAuthEnums.h"

@class SFAHttpRequestResponseDataContainer, SFAuthenticationContext;

/**
 *  An interactive auth handler allows a SDK consumer to intercept
 *  authentication failure cases before the task fails with an error.
 */
@protocol SFAInteractiveAuthHandling <NSObject>

/**
 *  Handle a given authentication challenge for a connection. We are using our own
 *  SFIHTTPAuthChallenge and SFICredential objects here rather than defaults because we
 *  support more forms of auth, such as OAuth and PCC.
 *
 *  @param container         Current HTTP response container
 *  @param authContext       Current auth context
 *
 *  @return Boolean indicating if response will be handled. If false, the completion block will not be called by the interactive handler.
 */
- (BOOL)canHandleInteractiveUnauthorizedResponse:(SFAHttpRequestResponseDataContainer *)container
                                     authContext:(SFAuthenticationContext *)authContext;
                                     
/**
 *  Handle a given authentication challenge for a connection. We are using our own
 *  SFIHTTPAuthChallenge and SFICredential objects here rather than defaults because we
 *  support more forms of auth, such as OAuth and PCC.
 *
 *  @param container         Current HTTP response container
 *  @param authContext       Current auth context
 *  @param completionHandler Completion handler to call after Credential is acquired
 *
 *  @return Boolean indicating if response will be handled. If false, the completion block will not be called by the interactive handler.
 */
- (BOOL)handleInteractiveUnauthorizedResponse:(SFAHttpRequestResponseDataContainer *)container
                                  authContext:(SFAuthenticationContext *)authContext
                            completionHandler:(void (^)(SFIURLAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;
                            
@end
