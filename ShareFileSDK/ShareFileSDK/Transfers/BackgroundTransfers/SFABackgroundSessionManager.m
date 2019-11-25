#import "SFAURLSessionTaskRuntimeAssociationKeys.h"
#import <objc/runtime.h>
#import "NSHTTPURLResponse+sfapi.h"
#import "SFABaseAuthHandler.h"
#import "SFAuthenticationContext.h"
#import "SFAAsyncFileDownloaderInternal.h"
#import "SFAAsyncStandardFileUploader.h"
#import "SFABackgroundSessionManagerInternal.h"

@interface SFABackgroundSessionManager () <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>

@property (weak, nonatomic, readwrite) SFAClient *client;
@property (strong, atomic, readwrite) NSURLSession *backgroundSession;

@end

@implementation SFABackgroundSessionManager

@synthesize backgroundSession = _backgroundSession;

- (NSURLSession *)backgroundSessionInternal {
    // Thread safe access to _backgroundSession, without setup.
    @synchronized(self)
    {
        return _backgroundSession;
    }
}

- (void)_setBackgroundSession:(NSURLSession *)backgroundSession {
    // Thread safe internal setter for _backgroundSession
    @synchronized(self)
    {
        _backgroundSession = backgroundSession;
    }
}

- (NSURLSession *)backgroundSession {
    // Thread safe access to _backgroundSession
    @synchronized(self)
    {
        if (!_backgroundSession) {
            [self setupBackgroundSession];
        }
        return _backgroundSession;
    }
}

- (void)setBackgroundSession:(NSURLSession *)backgroundSession {
    // Thread safe access to _backgroundSession.
    @synchronized(self)
    {
        if (_backgroundSession) {
            [_backgroundSession finishTasksAndInvalidate];
        }
        [self _setBackgroundSession:backgroundSession];
    }
}

- (NSMutableDictionary *)completionHandlers {
    // No need for thread safe init, since always accessed in a thread-safe way.
    if (!_completionHandlers) {
        _completionHandlers = [NSMutableDictionary new];
    }
    return _completionHandlers;
}

- (NSMutableDictionary *)allTaskSpecificDelegates {
    // No need for thread safe init, since always accessed in a thread-safe way.
    if (!_allTaskSpecificDelegates) {
        _allTaskSpecificDelegates = [NSMutableDictionary new];
    }
    return _allTaskSpecificDelegates;
}

- (instancetype)initWithClient:(SFAClient *)client {
    self = [super init];
    if (self) {
        NSAssert(client != nil, @"client can not be nil");
        self.client = client;
        self.configurationForNewBackgroundSession = [SFABackgroundSessionConfiguration new];
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (BOOL)hasBackgroundSession {
    return [self backgroundSessionInternal] != nil;
}

- (void)setupBackgroundSession {
    [self setupBackgroundSessionWithCompletionHandler:nil];
}

- (void)setupBackgroundSessionWithCompletionHandler:(void (^)(void))completionHandler {
    // This @synchronized is needed to prevent against a rare scenerio.
    // Two threads are simultaneously trying to setup.
    // Thread A sets up first.
    // When thread B sets up it will also invalidate session of thread A.
    // If invalidation delegate for thread A is then called before thread A is stored.
    // The completion handler of thread A's session will be stored needlessly.
    NSURLSessionConfiguration *configuration = [self backgroundSessionConfiguration];
    NSURLSession *backgroundSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    @synchronized(self)
    {
        self.backgroundSession = backgroundSession;
        [self setForBackgroundSession:backgroundSession completionHandler:completionHandler];
    }
}

- (void)setCompletionHandlerForCurrentBackgroundSession:(void (^)(void))completionHandler;
{
    // This @synchronized is needed so that delegate for invalidation is not executed,
    // while completion handler is being added. Both functions are synchronized.
    // But in-between call, another thread can get through. So needless object will be stored.
    @synchronized(self)
    {
        NSURLSession *session = [self backgroundSessionInternal];
        [self setForBackgroundSession:session completionHandler:completionHandler];
    }
}

- (void)setForBackgroundSession:(NSURLSession *)session completionHandler:(void (^)(void))completionHandler;
{
    if (!session) {
        return;
    }
    // This @synchronized is needed so that thread-unsafe data structure is accessed in a thread safe way.
    @synchronized(self)
    {
        if (completionHandler) {
            self.completionHandlers[session.configuration.identifier] = completionHandler;
        }
        else {
            [self.completionHandlers removeObjectForKey:session.configuration.identifier];
        }
    }
}

- (NSURLSessionConfiguration *)backgroundSessionConfiguration {
    NSURLSessionConfiguration *configuration = nil;
    if ([[NSURLSessionConfiguration class] respondsToSelector:@selector(backgroundSessionConfigurationWithIdentifier:)]) {
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:self.configurationForNewBackgroundSession.identifier];
    }
    else {
        configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:self.configurationForNewBackgroundSession.identifier];
    }
    if ([configuration respondsToSelector:@selector(setSharedContainerIdentifier:)]) {
        configuration.sharedContainerIdentifier = self.configurationForNewBackgroundSession.sharedContainerIdentifier;
    }
    return configuration;
}

