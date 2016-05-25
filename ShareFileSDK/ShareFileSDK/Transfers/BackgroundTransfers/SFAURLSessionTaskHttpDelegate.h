#import "SFAHttpHandleResponseReturnData.h"
#import "SFAAuthEnums.h"

@class SFAHttpRequestResponseDataContainer;

/**
 *  This protocol defines methods that a NSURLSessionTask can use for getting data, response handling and new tasks. Used with SDK background upload/download mechanism.
 */
@protocol SFAURLSessionTaskHttpDelegate <NSObject>

/**
 *  This delegate method should provide(if possible) a new task for the given session-task combination.
 *  The delegate can use context object for making decisions. See SFAURLSessionTaskRuntimeAssociationKeys.h
 *  The delegate should also associate HTTP delegate and context object with new task.
 *
 *  @param session Session of the session-task combination.
 *  @param task    Task of the session-task combination.
 *
 *  @return New task.
 */
- (NSURLSessionTask *)URLSession:(NSURLSession *)session taskNeedsNewTask:(NSURLSessionTask *)task;

/**
 *  This delegate method is called when task needs response handling.
 *
 *  @param session                          Session of the session-task combination.
 *  @param task                             Task of the session-task combination
 *  @param httpRequestResponseDataContainer HTTP request and response related data.
 *  @param contextObject                    Context object to be used for makingd decisions.
 *
 *  @return HTTP handle response return data. SFAHttpHandleResponseActionAsyncCallback is not supported.
 */
- (SFAHttpHandleResponseReturnData *)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needsResponseHandlingForHttpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject;

/**
 *  This delegate method is called when task received authentication challenge.
 *
 *  @param session                          Session of the session-task combination.
 *  @param task                             Task of the session-task combination
 *  @param challenge                        Authentication challenge received.
 *  @param httpRequestResponseDataContainer HTTP request and response related data.
 *  @param contextObject                    Context object to be used for makingd decisions.
 *  @param completionHandler                Completion handler to be called when delegate has handled challenge.
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task receivedAuthChallenge:(NSURLAuthenticationChallenge *)challenge httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject completionHandler:(void (^)(SFURLAuthChallengeDisposition, NSURLCredential *))completionHandler;

@end
