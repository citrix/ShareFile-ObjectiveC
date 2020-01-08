#import "SFAHttpTask.h"
#import "SFAHttpTaskProtected.h"
#import "SFABaseTaskProtected.h"
#import "SFAHttpTaskExternal.h"
#import "SFAHttpResponseActionAsyncCallback.h"
#import "NSHTTPURLResponse+sfapi.h"

@interface SFAHttpTask ()

@property (nonatomic, strong) SFAActionStopwatch *stopwatch;

@end

@implementation SFAHttpTask

@synthesize progressCallback = _progressCallback;
@synthesize transferMetaData = _transferMetaData;

- (NSOperationQueue *)delegateQueue {
    if (!_delegateQueue) {
        _delegateQueue = [NSOperationQueue new];
        _delegateQueue.maxConcurrentOperationCount = 1; // We do not want functions to be called concurrently.
    }
    return _delegateQueue;
}

#pragma mark - Public Functions

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (instancetype)initWithQuery:(id <SFAQuery> )query delegate:(id <SFAHttpTaskDelegate> )delegate contextObject:(id)contextObject callbackQueue:(NSOperationQueue *)queue client:(SFAClient *)client {
    self = [super init];
    if (self) {
        NSAssert(query != nil, @"Passed parameter query can not be nil.");
        NSAssert(delegate != nil, @"Passed parameter delegate can not be nil.");
        NSAssert(client != nil, @"Passed parameter client can not be nil.");
        [self initializeWithQuery:query delegate:delegate contextObject:contextObject callbackQueue:queue client:client];
    }
    return self;
}

- (instancetype)initWithDelegate:(id <SFAHttpTaskDelegate> )delegate contextObject:(id)contextObject callbackQueue:(NSOperationQueue *)queue client:(SFAClient *)client {
    self = [super init];
    if (self) {
        [self initializeWithQuery:nil delegate:delegate contextObject:contextObject callbackQueue:queue client:client];
    }
    return self;
}

- (void)initializeWithQuery:(id <SFAQuery> )query delegate:(id <SFAHttpTaskDelegate> )delegate contextObject:(id)contextObject callbackQueue:(NSOperationQueue *)queue client:(SFAClient *)client {
    self.query = query;
    self.delegate = delegate;
    self.client = client;
    self.contextObject = contextObject;
    if (!queue) {
        self.queue = [NSOperationQueue mainQueue];
    }
    else {
        self.queue = queue;
    }
    self.lock = [NSObject new];
}

#pragma mark - Base Task Override

- (void)startForcefully {
    [self makeConnection];
}

- (void)didMarkFinishedWithValue:(id)retVal {
    if (self.isCancelled) {
        // This code can get executed from both connection thread or 'cancel'
        // thread.
        // But above sync block will ensure that only one thread ever in lifetime
        // gets past it.
        //
        // This is for safety, in case this method is called from any delegate method except
        // connection finished or fail delegate. This is also needed if it is called from
        // 'cancel' thread.
        // In case connection is nil we will have no effect. If connection is
        // already finished/failed this will also have no effect.
        [self.connection cancel];
        [self.redirectionTask cancel];
        SFATaskCancelCallback cb = self.cancelCallback;
        [self.queue addOperationWithBlock: ^{
             if (cb) {
                 cb();
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:kSFATaskCancelNotification object:self userInfo:nil];
         }];
    }
    else {
        // Only possibility of this code getting executed is from connection thread.
        SFATaskCompletionCallback cb = self.completionCallback;
        SFATaskCancelCallback ccb = self.cancelCallback;
        NSDictionary *additionalInfo = nil;
        if (self.redirectionTaskAdditionalDictionary) {
            additionalInfo = self.redirectionTaskAdditionalDictionary;
        }
        else {
            SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:self.request response:self.response data:[self.data copy] error:self.error];
            additionalInfo = @{ kSFAHttpRequestResponseDataContainer : container };
        }
        NSMutableDictionary *notificationDictM = [NSMutableDictionary new];
        notificationDictM[kSFATaskNotificationUserInfoAdditionalInfo] = additionalInfo;
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
                     cb(returnValue, error, additionalInfo);
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
    [self.client.loggingProvider traceActionStopWatch:self.stopwatch];
}