- (void)addDelegate:(id <SFAURLSessionTaskDelegate> )delegate forCurrentBackgroundSessionAndTaskWithIdentifier:(NSUInteger)identifier {
    // This @synchronized is needed so that delegate for invalidation is not executed,
    // while completion delegate is being added. Both functions are synchronized.
    // But in-between call, another thread can get through. So needless object will be stored.
    @synchronized(self)
    {
        NSURLSession *currentSession = [self backgroundSessionInternal];
        [self addDelegate:delegate forSession:currentSession andTaskWithIdentifier:identifier];
    }
}

- (void)addDelegate:(id <SFAURLSessionTaskDelegate> )delegate forSession:(NSURLSession *)session andTaskWithIdentifier:(NSUInteger)identifier {
    if (!session) {
        return;
    }
    // This @synchronized is needed so that thread-unsafe data structure is accessed in a thread safe way.
    @synchronized(self)
    {
        NSString *sessionKey = session.configuration.identifier;
        if (delegate) {
            NSMapTable *taskSpecificDelegatesForSession = [self.allTaskSpecificDelegates objectForKey:sessionKey];
            if (!taskSpecificDelegatesForSession) {
                taskSpecificDelegatesForSession = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
                [self.allTaskSpecificDelegates setObject:taskSpecificDelegatesForSession forKey:sessionKey];
            }
            [taskSpecificDelegatesForSession setObject:delegate forKey:[self keyFromTaskIdentifier:identifier]];
        }
        else {
            [self removeDelegateForSession:session andTaskWithIdentifier:identifier];
        }
    }
}

- (void)removeDelegateForCurrentBackgroundSessionAndTaskWithIdentifier:(NSUInteger)identifier {
    // Here @synchronized block is not needed here, as both functions are thread-safe and
    // there is no side effect of thread getting through in-between calls.
    NSURLSession *currentSession = [self backgroundSessionInternal];
    [self removeDelegateForSession:currentSession andTaskWithIdentifier:identifier];
}

- (void)removeDelegateForSession:(NSURLSession *)session andTaskWithIdentifier:(NSUInteger)identifier {
    if (!session) {
        return;
    }
    // This @synchronized is needed so that thread-unsafe data structure is accessed in a thread safe way.
    @synchronized(self)
    {
        NSString *sessionKey = session.configuration.identifier;
        NSMapTable *taskSpecificDelegatesForSession = [self.allTaskSpecificDelegates objectForKey:sessionKey];
        [taskSpecificDelegatesForSession removeObjectForKey:[self keyFromTaskIdentifier:identifier]];
    }
}

- (void)removeAllTaskSpecificDelegatesForCurrentBackgroundSession {
    // Here @synchronized block is not needed here, as both functions are thread-safe and
    // there is no side effect of thread getting through in-between calls.
    NSURLSession *currentSession = [self backgroundSessionInternal];
    [self removeAllTaskSpecificDelegatesForSession:currentSession];
}

