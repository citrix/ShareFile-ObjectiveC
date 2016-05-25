#import "SFAUploaderBase.h"
#import "SFAFileUploaderConfig.h"
#import "SFATransferTask.h"
#import "SFABackgroundSessionManager.h"
#import "SFAURLSessionTaskHttpDelegate.h"
/**
 *  The SFAAsyncUploaderBase class contains method for creating and starting uploader task, configured with given parameters.
 */
@interface SFAAsyncUploaderBase : SFAUploaderBase <SFAURLSessionTaskHttpDelegate>
/**
 *  Initializes and starts task conforming to SFATransferTask protocol for uploading a file with provided parameters.
 *
 *  @param transferMetadata   NSDictionary to be returned in transfer progress callback.
 *  @param callbackQueue      NSOperationQueue on which the callbacks will be called. If nil, defaults to main queue.
 *  @param completionCallback SFATask completion callback.
 *  @param cancelCallback     SFATask cancel callback.
 *  @param progressCallback   SFATransferTask progress callback.
 *
 *  @return Returns initialized and started task, conforming SFATransferTask, configured with provided parameters or nil if an object could not be created for some reason.
 */
- (id <SFATransferTask> )uploadAsyncWithTransferData:(NSDictionary *)transferMetadata callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback progressCallback:(SFATransferTaskProgressCallback)progressCallback;
/**
 *  Initializes and starts task conforming to SFATransferTask protocol for uploading a file with provided parameters.
 *
 *  @param callbackQueue      NSOperationQueue on which the callbacks will be called. If nil, defaults to main queue.
 *  @param completionCallback SFATask completion callback.
 *  @param cancelCallback     SFATask cancel callback.
 *  @param progressCallback   SFATransferTask progress callback.
 *
 *  @return Returns initialized and started task, conforming SFATransferTask, configured with provided parameters or nil if an object could not be created for some reason.
 */
- (id <SFATransferTask> )uploadAsyncWithCallbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback progressCallback:(SFATransferTaskProgressCallback)progressCallback;
/**
 *  Initialize and start a task which will eventually start background URL session task for upload. Completion callback(of returned task) can be used to get information about
 *  wheather background upload was started or not, as well as any other required information is passed in the completion callback.
 *
 *  @param delegate           Task specific delegate to be added for the URL session task that will be created.
 *  @param callbackQueue      NSOperationQueue on which callbacks are to be called.
 *  @param completionCallback Completion callback of the returned task.
 *  @param cancelCallback     Cancel callback of the returned task.
 *
 *  @return Task that will eventually start background URL session task for upload.
 */
- (id <SFATransferTask> )uploadBackgroundAsyncWithTaskDelegate:(id <SFAURLSessionTaskDelegate> )delegate callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback;


@end
