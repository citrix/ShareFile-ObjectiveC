#import <Foundation/Foundation.h>

@class SFAHTTPAuthenticationChallenge, SFAHttpRequestResponseDataContainer;

/**
 *  Parses a given HTTP response for one or more authentication challenge types.
 */
@protocol SFAConnectionAuthParser <NSObject>

/**
 *  Parse an auth challenge from a given HTTPResponse
 *
 *  @param container   Current HTTP response container
 *  @param authContext Current authentication context
 *
 *  @return Auth challenge, if any
 */
- (SFAHTTPAuthenticationChallenge *)authChallengeWithResponseContainer:(SFAHttpRequestResponseDataContainer *)container
                                                           authContext:(SFAuthenticationContext *)authContext;
@end