- (void)removeAllTaskSpecificDelegatesForSession:(NSURLSession *)session {
    if (!session) {
        return;
    }
    // This @synchronized is needed so that thread-unsafe data structure is accessed in a thread safe way.
    @synchronized(self)
    {
        NSString *sessionKey = session.configuration.identifier;
        [self.allTaskSpecificDelegates removeObjectForKey:sessionKey];
    }
}

- (id <SFAURLSessionTaskDelegate> )delegateForCurrentBackgroundSessionAndTaskWithIdentifier:(NSUInteger)identifier {
    // Here @synchronized block is not needed here, as both functions are thread-safe and
    // there is no side effect of thread getting through in-between calls.
    NSURLSession *currentSession = [self backgroundSessionInternal];
    return [self delegateForSession:currentSession andTaskWithIdentifier:identifier];
}

- (id <SFAURLSessionTaskDelegate> )delegateForSession:(NSURLSession *)session andTaskWithIdentifier:(NSUInteger)identifier {
    if (!session) {
        return nil;
    }
    // This @synchronized is needed so that thread-unsafe data structure is accessed in a thread safe way.
    @synchronized(self)
    {
        NSString *sessionKey = session.configuration.identifier;
        NSMapTable *taskSpecificDelegatesForSession = [self.allTaskSpecificDelegates objectForKey:sessionKey];
        return [taskSpecificDelegatesForSession objectForKey:[self keyFromTaskIdentifier:identifier]];
    }
}

- (NSString *)keyFromTaskIdentifier:(NSUInteger)identifier {
    return [NSString stringWithFormat:@"_%lu", (unsigned long)identifier];
}

#pragma mark - URLSessionDelegate

#if TARGET_OS_IPHONE
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
	void (^completionHandler)(void) = nil;
    // Thread-safe access of thread-unsafe data structure.
    @synchronized(self)
    {
        completionHandler = self.completionHandlers[session.configuration.identifier];
    }
    [self setForBackgroundSession:session completionHandler:nil];
    if (completionHandler) {
        completionHandler();
    }
}
#endif

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    // We do not want any other thread to be setting up while, this thread
    // is invalidating.
    @synchronized(self)
    {
        if ([session isEqual:[self backgroundSessionInternal]]) {
            [self _setBackgroundSession:nil];
        }
    }
    [self removeAllTaskSpecificDelegatesForSession:session];
    [self setForBackgroundSession:session completionHandler:nil];
}

