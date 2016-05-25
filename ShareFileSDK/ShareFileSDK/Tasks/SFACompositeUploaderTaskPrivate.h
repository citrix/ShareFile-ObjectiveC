#import "SFACompositeUploaderTask.h"

@interface SFACompositeUploaderTask ()

@property (nonatomic, strong) SFAHttpTask *uploadspecificationTask;
@property (nonatomic, strong) SFAHttpTask *finishUploadTask;
@property (nonatomic, strong) id <SFACompositeTaskDelegate> delegate;
@property (atomic) NSUInteger concurrentExecutionCount;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic) SFAUploadMethod uploadMethod;
@property (nonatomic, strong) NSOperationQueue *uploadTasksQueue;
@property (nonatomic, strong) SFATransferProgress *progress;
@property (nonatomic, strong) NSOperationQueue *delegateQueue;

- (void)internalProgress:(int64_t)bytesTransfered;

@end
