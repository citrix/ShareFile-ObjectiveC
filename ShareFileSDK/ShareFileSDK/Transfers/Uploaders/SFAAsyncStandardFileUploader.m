#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#import "SFAAsyncStandardFileUploader.h"
#import "SFAAsyncStandardFileUploaderPrivate.h"
#import "SFAAsyncUploaderBaseProtected.h" //Inheritence
#import "SFAUploaderBaseProtected.h"      //Inheritence
#import "NSStream+sfapi.h"
#import "SFACompositeUploaderTaskInternal.h"
#import "NSHTTPURLResponse+sfapi.h"
#import "SFASharedThreadManager.h"
#import "SFAUtils.h"
#import "SFAURLSessionTaskRuntimeAssociationKeys.h"
#import "SFABackgroundUploadInitiationTask.h"
#import "SFABackgroundUploadInitiationTaskInternal.h"
#import <objc/runtime.h>
#import "SFAuthenticationContext.h"

@interface SFAAsyncStandardFileUploader () <SFABackgroundUploadInitiationTaskDelegate>

@end

// Note: See xyzPrivate.h

@implementation SFAAsyncStandardFileUploader

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config andExpirationDays:(int)expirationDays {
    self = [super initWithSFAClient:client uploadSpecificationRequest:uploadSpecificationRequest filePath:filePath fileUploaderConfig:config andExpirationDays:expirationDays];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath;
{
    return [self initWithSFAClient:client uploadSpecificationRequest:uploadSpecificationRequest filePath:filePath fileUploaderConfig:nil andExpirationDays:-1];
}

#if TARGET_OS_IPHONE
- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset fileUploaderConfig:(SFAFileUploaderConfig *)config andExpirationDays:(int)expirationDays {
    self = [super initWithSFAClient:client uploadSpecificationRequest:uploadSpecificationRequest asset:asset fileUploaderConfig:config andExpirationDays:expirationDays];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset;
{
    return [self initWithSFAClient:client uploadSpecificationRequest:uploadSpecificationRequest asset:asset fileUploaderConfig:nil andExpirationDays:-1];
}
#endif

- (void)initialize {
    self.uploadSpecificationRequest.raw = NO;
}

+ (instancetype)uploaderForURLSessionTaskDefaultHTTPDelegateWithClient:(SFAClient *)client {
    SFAAsyncStandardFileUploader *uploader = [[[self class] alloc] initWithSFAClient:client uploadSpecificationRequest:[SFAUploadSpecificationRequest new] filePath:@""];
    uploader.defaultURLSessionTaskHTTPDelegate = YES;
    uploader.hasStartedTask = YES;
    return uploader;
}

+ (instancetype)uploaderForURLSessionTaskDelegateWithClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config andExpirationDays:(int)expirationDays uploadSpecification:(SFUploadSpecification *)uploadSpecification {
    NSAssert(uploadSpecification != nil, @"Passed parameter uploadSpecification can not be nil.");
    SFAAsyncStandardFileUploader *uploader = [[[self class] alloc] initWithSFAClient:client uploadSpecificationRequest:uploadSpecificationRequest filePath:filePath fileUploaderConfig:config andExpirationDays:expirationDays];
    uploader.hasStartedTask = YES;
    [uploader initializeUploadSpecificationRequest:uploadSpecification];
    return uploader;
}

- (id <SFATransferTask> )uploadAsyncWithTransferData:(NSDictionary *)transferMetadata callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback progressCallback:(SFATransferTaskProgressCallback)progressCallback;
{
    if (!self.hasStartedTask) {
        self.hasStartedTask = YES;
        // Make Upload Spec Query From Spec Req
        SFApiQuery *query = [self createUpload:self.uploadSpecificationRequest];
        // Make Upload Spec Task From Client. This is a simple query and task so its handled by Async Request Provider.
        // On Completion Composite Task will give a delegate call to Uploader.
        id <SFATransferTask> uploadSpecTask = [self.client taskWithQuery:query callbackQueue:nil completionCallback:nil cancelCallback:nil];
        // Make uploader task, its delegate is uploader. For standard this might be intercepted in between by the composite task.
        id <SFATransferTask> uploadTask = [[SFAUploaderTask alloc] initWithDelegate:self client:self.client];
        // Composite Uploader Task with delegate=self.
        SFACompositeUploaderTask *task = [[SFACompositeUploaderTask alloc] initWithUploadSpecificationTask:(SFAHttpTask *)uploadSpecTask concurrentExecution:1 uploaderTasks:@[uploadTask] finishTask:nil delegate:self transferMetadata:transferMetadata callbackQueue:callbackQueue client:self.client uploadMethod:SFAUploadMethodStandard];
        // We need to initalize the length of body for this task.
        [self initializeBodyLengthForTask:task];
        // Callback setup.
        task.completionCallback = completionCallback;
        task.cancelCallback = cancelCallback;
        task.progressCallback = progressCallback;
        // Execute
        [self.client executeTask:task];
        return task;
    }
    else {
        NSAssert(NO, @"Can not re-use this instance of uploader as it has already started an upload task.");
    }
    return nil;
}

- (id <SFATransferTask> )uploadBackgroundAsyncWithTaskDelegate:(id <SFAURLSessionTaskDelegate> )delegate callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback {
    if (!self.hasStartedTask) {
        self.hasStartedTask = YES;
        self.uploadSpecificationRequest.raw = YES;
        // Make Upload Spec Query From Spec Req
        SFApiQuery *query = [self createUpload:self.uploadSpecificationRequest];
        // Make Upload Spec Task From Client. This is a simple query and task so its handled by Async Request Provider.
        id <SFAAsyncRequestProvider> clientsReqProv = self.client.asyncRequestProvider;
        id <SFAHttpTaskDelegate> httpTaskDelegate = nil;
        if ([clientsReqProv conformsToProtocol:@protocol(SFAHttpTaskDelegate)]) {
            httpTaskDelegate = (id <SFAHttpTaskDelegate> )clientsReqProv;
        }
        else {
            SFAAsyncRequestProvider *reqProv = [[SFAAsyncRequestProvider alloc] initWithSFAClient:self.client];
            NSAssert([reqProv conformsToProtocol:@protocol(SFAHttpTaskDelegate)], @"Can not find an appropiate request provider.");
            httpTaskDelegate = (id <SFAHttpTaskDelegate> )reqProv;
        }
        SFABackgroundUploadInitiationTask *bgUploadInitiationTask = [[SFABackgroundUploadInitiationTask alloc] initWithQuery:query delegate:httpTaskDelegate contextObject:nil callbackQueue:callbackQueue client:self.client];
        bgUploadInitiationTask.backgroundUploadInitiationTaskDelegate = self;
        // Store for later.
        bgUploadInitiationTask.urlSessionTaskDelegate = delegate;
        bgUploadInitiationTask.completionCallback = completionCallback;
        bgUploadInitiationTask.cancelCallback = cancelCallback;
        // Execute
        [self.client executeTask:bgUploadInitiationTask];
        return bgUploadInitiationTask;
    }
    else {
        NSAssert(NO, @"Can not re-use this instance of uploader as it has already started an upload task.");
    }
    return nil;
}

#pragma mark - Protected Methods

// This is called from needsResponseHandling delegate to get Uploader specific response handling.
- (id)uploadResponseAsync:(SFAHttpRequestResponseDataContainer *)dataContainer {
    SFAError *errorResponse = nil;
    if ([dataContainer.response isSuccessCode]) {
        NSError *jsonError;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:dataContainer.data options:kNilOptions error:&jsonError];
        if (!jsonError) {
            NSNumber *error = jsonDictionary[SFAErrorString];
            if ([error intValue] != 0) {
                errorResponse = [SFAError errorWithMessage:jsonDictionary[SFAErrorMessage] type:SFAErrorTypeUploadError domain:@"" code:[jsonDictionary[SFAErrorCode] intValue] userInfo:nil];
            }
            else {
                // Uploadresponse parse here and set in shareFile response
                SFAUploadResponse *uploadResponse = [SFAUploadResponse new];
                [uploadResponse setPropertiesWithJSONDictionary:jsonDictionary];
                return uploadResponse;
            }
        }
        else {
            errorResponse = [SFAError errorWithMessage:[jsonError description] type:SFAErrorTypeInvalidResponseError];
        }
    }
    return errorResponse;
}

- (id <SFAQuery> )queryForURLSession:(NSURLSession *)session task:(NSURLSessionTask *)task {
    return nil;
}

#pragma mark - SFABackgroundUploaderSpecificationTaskDelegate

- (NSArray *)backgroundUploadInitiationTask:(SFABackgroundUploadInitiationTask *)task didReceiveUploadSepcification:(SFUploadSpecification *)val {
    [self initializeUploadSpecificationRequest:val];
    SFABackgroundSessionManager *sessionManager = self.client.backgroundSessionManager;
    NSURLSession *session = sessionManager.backgroundSession;
    NSURLSessionUploadTask *uploadTask = nil;
    if (session) {
        uploadTask = (NSURLSessionUploadTask *)[self URLSession:session taskNeedsNewTask:nil];
        if (uploadTask) {
            [sessionManager addDelegate:task.urlSessionTaskDelegate forSession:session andTaskWithIdentifier:uploadTask.taskIdentifier];
            id <SFAURLSessionTaskHttpDelegate> httpDelegate = objc_getAssociatedObject(uploadTask, [kSFAURLSessionTaskRuntimeAssociationHttpDelegate UTF8String]);
            NSMutableDictionary *contextObject = objc_getAssociatedObject(uploadTask, [kSFAURLSessionTaskRuntimeAssociationContextObject UTF8String]);
            [sessionManager notifiyDelegateUpdateForURLSession:session task:uploadTask delegate:httpDelegate];
            [sessionManager notifyContextUpdateForSession:session task:uploadTask contextObject:contextObject];
        }
    }
    if (!uploadTask) {
        return nil;
    }
    return @[session, uploadTask];
}

#pragma mark - CompositeTaskDelegate

- (void)compositeTask:(SFACompositeUploaderTask *)task finishedSpecificationTaskWithUploadSpec:(SFUploadSpecification *)val {
    [self initializeUploadSpecificationRequest:val];
}

#pragma mark - SFAURLSessionTaskHttpDelegate

- (NSURLSessionTask *)URLSession:(NSURLSession *)session taskNeedsNewTask:(NSURLSessionTask *)task {
    if (self.defaultURLSessionTaskHTTPDelegate) {
        // We do not have file path.
        return nil;
    }
    NSMutableDictionary *contextObject;
    if (task) {
        contextObject = objc_getAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationContextObject UTF8String]);
    }
    SFAuthenticationContext *authContext = contextObject[SFAAuthContextKey];
    if (!authContext) {
        authContext = [SFAuthenticationContext new];
        authContext.backgroundRequest = YES;
    }
    if (!contextObject) {
        contextObject = [NSMutableDictionary new];
    }
    contextObject[SFAAuthContextKey] = authContext;
    NSURLRequest *request = [self needsRequestForURLSessionTaskUsingContextObject:&contextObject];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromFile:[NSURL fileURLWithPath:self.fileHandler.filePath]];
    objc_setAssociatedObject(uploadTask, [kSFAURLSessionTaskRuntimeAssociationContextObject UTF8String], contextObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(uploadTask, [kSFAURLSessionTaskRuntimeAssociationHttpDelegate UTF8String], self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return uploadTask;
}

#pragma mark - SFAHttpTaskDelegate

- (NSURLRequest *)task:(SFAHttpTask *)task needsRequestForQuery:(id <SFAQuery> )query usingContextObject:(NSMutableDictionary **)contextObject {
    [self cleanUp]; // A saftey check to clean up everything before reexecuting http task.
    // Fetch data from context
    NSMutableDictionary *dict = (*contextObject) ? :[NSMutableDictionary dictionary];
    SFAuthenticationContext *authContext = [SFAUtils nilForNSNull:dict[SFAAuthContextKey]];
    
#if TARGET_OS_IPHONE
    if (!self.asset) {
#endif
    // Open a stream for the file we're going to send.  We open this stream
    // straight away because there's no need to delay.
    self.fileStream = [self.fileHandler streamForRead];
    assert(self.fileStream != nil);
    [self.fileStream open];
#if TARGET_OS_IPHONE
}

#endif
    // Open producer/consumer streams.  We open the producerStream straight
    // away.  We leave the consumerStream alone; NSURLConnection will deal
    // with it.
    NSInputStream *consStream;
    NSOutputStream *prodStream;
    [NSStream createBoundInputStream:&consStream outputStream:&prodStream bufferSize:SFAMaxBufferLength];
    assert(consStream != nil);
    assert(prodStream != nil);
    self.consumerStream = consStream;
    self.producerStream = prodStream;
    self.producerStream.delegate = self;
    // New Thread that will end when this request is done.
    //[NSThread detachNewThreadSelector:@selector(scheduleProducerStreamAndRunLoop) toTarget:self withObject:nil];
    // Using Shared thread.
    [self performSelector:@selector(scheduleProducerStream) onThread:[SFASharedThreadManager sharedThread] withObject:nil waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
    // Set up our state to send the body prefix first.
    self.buffer = [self.bodyPrefixData bytes];
    self.bufferLimit = [self.bodyPrefixData length];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self chunkUriForStandardUploads] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:self.config.httpTimeout];
    authContext = [self.client.authHandler prepareRequest:request authContext:authContext interactiveHandler:task.interactiveHandler];
    
    [dict setObject:authContext forKey:SFAAuthContextKey];
    
    assert(request != nil);
    [request setHTTPMethod:SFAPost];
    [request setHTTPBodyStream:self.consumerStream];
    [request setValue:[NSString stringWithFormat:@"%@\"%@\"", SFAMultiPartFormData, self.boundaryStr] forHTTPHeaderField:SFAContentType];
    [request setValue:[NSString stringWithFormat:@"%llu", self.bodyLength] forHTTPHeaderField:SFAContentLength];
    
    *contextObject = dict;
    return [request copy];
}