#pragma mark - Protected

- (void)notifyProgress {
    // Make Progress Object
    SFATransferProgress *progress = [SFATransferProgress new];
    progress.bytesTransferred = (long long)self.byteTransfered;
    progress.bytesRemaining = (long long)self.transferSize - (long long)self.byteTransfered;
    progress.totalBytes = (long long)self.transferSize;
    progress.transferMetadata = self.transferMetaData;
    progress.complete = progress.bytesRemaining <= 0;
    //
    [self notifyProgressWithTransferProgress:progress];
}

- (void)notifyProgressWithTransferProgress:(SFATransferProgress *)transferProgress {
    SFATransferTaskProgressCallback cb = self.progressCallback;
    NSDictionary *notificationDictionary = [NSDictionary dictionaryWithObjectsAndKeys:transferProgress, kSFATransferTaskNotificationUserInfoProgress, nil];
    [self.queue addOperationWithBlock: ^{
         // This check might no be enough for preventing progress callback after finish.
         if (self.isExecuting) {
             if (cb) {
                 cb(transferProgress);
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:kSFATransferTaskProgressNotification object:self userInfo:notificationDictionary];
         }
     }];
}

- (void)handleCompletion {
    // This method is always called from connection thread.
    id contextObject = self.contextObject;
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:self.request response:self.response data:[self.data copy] error:self.error];
    SFAHttpHandleResponseReturnData *data = [self.delegate task:self needsResponseHandlingForQuery:self.query httpRequestResponseDataContainer:container usingContextObject:&contextObject];
    self.contextObject = contextObject;
    
    if (data.responseAction == SFAHttpHandleResponseActionAsyncCallback) {
        __weak SFAHttpTask *weakSelf = self;
        
        SFAHttpResponseActionAsyncCallback *callbackObject = data.returnValue;
        if (callbackObject) {
            [callbackObject asyncCallWithCompleteBlock: ^(SFAHttpHandleResponseReturnData *asyncResponseReturnData) {
                 [weakSelf.delegateQueue addOperationWithBlock: ^{
                      [weakSelf reexecuteOrFinish:asyncResponseReturnData];
                  }];
             }];
        }
        return;
    }
    else {
        [self reexecuteOrFinish:data];
    }
}

- (void)reexecuteOrFinish:(SFAHttpHandleResponseReturnData *)data {
    if (data.responseAction == SFAHttpHandleResponseActionReExecute) {
        [self needsToReExecute];
    }
    else {
        [self taskCompleted:data.returnValue];
    }
}

- (void)needsToReExecute {
    SFAHttpTask *redirectionTask = [self needsRedirectionTask];
    __weak SFAHttpTask *weakSelf = self;
    redirectionTask.completionCallback = ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
        weakSelf.redirectionTaskAdditionalDictionary = additionalInfo;
        id toBePassedValue = returnValue ? returnValue : error;
        [weakSelf taskCompleted:toBePassedValue];
    };
    redirectionTask.progressCallback = ^(SFATransferProgress *progress) { [weakSelf notifyProgressWithTransferProgress:progress]; };
    // This lock is needed because otherwise the current thread can be suspended inside 'if' while some other thread cancels the the task.
    // When current thread resumes it will start the task.
    @synchronized(self.lock)
    {
        if (self.isExecuting) {
            self.redirectionTask = redirectionTask;
            [self.redirectionTask start];
        }
    }
}