#pragma mark - URLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    SFAError *otherError = objc_getAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationOtherError UTF8String]);
    if (!error && !otherError) {
        id <SFAURLSessionTaskHttpDelegate> httpDelegate = objc_getAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationHttpDelegate UTF8String]);
        BOOL hasDelegate = httpDelegate != nil;
        if (!hasDelegate) { // Try to get from user
            hasDelegate = [self tryToGetRuntimeAssociationsFromUserForURLSession:session task:task];
        }
        // check again.
        if (!hasDelegate) { // we do not have reference to the delegate and hence we need to have a default handling
            [self defaultResponseHandlingForSession:session task:task];
        }
        else {
            [self nonDefaultResponseHandlingForSession:session task:task];
        }
    }
    else if (error) {
        SFAError *sfaError = [SFAError errorWithMessage:@"Background URL Session Task failed with error" type:SFAErrorTypeBackgroundURLSessionTaskFailWithError domain:@"" code:0 userInfo:@{ @"error" : error }];
        [self genericResponseHandlingForSession:session task:task returnValue:sfaError];
    }
    else {
        [self genericResponseHandlingForSession:session task:task returnValue:otherError];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    id <SFAURLSessionTaskHttpDelegate> httpDelegate = objc_getAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationHttpDelegate UTF8String]);
    BOOL hasDelegate = httpDelegate != nil;
    if (!hasDelegate) { // Try to get from user
        hasDelegate = [self tryToGetRuntimeAssociationsFromUserForURLSession:session task:task];
    }
    // check again.
    if (!hasDelegate) { // we do not have reference to the delegate and hence we need to have a default handling
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
    else {
        [self nonDefaultAuthHandlingForSession:session task:task challenge:challenge completionHandler:completionHandler];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    id <SFAURLSessionTaskDelegate> univDelegate = self.universalTaskDelegate;
    id <SFAURLSessionTaskDelegate> taskSpecificDelegate = [self delegateForSession:session andTaskWithIdentifier:task.taskIdentifier];
    BOOL didHandle = NO;
    if (taskSpecificDelegate && [taskSpecificDelegate respondsToSelector:@selector(URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)]) {
        didHandle = [taskSpecificDelegate URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
    }
    if (!didHandle && univDelegate && [univDelegate respondsToSelector:@selector(URLSession:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:)]) {
        [univDelegate URLSession:session task:task didSendBodyData:bytesSent totalBytesSent:totalBytesSent totalBytesExpectedToSend:totalBytesExpectedToSend];
    }
}

#pragma mark - URLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    id <SFAURLSessionTaskDelegate> univDelegate = self.universalTaskDelegate;
    id <SFAURLSessionTaskDelegate> taskSpecificDelegate = [self delegateForSession:session andTaskWithIdentifier:downloadTask.taskIdentifier];
    BOOL didHandle = NO;
    if (taskSpecificDelegate && [taskSpecificDelegate respondsToSelector:@selector(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        didHandle = [taskSpecificDelegate URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
    if (!didHandle && univDelegate && [univDelegate respondsToSelector:@selector(URLSession:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [univDelegate URLSession:session downloadTask:downloadTask didWriteData:bytesWritten totalBytesWritten:totalBytesWritten totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL {
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)downloadTask.response;
    if ([response isSuccessCode]) {
        id <SFAURLSessionTaskDelegate> univDelegate = self.universalTaskDelegate;
        id <SFAURLSessionTaskDelegate> taskSpecificDelegate = [self delegateForSession:session andTaskWithIdentifier:downloadTask.taskIdentifier];
        NSURL *destinationURL = nil;
        if (taskSpecificDelegate && [taskSpecificDelegate respondsToSelector:@selector(URLSession:downloadTaskNeedsDestinationFileURL:)]) {
            destinationURL = [taskSpecificDelegate URLSession:session downloadTaskNeedsDestinationFileURL:downloadTask];
        }
        if (!destinationURL && univDelegate && [univDelegate respondsToSelector:@selector(URLSession:downloadTaskNeedsDestinationFileURL:)]) {
            destinationURL = [univDelegate URLSession:session downloadTaskNeedsDestinationFileURL:downloadTask];
        }
        if (destinationURL) {
            NSError *errorCopy;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *destinationPath = [[NSString alloc] initWithUTF8String:destinationURL.fileSystemRepresentation];
            if ([fileManager fileExistsAtPath:destinationPath]) {
                [fileManager removeItemAtPath:destinationPath error:&errorCopy];
            }
            BOOL success = NO;
            if (!errorCopy) {
                success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&errorCopy];
            }
            if (!success || errorCopy) {
                SFAError *error = [SFAError errorWithMessage:@"Unable to copy file to destination" type:SFAErrorTypeFileCopyError];
                objc_setAssociatedObject(downloadTask, [kSFAURLSessionTaskRuntimeAssociationOtherError UTF8String], error, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            else {
                objc_setAssociatedObject(downloadTask, [kSFAURLSessionTaskRuntimeAssociationDestinationFileURL UTF8String], destinationURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
        else {
            SFAError *error = [SFAError errorWithMessage:@"No destination file url returned by delegate" type:SFAErrorTypeFileCopyError];
            objc_setAssociatedObject(downloadTask, [kSFAURLSessionTaskRuntimeAssociationOtherError UTF8String], error, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    NSMutableData *responseData = objc_getAssociatedObject(dataTask, [kSFAURLSessionTaskRuntimeAssociationResponseData UTF8String]);
    if (!responseData) {
        responseData = [NSMutableData new];
        objc_setAssociatedObject(dataTask, [kSFAURLSessionTaskRuntimeAssociationResponseData UTF8String], responseData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [responseData appendData:data];
}

#pragma mark - EOS

- (BOOL)tryToGetRuntimeAssociationsFromUserForURLSession:(NSURLSession *)session task:(NSURLSessionTask *)task {
    id <SFAURLSessionTaskDelegate> univDelegate = self.universalTaskDelegate;
    id <SFAURLSessionTaskDelegate> taskSpecificDelegate = [self delegateForSession:session andTaskWithIdentifier:task.taskIdentifier];
    BOOL didHandle = NO;
    id <SFAURLSessionTaskHttpDelegate> returnedDelegate = nil;
    NSMutableDictionary *returnedContextObject = nil;
    if (taskSpecificDelegate && [taskSpecificDelegate respondsToSelector:@selector(URLSession:task:needsHttpDelegate:andNeedsContextObject:)]) {
        didHandle = [taskSpecificDelegate URLSession:session task:task needsHttpDelegate:&returnedDelegate andNeedsContextObject:&returnedContextObject];
    }
    if (!didHandle && univDelegate && [univDelegate respondsToSelector:@selector(URLSession:task:needsHttpDelegate:andNeedsContextObject:)]) {
        didHandle = [univDelegate URLSession:session task:task needsHttpDelegate:&returnedDelegate andNeedsContextObject:&returnedContextObject];
    }
    // Make default delegate
    BOOL shouldNotifyDelegate = NO;
    if (!didHandle || (returnedDelegate == nil)) {
        if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
            // Create a downloader with whatever information we have at hand.
            returnedDelegate = [SFAAsyncFileDownloader downloaderForURLSessionTaskDefaultHTTPDelegateWithClient:self.client];
            shouldNotifyDelegate = YES;
        }
        else if ([task isKindOfClass:[NSURLSessionUploadTask class]]) {
            // Create a uploader with what ever information we have at hand.
            returnedDelegate = [SFAAsyncStandardFileUploader uploaderForURLSessionTaskDefaultHTTPDelegateWithClient:self.client];
            shouldNotifyDelegate = YES;
        }
        else {
            NSAssert(NO, @"Unexpected kind of URL Session Task encountered");
            return NO;
        }
    }
    BOOL shouldNotifyContextObject = NO;
    if (!didHandle || returnedContextObject == nil) {
        SFAuthenticationContext *authContext = [SFABaseAuthHandler initializeContextFromExistingContext:nil];
        authContext.backgroundRequest = YES;
        returnedContextObject = [NSMutableDictionary new];
        returnedContextObject[SFAAuthContextKey] = authContext;
        shouldNotifyContextObject = YES;
    }
    objc_setAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationHttpDelegate UTF8String], returnedDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationContextObject UTF8String], returnedContextObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (shouldNotifyDelegate) {
        [self notifiyDelegateUpdateForURLSession:session task:task delegate:returnedDelegate];
    }
    if (shouldNotifyContextObject) {
        [self notifyContextUpdateForSession:session task:task contextObject:returnedContextObject];
    }
    return YES;
}

- (void)nonDefaultAuthHandlingForSession:(NSURLSession *)session task:(NSURLSessionTask *)task challenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler {
    NSMutableDictionary *contextObject = objc_getAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationContextObject UTF8String]);
    NSMutableDictionary *originalContextObject = contextObject;
    id <SFAURLSessionTaskHttpDelegate> httpDelegate = objc_getAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationHttpDelegate UTF8String]);
    NSData *responseData = [objc_getAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationResponseData UTF8String]) copy];
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:task.currentRequest response:(NSHTTPURLResponse *)task.response data:responseData error:task.error];
    // Call out so we can parse this challenge
    __weak SFABackgroundSessionManager *weakSelf = self;
    [httpDelegate          URLSession:session
                                 task:task
                receivedAuthChallenge:challenge
     httpRequestResponseDataContainer:container
                   usingContextObject:&contextObject
                    completionHandler: ^(SFURLAuthChallengeDisposition disp, NSURLCredential *cred) {
         if (![originalContextObject isEqual:contextObject]) {
             objc_setAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationContextObject UTF8String], contextObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
             [weakSelf notifyContextUpdateForSession:session task:task contextObject:contextObject];
         }
         switch (disp) {
             case SFURLAuthChallengeUseCredential:
                 completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
                 break;
                 
             case SFURLAuthChallengeCancelAuthenticationChallenge:
                 completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
                 break;
                 
             default:
                 completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
                 break;
         }
     }];
}

- (void)nonDefaultResponseHandlingForSession:(NSURLSession *)session task:(NSURLSessionTask *)task {
    NSMutableDictionary *contextObject = objc_getAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationContextObject UTF8String]);
    NSMutableDictionary *originalContextObject = contextObject;
    id <SFAURLSessionTaskHttpDelegate> httpDelegate = objc_getAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationHttpDelegate UTF8String]);
    NSData *responseData = [objc_getAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationResponseData UTF8String]) copy];
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:task.currentRequest response:(NSHTTPURLResponse *)task.response data:responseData error:task.error];
    
    SFAHttpHandleResponseReturnData *data = [httpDelegate URLSession:session task:task needsResponseHandlingForHttpRequestResponseDataContainer:container usingContextObject:&contextObject];
    
    if (![originalContextObject isEqual:contextObject]) {
        objc_setAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationContextObject UTF8String], contextObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self notifyContextUpdateForSession:session task:task contextObject:contextObject];
    }
    if (data.responseAction == SFAHttpHandleResponseActionReExecute) {
        NSURLSessionTask *newTask = [httpDelegate URLSession:session taskNeedsNewTask:task];
        if (newTask) {
            [self notifiyNewTaskForURLSession:session task:task newTask:newTask];
            id <SFAURLSessionTaskHttpDelegate> httpDelegate = objc_getAssociatedObject(newTask, [kSFAURLSessionTaskRuntimeAssociationHttpDelegate UTF8String]);
            NSMutableDictionary *contextObject = objc_getAssociatedObject(newTask, [kSFAURLSessionTaskRuntimeAssociationContextObject UTF8String]);
            [self notifiyDelegateUpdateForURLSession:session task:newTask delegate:httpDelegate];
            [self notifyContextUpdateForSession:session task:newTask contextObject:contextObject];
            [newTask resume];
            //[self defaultResponseHandlingForSession:session task:task error:error];
        }
        else {
            SFAError *error = [SFAError errorWithMessage:@"Could not create new URLSessionTask" type:SFAErrorTypeUnableToCreateNewTaskForExistingURLSessionTask];
            [self genericResponseHandlingForSession:session task:task returnValue:error];
        }
    }
    else if (data.responseAction == SFAHttpHandleResponseActionAsyncCallback) {
        NSAssert(NO, @"Response Action %ld is not supported for background requests.", (long)SFAHttpHandleResponseActionAsyncCallback);
    }
    else {
        [self genericResponseHandlingForSession:session task:task returnValue:data.returnValue];
    }
}