#pragma mark - NSStream Delegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our
// network stream.
{
#pragma unused(aStream)
    assert(aStream == self.producerStream);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
        {
            // NSLog(@"producer stream opened");
        }
        break;
        
        case NSStreamEventHasBytesAvailable:
        {
            assert(NO);
        }
        break;
        
        case NSStreamEventHasSpaceAvailable:
        {
            // Check to see if we've run off the end of our buffer.  If we have,
            // work out the next buffer of data to send.
            
            if (self.bufferOffset == self.bufferLimit) {
                // See if we're transitioning from the prefix to the file data.
                // If so, allocate a file buffer.
                
                if (self.bodyPrefixData != nil) {
                    self.bodyPrefixData = nil;
                    
                    assert(self.bufferOnHeap == NULL);
                    self.bufferOnHeap = malloc(SFAMaxBufferLength);
                    assert(self.bufferOnHeap != NULL);
                    self.buffer = self.bufferOnHeap;
                    
                    self.bufferOffset = 0;
                    self.bufferLimit = 0;
                }
                
                // If we still have file data to send, read the next chunk.
                BOOL condition = self.fileStream != nil;
#if TARGET_OS_IPHONE
                condition = condition || (self.asset && !self.assetDataRead);
#endif
                if (condition) {
                    NSError *err = nil;
                    NSUInteger bytesReadFromAsset = 0;
                    NSInteger bytesRead = 0;
#if TARGET_OS_IPHONE
                    ALAssetRepresentation *rep = self.asset.defaultRepresentation;
                    if (self.asset) {
                        bytesReadFromAsset = [rep getBytes:self.bufferOnHeap fromOffset:(long long)self.assetByteOffset length:SFAMaxBufferLength error:&err];
                    }
                    else {
#endif
                    bytesRead = [self.fileStream read:self.bufferOnHeap maxLength:SFAMaxBufferLength];
#if TARGET_OS_IPHONE
                }
#endif

                    if (err || bytesRead < 0) {
                        [self cleanUp];
                    }
                    else if (bytesRead != 0 || bytesReadFromAsset != 0) {
                        self.bufferOffset = 0;
                        if (bytesRead != 0) {
                            self.bufferLimit = (NSUInteger)bytesRead;
                        }
                        else {
                            self.assetByteOffset += bytesReadFromAsset;
                            self.bufferLimit = bytesReadFromAsset;
                        }
                    }
                    else {
                        // If we hit the end of the file, transition to sending the
                        // suffix.
                        if (self.fileStream) {
                            [self.fileStream close];
                            self.fileStream = nil;
                        }
                        else {
                            self.assetDataRead = YES;
                        }
                        assert(self.bufferOnHeap != NULL);
                        free(self.bufferOnHeap);
                        self.bufferOnHeap = NULL;
                        self.buffer = [self.bodySuffixData bytes];
                        
                        self.bufferOffset = 0;
                        self.bufferLimit = [self.bodySuffixData length];
                    }
                }
                
                // If we've failed to produce any more data, we close the stream
                // to indicate to NSURLConnection that we're all done.  We only do
                // this if producerStream is still valid to avoid running it in the
                // file read error case.
                
                if ((self.bufferOffset == self.bufferLimit) && (self.producerStream != nil)) {
                    [self cleanUp];
                }
            }
            // Send the next chunk of data in our buffer.
            
            if (self.buffer && self.bufferOffset != self.bufferLimit) {
                NSInteger bytesWritten;
                bytesWritten = [self.producerStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
                if (bytesWritten <= 0) {
                    [self cleanUp];
                }
                else {
                    self.bufferOffset += (NSUInteger)bytesWritten;
                }
            }
        }
        break;
        
        case NSStreamEventErrorOccurred:
        {
            NSAssert(NO, @"producer stream error %@", [aStream streamError]);
            [self cleanUp];
        }
        break;
        
        case NSStreamEventEndEncountered:
        {
            [self cleanUp];
        }
        break;
        
        default:
        {
            assert(NO);
        }
        break;
    }
}

