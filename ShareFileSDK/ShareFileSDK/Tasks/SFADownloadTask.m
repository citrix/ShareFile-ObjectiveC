#import "SFADownloadTask.h"
#import "SFAHttpTaskProtected.h"
#import "SFABaseTaskProtected.h"
#import "NSHTTPURLResponse+sfapi.h"

@interface SFADownloadTask ()

// Only Accessed on Connection Thread.
@property (strong, nonatomic) NSFileHandle *fileHandle;
@property (nonatomic) unsigned long long initialFileHandleOffset;
@property (nonatomic) BOOL skipWritingToFile;

@end

@implementation SFADownloadTask

@synthesize progressCallback = _progressCallback;
@synthesize dataReceivedCallback = _dataReceivedCallback;

- (instancetype)initWithQuery:(id <SFAQuery> )query fileHandle:(NSFileHandle *)handle transferMetaData:(NSDictionary *)transferMetaData transferSize:(unsigned long long)transferSize delegate:(id <SFAHttpTaskDelegate> )delegate contextObject:(id)contextObject callbackQueue:(NSOperationQueue *)queue client:(SFAClient *)client {
    self = [super initWithQuery:query delegate:delegate contextObject:contextObject callbackQueue:queue client:client];
    if (self) {
        self.fileHandle = handle;
        self.initialFileHandleOffset = handle.offsetInFile;
        self.transferMetaData = transferMetaData;
        self.transferSize = transferSize;
    }
    return self;
}

- (instancetype)initWithQuery:(id <SFAQuery> )query delegate:(id <SFAHttpTaskDelegate> )delegate contextObject:(id)contextObject callbackQueue:(NSOperationQueue *)queue client:(SFAClient *)client {
    NSAssert(NO, @"This init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (instancetype)needsRedirectionTask {
    id redirectionTask = nil;
    [self.fileHandle truncateFileAtOffset:self.initialFileHandleOffset];
    redirectionTask = [[[self class] alloc] initWithQuery:self.query fileHandle:self.fileHandle transferMetaData:self.transferMetaData transferSize:self.transferSize delegate:self.delegate contextObject:self.contextObject callbackQueue:self.delegateQueue client:self.client];
    [redirectionTask setDataReceivedCallback:self.dataReceivedCallback];
    return redirectionTask;
}

#pragma mark - NSURLConnectionDataDelegate NSURLConnectionDelegate Methods

// These are called on connection thread.

- (void)connection:(NSURLConnection *)cn didReceiveData:(NSData *)data {
    if (!self.skipWritingToFile) {
        @try {
            SFADownloadTaskDataReceivedCallback cb = self.dataReceivedCallback;
            NSData *mutatedData = data;
            if (self.isExecuting && cb) {
                mutatedData = cb(data);
            }
            // Just to be sure that callback did not take too long
            // and in between someone cancelled the tasks.
            if (self.isExecuting) {
                if (mutatedData) {
                    [self.fileHandle writeData:mutatedData];
                }
                self.byteTransfered += data.length;
                [self notifyProgress];
            }
        }
        @catch (NSException *exception)
        {
            SFAError *error = [SFAError errorWithMessage:exception.reason type:SFAErrorTypeUnknownError];
            [self taskCompleted:error];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [super connection:connection didReceiveResponse:response];
    self.skipWritingToFile = !(self.isExecuting && [self.response isSuccessCode]);
}

@end
