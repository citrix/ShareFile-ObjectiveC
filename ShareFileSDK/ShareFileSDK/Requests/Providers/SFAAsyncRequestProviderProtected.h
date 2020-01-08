#import <Foundation/Foundation.h>
#import "SFAResponse.h"
#import "SFAApiRequest.h"
#import "SFAHttpTask.h"

@interface SFAAsyncRequestProvider () <SFAHttpTaskDelegate>

- (SFAResponse *)handleResponseForQuery:(id <SFAQuery> )query apiRequest:(SFAApiRequest *)apiRequest httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)container retryCount:(int)retryCount;
- (id)handleSuccessResponseForQuery:(id <SFAQuery> )query apiRequest:(SFAApiRequest *)apiRequest httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)container error:(SFAError **)error;
- (SFAEventHandlerResponse *)handleNonSuccessResponseForQuery:(id <SFAQuery> )query apiRequest:(SFAApiRequest *)apiRequest httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)container retryCount:(int)retryCount error:(SFAError **)error;
- (SFAError *)checkAsyncOperationScheduledWith:(SFAHttpRequestResponseDataContainer *)container;
//
- (NSURLRequest *)_task:(id)task needsRequestForQuery:(id <SFAQuery> )query usingContextObject:(NSMutableDictionary **)contextObject;
- (void)_task:(id)task receivedAuthChallenge:(NSURLAuthenticationChallenge *)challenge httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject completionHandler:(void (^)(SFIURLAuthChallengeDisposition, NSURLCredential *))completionHandler;
- (SFAHttpHandleResponseReturnData *)_task:(id)task needsResponseHandlingForQuery:(id <SFAQuery> )query httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject;

@end