#pragma mark - Private Methods Other methods

- (void)initializeUploadSpecificationRequest:(SFUploadSpecification *)val {
    if (!self.prepared) {
        self.uploadSpecification = val;
        [self checkResumeAsync];
        self.prepared = YES;
    }
}

- (void)initializeBodyLength {
    NSString *fileName = self.uploadSpecificationRequest.fileName;
#if TARGET_OS_IPHONE
    ALAssetRepresentation *rep = self.asset.defaultRepresentation;
#endif
    if (fileName.length == 0) {
#if TARGET_OS_IPHONE
        ALAssetRepresentation *rep = self.asset.defaultRepresentation;
        if (self.asset) {
            fileName = rep.filename;
        }
        else {
#endif
        fileName = [self.fileHandler filePath].lastPathComponent;
#if TARGET_OS_IPHONE
    }
#endif
    }
    self.boundaryStr = [self generateBoundaryString];
    NSString *bodyPrefixStr = [NSString stringWithFormat:@"\r\n"
                               "--%@\r\n"
                               "Content-Disposition: form-data; "
                               "name=\"File1\"; filename=\"%@\"\r\n"
                               "\r\n",
                               self.boundaryStr, fileName];
    NSString *bodySuffixStr = [NSString stringWithFormat:@"\r\n"
                               "--%@--\r\n",
                               self.boundaryStr];
    self.bodyPrefixData = [bodyPrefixStr dataUsingEncoding:NSUTF8StringEncoding];
    self.bodySuffixData = [bodySuffixStr dataUsingEncoding:NSUTF8StringEncoding];
    
    NSNumber *fileLengthNum;
#if TARGET_OS_IPHONE
    if (self.asset) {
        fileLengthNum = [NSNumber numberWithLongLong:rep.size];
    }
    else {
#endif
    fileLengthNum = [self.fileHandler fileSize];
#if TARGET_OS_IPHONE
}

#endif
    self.bodyLength = (unsigned long long)[self.bodyPrefixData length] + [fileLengthNum unsignedLongLongValue] + (unsigned long long)[self.bodySuffixData length];
}

