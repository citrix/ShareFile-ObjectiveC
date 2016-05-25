#import "SFACompositeUploaderTask.h"
#import "SFACompositeUploaderTaskInternal.h"
#import "SFACompositeUploaderTaskPrivate.h"
#import "SFABaseTaskProtected.h"
#import "SFAUploadResponse.h"
#import "SFAUploaderTask.h"
#import "SFAUploaderTaskInternal.h"
#import "SFAApiResponse.h"
#import "SFAHttpTaskInternal.h"
#import "SFAHttpTaskProtected.h"

// NOTE: Some Private Functions and Properties may be defined inside xyzPrivate.h file.

@implementation SFACompositeUploaderTask

@synthesize progressCallback = _progressCallback;
@synthesize completionCallback = _completionCallback;
@synthesize cancelCallback = _cancelCallback;
@synthesize transferMetaData = _transferMetaData;

- (NSOperationQueue *)delegateQueue {
    if (!_delegateQueue) {
        _delegateQueue = [NSOperationQueue new];
        _delegateQueue.maxConcurrentOperationCount = 1; // We do not want functions to be called concurrently.
    }
    return _delegateQueue;
}

- (instancetype)initWithUploadSpecificationTask:(SFAHttpTask *)uploadSpecificationTask concurrentExecution:(NSUInteger)concurrentExecution uploaderTasks:(NSArray *)uploaderTasks finishTask:(SFAHttpTask *)finishTask delegate:(id <SFACompositeTaskDelegate> )delegate transferMetadata:(NSDictionary *)transferMetadata callbackQueue:(NSOperationQueue *)queue client:(SFAClient *)client uploadMethod:(SFAUploadMethod)method {
    self = [super init];
    if (self) {
        __weak SFACompositeUploaderTask *weakSelf = self;
        SFATaskCompletionCallback internalCompletionCallback = ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) { [weakSelf internalStandardUploadTaskCompletionWithValue:returnValue error:error additionalInfo:additionalInfo]; };
        
        self.delegate = delegate;
        self.uploaderTasks = uploaderTasks;
        self.concurrentExecutionCount = concurrentExecution;
        self.uploadMethod = method;
        
        self.uploadspecificationTask = uploadSpecificationTask;
        [self.uploadspecificationTask setCallbackQueue:self.delegateQueue];
        self.uploadspecificationTask.completionCallback = internalCompletionCallback;
        
        self.finishUploadTask = finishTask;
        [self.finishUploadTask setCallbackQueue:self.delegateQueue];
        self.finishUploadTask.completionCallback = internalCompletionCallback;
        
        self.progress = [SFATransferProgress new];
        self.progress.transferId = [[NSUUID UUID] UUIDString];
        self.transferMetaData = transferMetadata ? transferMetadata :[NSDictionary dictionary];
        self.progress.transferMetadata = self.transferMetaData;
        
        if (!queue) {
            self.queue = [NSOperationQueue mainQueue];
        }
        else {
            self.queue = queue;
        }
    }
    return self;
}

#pragma mark - Internal

- (void)initializeProgressWithTotalBytes:(int64_t)totalBytes {
    self.progress.totalBytes = totalBytes;
    self.progress.bytesTransferred = 0;
    self.progress.bytesRemaining = 0;
}

- (void)taskCompletedWithError:(SFAError *)error {
    [self taskCompleted:error];
}

#pragma mark - Private

- (void)internalMultiChunkUploadTaskCompletionWithValue:(id)returnValue error:(SFAError *)error additionalInfo:(NSDictionary *)additionalInfo {
    // No need to handle error incase of Upload Task
    if ([self isFinished]) {
        return; // Incase there is previously queued callback. We don't need to handle it.
    }
    if ([returnValue isKindOfClass:[SFAApiResponse class]]) {
        SFAApiResponse *response = returnValue;
        if (response.error) {
            // Incase finish call is failed.
            [self taskCompleted:[SFAError errorWithMessage:response.value type:SFAErrorTypeUploadError]];
        }
    }
    else if ([returnValue isKindOfClass:[SFAUploadResponse class]]) {
        // Upload Finished
        [self taskCompleted:returnValue];
    }
    else if (error) {
        // Cancel other tasks and notify
        [self cancelAllTasks];
        [self taskCompleted:error];
    }
}

- (void)internalStandardUploadTaskCompletionWithValue:(id)returnValue error:(SFAError *)error additionalInfo:(NSDictionary *)additionalInfo {
    if ([self isFinished]) {
        return; // Incase there is previously queued callback. We don't need to handle it.
    }
    if ([returnValue isKindOfClass:[SFUploadSpecification class]]) {
        // Specification Task Done. Setup Delegate and Start Uploading
        [self.delegate compositeTask:self finishedSpecificationTaskWithUploadSpec:returnValue];
        [self startUploaders];
    }
    else if ([returnValue isKindOfClass:[SFAUploadResponse class]]) {
        // Upload Finished
        [self taskCompleted:returnValue];
    }
    else if (error) {
        // Cancel other tasks and notify
        [self cancelAllTasks];
        [self taskCompleted:error];
    }
}