- (void)defaultResponseHandlingForSession:(NSURLSession *)session task:(NSURLSessionTask *)task {
    id returnValue = nil;
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    if (![response isSuccessCode]) {
        returnValue = [SFAError errorWithMessage:@"Background task failed non-success HTTP status code" type:SFAErrorTypeUnknownError];
    }
    [self genericResponseHandlingForSession:session task:task returnValue:returnValue];
}

- (void)genericResponseHandlingForSession:(NSURLSession *)session task:(NSURLSessionTask *)task returnValue:(id)returnValue {
    NSData *responseData = [objc_getAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationResponseData UTF8String]) copy];
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:task.currentRequest response:(NSHTTPURLResponse *)task.response data:responseData error:task.error];
    id retVal = nil;
    SFAError *sfaError = nil;
    NSDictionary *additionalInfo = @{ kSFAURLSessionTaskDelegateAdditionalInfoHttpRequestResponseDataContainer : container };
    if ([returnValue isKindOfClass:[SFAError class]]) {
        sfaError = returnValue;
    }
    else if (returnValue != nil) {
        retVal = returnValue;
    }
    else if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
        NSURL *destinationFileURL = [objc_getAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationDestinationFileURL UTF8String]) copy];
        if (destinationFileURL) {
            retVal = destinationFileURL;
        }
    }
    id <SFAURLSessionTaskDelegate> univDelegate = self.universalTaskDelegate;
    id <SFAURLSessionTaskDelegate> taskSpecificDelegate = [self delegateForSession:session andTaskWithIdentifier:task.taskIdentifier];
    BOOL didHandle = NO;
    if (taskSpecificDelegate) {
        didHandle = [taskSpecificDelegate URLSession:session task:task didCompleteWithReturnValue:retVal error:sfaError additionalInfo:additionalInfo];
    }
    if (!didHandle && univDelegate) {
        [univDelegate URLSession:session task:task didCompleteWithReturnValue:retVal error:sfaError additionalInfo:additionalInfo];
    }
    [session finishTasksAndInvalidate];
}