- (void)initializeBodyLengthForTask:(SFACompositeUploaderTask *)task {
    [self initializeBodyLength];
    [task initializeProgressWithTotalBytes:(int64_t)self.bodyLength];
}

- (void)scheduleProducerStream {
    [self.producerStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.producerStream open];
}

- (void)scheduleProducerStreamAndRunLoop {
    @autoreleasepool
    {
        [self.producerStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.producerStream open];
        [[NSThread currentThread] setName:@"ShareFile Upload Thread"];
        // Current Runloop
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        while (self.producerStream) {
            @autoreleasepool
            {
                // Start the run loop but return after each source is handled.
                [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }
        // NSLog(@"Thread Ended");
    }
}

- (NSString *)generateBoundaryString {
    CFUUIDRef uuid;
    CFStringRef uuidStr;
    NSString *result;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSString stringWithFormat:@"%@", uuidStr];
    result = [result stringByReplacingOccurrencesOfString:@"-" withString:@""];
    result = [NSString stringWithFormat:@"%@-%@", SFAUpload, result];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

- (void)cleanUp {
    if (![[NSThread currentThread] isEqual:[SFASharedThreadManager sharedThread]]) {
        [self performSelector:@selector(cleanUp) onThread:[SFASharedThreadManager sharedThread] withObject:nil waitUntilDone:YES];
    }
    else {
        if (self.bufferOnHeap) {
            free(self.bufferOnHeap);
            self.bufferOnHeap = NULL;
        }
        self.buffer = NULL;
        self.bufferOffset = 0;
        self.bufferLimit = 0;
        
        if (self.producerStream != nil) {
            self.producerStream.delegate = nil;
            [self.producerStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [self.producerStream close];
            self.producerStream = nil;
        }
        self.consumerStream = nil;
        if (self.fileStream != nil) {
            [self.fileStream close];
        }
        self.assetByteOffset = 0;
        self.assetDataRead = NO;
    }
}

- (NSURLRequest *)needsRequestForURLSessionTaskUsingContextObject:(NSMutableDictionary *__autoreleasing *)contextObject {
    NSMutableDictionary *dict = (*contextObject) ? :[NSMutableDictionary dictionary];
    SFAuthenticationContext *authContext = [SFAUtils nilForNSNull:dict[SFAAuthContextKey]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[self chunkUriForStandardUploads] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:self.config.httpTimeout];
    authContext = [self.client.authHandler prepareRequest:request authContext:authContext interactiveHandler:nil];
    if (authContext) {
        [dict setObject:authContext forKey:SFAAuthContextKey];
    }
    [request setHTTPMethod:SFAPost];
    *contextObject = dict;
    return [request copy];
}

- (void)dealloc {
    [self cleanUp];
}

@end

#pragma clang diagnostic pop
