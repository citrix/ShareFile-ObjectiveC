#import <Foundation/Foundation.h>
#import "SFAAsyncRequestProvider.h"
#import "SFABaseRequestProvider.h"
#import "SFATask.h"
#import "SFAQuery.h"
/**
 * Protocol that lets SFAClient communicate with any Async Request Provider for getting properly configured task's from query. In case you implement your custom Async Request Provider, it will need to conform to this protocol.
 */
@protocol SFAAsyncRequestProvider <NSObject>
/**
 *  Initializes task conforming to SFATransferTask protocol with provided parameters.
 *
 *  @param query Query to be performed by the task.
 *  @param queue NSOperationQueue on which the callbacks will be called.
 *  @param ccb   SFATask completion callback.
 *  @param canCb SFATask cancel callback.
 *
 *  @return Returns initialized task, conforming SFATransferTask, configured with provided parameters or nil if an object could not be created for some reason.
 */
- (id <SFATransferTask> )taskWithQuery:(id <SFAQuery> )query callbackQueue:(NSOperationQueue *)queue completionCallback:(SFATaskCompletionCallback)ccb cancelCallback:(SFATaskCancelCallback)canCb;

@end
/**
   The SFAAsyncRequestProvider conforms to SFAAsyncRequestProvider protocol and is used by SFAClient by default.
 */
@interface SFAAsyncRequestProvider : SFABaseRequestProvider <SFAAsyncRequestProvider>
/**
 *  Initializes SFAAsyncRequestProvider with SFAClient object.
 *
 *  @param client SFAClient object.
 *
 *  @return Returns initilized object of SFAAsyncRequestProvider or nil if an object could not be created for some reason.
 */
- (instancetype)initWithSFAClient:(SFAClient *)client;

@end