- (void)internalProgress:(int64_t)bytesTransfered {
    SFATransferProgress *progress;
    @synchronized(self)
    {
        self.progress.bytesTransferred += bytesTransfered;
        self.progress.bytesRemaining = self.progress.totalBytes - self.progress.bytesTransferred;
        self.progress.complete = self.progress.bytesTransferred >= self.progress.totalBytes;
        progress = [self.progress copy];
    }
    
    [self notifyProgressWithTransferProgress:progress];
}

- (void)notifyProgressWithTransferProgress:(SFATransferProgress *)progress {
    SFATransferTaskProgressCallback cb = self.progressCallback;
    NSDictionary *notificationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:progress, kSFATransferTaskNotificationUserInfoProgress, nil];
    [self.queue addOperationWithBlock: ^{
         if (self.isExecuting) {
             if (cb) {
                 cb(progress);
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:kSFATransferTaskProgressNotification object:self userInfo:notificationDictionary];
         }
     }];
}

#pragma Private

- (void)cancelAllTasks {
    [self.uploadspecificationTask cancel];
    [self.uploadTasksQueue cancelAllOperations];
}

- (void)didMarkFinishedWithValue:(id)retVal {
    if (self.isCancelled) {
        [self cancelAllTasks];
        SFATaskCancelCallback cb = self.cancelCallback;
        [self.queue addOperationWithBlock: ^{
             if (cb) {
                 cb();
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:kSFATaskCancelNotification object:self userInfo:nil];
         }];
    }
    else { // If finished
           // Only possibility of this code getting executed is from connection thread.
        SFATaskCompletionCallback cb = self.completionCallback;
        SFATaskCancelCallback ccb = self.cancelCallback;
        NSMutableDictionary *notificationDictM = [NSMutableDictionary new];
        SFAError *error = nil;
        id returnValue = nil;
        if ([retVal isKindOfClass:[SFAError class]]) {
            error = retVal;
            notificationDictM[kSFATaskNotificationUserInfoError] = error;
        }
        else {
            returnValue = retVal;
            if (returnValue) {
                notificationDictM[kSFATaskNotificationUserInfoReturnValue] = returnValue;
            }
        }
        NSDictionary *notificationUserInfo = [notificationDictM copy];
        [self.queue addOperationWithBlock: ^{
             if (!self.isCancelled) {
                 if (cb) {
                     cb(returnValue, error, nil);
                 }
                 [[NSNotificationCenter defaultCenter] postNotificationName:kSFATaskCompleteNotification object:self userInfo:notificationUserInfo];
             }
             else {
                 if (ccb) {
                     ccb();
                 }
                 [[NSNotificationCenter defaultCenter] postNotificationName:kSFATaskCancelNotification object:self userInfo:nil];
             }
         }];
    }
}

- (void)startUploaders {
    self.uploadTasksQueue = [NSOperationQueue new];
    self.uploadTasksQueue.maxConcurrentOperationCount = (NSInteger)self.concurrentExecutionCount;
    
    __weak SFACompositeUploaderTask *weakSelf = self;
    SFATaskCompletionCallback internalMultiChunkUploaderTaskCompletionCallback = ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) { [weakSelf internalMultiChunkUploadTaskCompletionWithValue:returnValue error:error additionalInfo:additionalInfo]; };
    
    SFAUploaderTaskProgressCallback internalProgressCallBack = ^(SFATransferProgress *progress) {
        [weakSelf internalProgress:progress.bytesTransferred];
    };
    SFATaskCompletionCallback internalStandardUploadCompletionCallback = ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) { [weakSelf internalStandardUploadTaskCompletionWithValue:returnValue error:error additionalInfo:additionalInfo]; };
    
    for (SFAUploaderTask *task in self.uploaderTasks) {
        [task setCallbackQueue:self.delegateQueue];
        if (self.uploadMethod == SFAUploadMethodStandard) {
            task.completionCallback = internalStandardUploadCompletionCallback;
            task.uploaderTaskProgressCallback = internalProgressCallBack;
        }
        else if (self.uploadMethod == SFAUploadMethodStreamed) {
            task.completionCallback = internalMultiChunkUploaderTaskCompletionCallback;
            task.uploaderTaskProgressCallback = internalProgressCallBack;
        }
        else { // SFAUploadMethodThreaded
            task.completionCallback = internalMultiChunkUploaderTaskCompletionCallback;
            task.uploaderTaskProgressCallback = internalProgressCallBack;
        }
        [self.finishUploadTask addDependency:task];
    }
    [self.uploadTasksQueue addOperations:self.uploaderTasks waitUntilFinished:NO];
    if (self.finishUploadTask) {
        [self.uploadTasksQueue addOperation:self.finishUploadTask];
    }
}

#pragma mark - Base Task Override

- (void)startForcefully {
    [self.uploadspecificationTask start];
}

@end