- (instancetype)needsRedirectionTask {
    id redirectionTask = nil;
    if (self.query) {
        redirectionTask = [[[self class] alloc] initWithQuery:self.query delegate:self.delegate contextObject:self.contextObject callbackQueue:self.delegateQueue client:self.client];
    }
    else {
        redirectionTask = [[[self class] alloc] initWithDelegate:self.delegate contextObject:self.contextObject callbackQueue:self.delegateQueue client:self.client];
    }
    return redirectionTask;
}

#pragma mark - Private

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)makeConnection {
    // Need this so that no thread can change the state while connection is being
    // setup.
    // This prevents the scenerio where connection thread is suspended inside the
    // 'if', and another thread calls 'cancel'.
    // After that other thread completes 'cancel' flow, this thread will continue
    // with making a connection, when operation has already
    // been cancelled.
    @synchronized(self.lock)
    // To avoid deadlock on self. As KVO observer might
    // shift to another thread with
    // performOnThreadAndWait which will create deadlock
    // on self.
    {
        if (self.isExecuting) {
            id contextObj = self.contextObject;
            NSURLRequest *request = [self.delegate task:self needsRequestForQuery:self.query usingContextObject:&contextObj];
            self.contextObject = contextObj;
            NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            
            if (connection) {
                self.connection = connection;
                self.request = request;
                self.data = [NSMutableData new];
                [connection setDelegateQueue:self.delegateQueue];
                [connection start];
                self.stopwatch = [[SFAActionStopwatch alloc] initWithName:@"RequestRoundTrip" loggingProvider:self.client.loggingProvider];
            }
            else {
                NSError *error = [NSError errorWithDomain:SFAErrorConnection code:0 userInfo:nil];
                [self taskCompleted:error];
            }
        }
    }
}
#pragma clang diagnostic pop

#pragma mark - NSURLConnectionDataDelegate NSURLConnectionDelegate Methods

// These are called on connection thread.
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)inRequest redirectResponse:(NSURLResponse *)redirectResponse {
    NSURLRequest *newRequest = inRequest;
    
    if (redirectResponse) {
        SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:self.request response:self.response data:[self.data copy] error:self.error];
        id contextObject = self.contextObject;
        
        newRequest = [self.delegate task:self willRedirectToRequest:inRequest httpRequestResponseDataContainer:container usingContextObject:&contextObject];
        
        self.request = newRequest;
        self.data = [NSMutableData new];
        self.contextObject = contextObject;
    }
    
    return newRequest;
}

- (void)connection:(NSURLConnection *)cn didReceiveData:(NSData *)data {
    [self.data appendData:data];
    self.byteTransfered += data.length;
    [self notifyProgress];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.response = (NSHTTPURLResponse *)response;
    self.byteTransfered = 0;
    if (self.isExecuting && [self.response isSuccessCode] && self.response.allHeaderFields[SFAContentLength]) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        self.transferSize = [[formatter numberFromString:self.response.allHeaderFields[SFAContentLength]] unsignedLongLongValue];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)cn {
    [self handleCompletion];
}

- (void)connection:(NSURLConnection *)cn didFailWithError:(NSError *)error {
    self.error = error;
    [self handleCompletion];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:self.request response:self.response data:[self.data copy] error:self.error];
    id contextObject = self.contextObject;
    
    // Call out so we can parse this challenge
    [self.delegate task:self receivedAuthChallenge:challenge httpRequestResponseDataContainer:container usingContextObject:&contextObject completionHandler: ^(SFIURLAuthChallengeDisposition disp, NSURLCredential *cred) {
         switch (disp) {
             case SFIURLAuthChallengeUseCredential:
                 [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
                 break;
                 
             case SFIURLAuthChallengeCancelAuthenticationChallenge:
                 [challenge.sender cancelAuthenticationChallenge:challenge];
                 break;
                 
             default:
                 [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
                 break;
         }
     }];
}

#pragma mark - Internal Functions

- (void)setCallbackQueue:(NSOperationQueue *)queue {
    @synchronized(self)
    {
        self.queue = queue;
    }
}

@end
