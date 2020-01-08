#import <Foundation/Foundation.h>
#import "SFABaseTask.h"
#import "SFAHttpHandleResponseReturnData.h"
#import "SFAHttpRequestResponseDataContainer.h"
#import "SFAQuery.h"

@class SFAHttpTask;
@class SFAClient;

@protocol SFAHttpTaskDelegate <NSObject>

- (NSURLRequest *)task:(SFAHttpTask *)task needsRequestForQuery:(id <SFAQuery> )query usingContextObject:(NSMutableDictionary **)contextObject;
- (SFAHttpHandleResponseReturnData *)task:(SFAHttpTask *)task needsResponseHandlingForQuery:(id <SFAQuery> )query httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject;

/**
 *  Task delegate for cases where the current connection needs to redirect the request (301.)
 *
 *  @param task                             Current SFAHttpTask
 *  @param request                          New request that the redirect specified
 *  @param httpRequestResponseDataContainer Current HTTP response container for task
 *  @param contextObject                    HTTPTask context object
 *
 *  @return NSURLRequest for redirect req, after housekeeping such as credentials and cookies are applied
 */
- (NSURLRequest *)task:(SFAHttpTask *)task willRedirectToRequest:(NSURLRequest *)request httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject;

/**
 *  Task delegate for storing authentication challenges receieved in the task
 *
 *  @param task                             Current SFAHttpTask
 *  @param challenge                        New authentication challenge
 *  @param httpRequestResponseDataContainer Current HTTP response container for task
 *  @param contextObject                    HTTPTask context object
 */
- (void)task:(SFAHttpTask *)task receivedAuthChallenge:(NSURLAuthenticationChallenge *)challenge httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary **)contextObject completionHandler:(void (^)(SFIURLAuthChallengeDisposition, NSURLCredential *))completionHandler;

@end

@interface SFAHttpTask : SFABaseTask <SFATransferTask>

@property (atomic, strong) NSMutableDictionary *contextObject;

// Designated Initializer
- (instancetype)initWithQuery:(id <SFAQuery> )query delegate:(id <SFAHttpTaskDelegate> )delegate contextObject:(id)contextObject callbackQueue:(NSOperationQueue *)queue client:(SFAClient *)client;

@end
