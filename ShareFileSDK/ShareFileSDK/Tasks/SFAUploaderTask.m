#import "SFAUploaderTask.h"
#import "SFAHttpTaskProtected.h"
#import "SFAUploaderTaskInternal.h"

@implementation SFAUploaderTask

- (instancetype)initWithDelegate:(id <SFACompositeTaskDelegate> )delegate client:(SFAClient *)client {
    self = [super initWithDelegate:(id < SFAHttpTaskDelegate >) delegate contextObject:nil callbackQueue:nil client:client];
    if (self) {
    }
    return self;
}

- (instancetype)initWithDelegate:(id <SFACompositeTaskDelegate> )delegate contextObject:(id)contextObj client:(SFAClient *)client {
    self = [super initWithDelegate:(id < SFAHttpTaskDelegate >) delegate contextObject:contextObj callbackQueue:nil client:client];
    if (self) {
    }
    return self;
}

- (void)notifyUploadProgressWithTransferProgress:(SFATransferProgress *)transferProgress {
    SFAUploaderTaskProgressCallback cb = self.uploaderTaskProgressCallback;
    [self.queue addOperationWithBlock: ^{
         if (cb) {
             cb(transferProgress);
         }
     }];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    SFATransferProgress *transferProgress = [SFATransferProgress new];
    transferProgress.transferMetadata = self.transferMetaData;
    transferProgress.bytesTransferred = bytesWritten;
    transferProgress.totalBytes = totalBytesExpectedToWrite;
    transferProgress.bytesRemaining = transferProgress.totalBytes - transferProgress.bytesTransferred;
    transferProgress.complete = transferProgress.bytesTransferred >= transferProgress.totalBytes;
    [self notifyUploadProgressWithTransferProgress:transferProgress];
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request {
    // If this delegate method returns NULL, the connection fails.
    return NULL;
}

@end
