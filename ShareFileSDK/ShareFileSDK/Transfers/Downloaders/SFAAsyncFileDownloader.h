#import <Foundation/Foundation.h>
#import "SFAAsyncRequestProvider.h"
#import "SFADownloaderConfig.h"
#import "SFADownloadTaskExternal.h"
#import "SFABackgroundSessionManager.h"

/**
 *  The SFAAsyncFileDownloader class contain methods for creating and starting task's conforming to SFADownloadTask.
 */
@interface SFAAsyncFileDownloader : SFAAsyncRequestProvider <SFAURLSessionTaskHttpDelegate>
/**
 *  SFADownloaderConfig object reference. This config object is used by downloader when creating download query.
 */
@property (nonatomic, strong) SFADownloaderConfig *config;
/**
 *  Initializes and starts a task conforming to SFADownloadTask with provided paramters.
 *
 *  @param fileHandle         NSFileHandle object pointing to file, to which downloaded data will be written.
 *  @param transferMetadata   NSDictionary to be passed as parameter in transfer progress callback.
 *  @param callbackQueue      NSOperationQueue on which the callbacks will be called. If nil, defaults to main queue.
 *  @param completionCallback SFATask completion callback.
 *  @param cancelCallback     SFATask cancel callback.
 *  @param progressCallback   SFATransferTask progress callback.
 *
 *  @return Returns intialized and started task, conforming SFADownloadTask, configured with provided parameters.
 */
- (id <SFADownloadTask> )downloadAsyncToFileHandle:(NSFileHandle *)fileHandle withTransferMetadata:(NSDictionary *)transferMetadata callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback progressCallback:(SFATransferTaskProgressCallback)progressCallback;
/**
 *  Initializes and starts a task conforming to SFADownloadTask with provided parameters.
 *
 *  @param fileHandle         NSFileHandle object pointing to file, to which downloaded data will be written.
 *  @param transferMetadata   NSDictionary to be passed as parameter in transfer progress callback.
 *  @param callbackQueue      NSOperationQueue on which the callbacks will be called. If nil, defaults to main queue.
 *  @param completionCallback SFATask completion callback.
 *  @param cancelCallback     SFATask cancel callback.
 *  @param progressCallback   SFATransferTask progress callback.
 *  @param dataReceivedCallback   SFADownloadTask data received callback.
 *
 *  @return Returns intialized and started task, conforming SFADownloadTask, configured with provided parameters.
 *
 *  @warning dataReceivedCallback is not called on callback queue.
 */
- (id <SFADownloadTask> )downloadAsyncToFileHandle:(NSFileHandle *)fileHandle withTransferMetadata:(NSDictionary *)transferMetadata callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback progressCallback:(SFATransferTaskProgressCallback)progressCallback dataReceivedCallback:(SFADownloadTaskDataReceivedCallback)dataReceivedCallback;
/**
 *  Creates and starts a URL session task for background download.
 *
 *  @param delegate Task specific delegate to be added for created URL session task.
 *
 *  @return URL session task for background download.
 */
- (NSURLSessionDownloadTask *)downloadBackgroundAsyncWithTaskDelegate:(id <SFAURLSessionTaskDelegate> )delegate;

@end