- (void)notifyContextUpdateForSession:(NSURLSession *)session task:(NSURLSessionTask *)task contextObject:(NSMutableDictionary *)contextObject {
    id <SFAURLSessionTaskDelegate> univDelegate = self.universalTaskDelegate;
    id <SFAURLSessionTaskDelegate> taskSpecificDelegate = [self delegateForSession:session andTaskWithIdentifier:task.taskIdentifier];
    BOOL didHandle = NO;
    if (taskSpecificDelegate && [taskSpecificDelegate respondsToSelector:@selector(URLSession:task:willUseContextObject:)]) {
        didHandle = [taskSpecificDelegate URLSession:session task:task willUseContextObject:contextObject];
    }
    if (!didHandle && univDelegate && [univDelegate respondsToSelector:@selector(URLSession:task:willUseContextObject:)]) {
        [univDelegate URLSession:session task:task willUseContextObject:contextObject];
    }
}

- (void)notifiyDelegateUpdateForURLSession:(NSURLSession *)session task:(NSURLSessionTask *)task delegate:(id <SFAURLSessionTaskHttpDelegate> )httpDelegate {
    id <SFAURLSessionTaskDelegate> univDelegate = self.universalTaskDelegate;
    id <SFAURLSessionTaskDelegate> taskSpecificDelegate = [self delegateForSession:session andTaskWithIdentifier:task.taskIdentifier];
    BOOL didHandle = NO;
    if (taskSpecificDelegate && [taskSpecificDelegate respondsToSelector:@selector(URLSession:task:hasHttpDelegate:)]) {
        didHandle = [taskSpecificDelegate URLSession:session task:task hasHttpDelegate:httpDelegate];
    }
    if (!didHandle && univDelegate && [univDelegate respondsToSelector:@selector(URLSession:task:hasHttpDelegate:)]) {
        [univDelegate URLSession:session task:task hasHttpDelegate:httpDelegate];
    }
}

- (void)notifiyNewTaskForURLSession:(NSURLSession *)session task:(NSURLSessionTask *)task newTask:(NSURLSessionTask *)newTask {
    id <SFAURLSessionTaskDelegate> univDelegate = self.universalTaskDelegate;
    id <SFAURLSessionTaskDelegate> taskSpecificDelegate = [self delegateForSession:session andTaskWithIdentifier:task.taskIdentifier];
    BOOL didHandle = NO;
    if (taskSpecificDelegate && [taskSpecificDelegate respondsToSelector:@selector(URLSession:task:willRetryWithNewTask:)]) {
        didHandle = [taskSpecificDelegate URLSession:session task:task willRetryWithNewTask:newTask];
    }
    if (!didHandle && univDelegate && [univDelegate respondsToSelector:@selector(URLSession:task:willRetryWithNewTask:)]) {
        [univDelegate URLSession:session task:task willRetryWithNewTask:newTask];
    }
}

@end
