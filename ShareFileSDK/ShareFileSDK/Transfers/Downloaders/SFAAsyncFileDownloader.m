#import "SFAAsyncFileDownloaderProtected.h"
#import "SFAAsyncRequestProviderProtected.h"
#import "SFABaseRequestProviderProtected.h"
#import "SFADownloadTask.h"
#import "SFAUtils.h"
#import <objc/runtime.h>
#import "SFAURLSessionTaskRuntimeAssociationKeys.h"
#import "SFAuthenticationContext.h"

@interface SFAAsyncFileDownloader ()

@property (nonatomic) BOOL defaultURLSessionTaskHttpDelegate;

@end

@implementation SFAAsyncFileDownloader

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (id <SFADownloadTask> )downloadAsyncToFileHandle:(NSFileHandle *)fileHandle withTransferMetadata:(NSDictionary *)transferMetadata callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback progressCallback:(SFATransferTaskProgressCallback)progressCallback {
    return [self downloadAsyncToFileHandle:fileHandle withTransferMetadata:transferMetadata callbackQueue:callbackQueue completionCallback:completionCallback cancelCallback:cancelCallback progressCallback:progressCallback dataReceivedCallback:nil];
}

- (id <SFADownloadTask> )downloadAsyncToFileHandle:(NSFileHandle *)fileHandle withTransferMetadata:(NSDictionary *)transferMetadata callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback progressCallback:(SFATransferTaskProgressCallback)progressCallback dataReceivedCallback:(SFADownloadTaskDataReceivedCallback)dataReceivedCallback {
    if (self.defaultURLSessionTaskHttpDelegate) {
        return nil;
    }
    SFApiQuery *query = [self createDownloadQuery];
    SFADownloadTask *task = [[SFADownloadTask alloc] initWithQuery:query fileHandle:fileHandle transferMetaData:transferMetadata transferSize:self.item.FileSizeBytes.unsignedIntegerValue delegate:self contextObject:nil callbackQueue:callbackQueue client:self.sfaClient];
    task.completionCallback = completionCallback;
    task.cancelCallback = cancelCallback;
    task.progressCallback = progressCallback;
    task.dataReceivedCallback = dataReceivedCallback;
    [self.sfaClient executeTask:task];
    return task;
}

- (NSURLSessionDownloadTask *)downloadBackgroundAsyncWithTaskDelegate:(id <SFAURLSessionTaskDelegate> )delegate {
    if (self.defaultURLSessionTaskHttpDelegate) {
        return nil;
    }
    SFABackgroundSessionManager *sessionManager = self.sfaClient.backgroundSessionManager;
    NSURLSession *session = sessionManager.backgroundSession;
    NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)[self URLSession:session taskNeedsNewTask:nil];
    [sessionManager addDelegate:delegate forSession:session andTaskWithIdentifier:downloadTask.taskIdentifier];
    id <SFAURLSessionTaskHttpDelegate> httpDelegate = objc_getAssociatedObject(downloadTask, [kSFAURLSessionTaskRuntimeAssociationHttpDelegate UTF8String]);
    NSMutableDictionary *contextObject = objc_getAssociatedObject(downloadTask, [kSFAURLSessionTaskRuntimeAssociationContextObject UTF8String]);
    [sessionManager notifiyDelegateUpdateForURLSession:session task:downloadTask delegate:httpDelegate];
    [sessionManager notifyContextUpdateForSession:session task:downloadTask contextObject:contextObject];
    [downloadTask resume];
    return downloadTask;
}

#pragma mark - Internal

- (instancetype)initWithItem:(SFIItem *)item withSFAClient:(SFAClient *)client andDownloaderConfig:(SFADownloaderConfig *)config {
    self = [super initWithSFAClient:client];
    if (self) {
        self.item = item;
        self.config = config ? config :[[SFADownloaderConfig alloc] init];
    }
    return self;
}

+ (instancetype)downloaderForURLSessionTaskDefaultHTTPDelegateWithClient:(SFAClient *)client {
    SFAAsyncFileDownloader *downloader = [[[self class] alloc] initWithItem:nil withSFAClient:client andDownloaderConfig:nil];
    downloader.defaultURLSessionTaskHttpDelegate = YES;
    return downloader;
}

+ (instancetype)downloaderForURLSessionTaskHTTPDelegateWithItem:(SFIItem *)item client:(SFAClient *)client config:(SFADownloaderConfig *)config {
    return [[[self class] alloc] initWithItem:item withSFAClient:client andDownloaderConfig:config];
}

#pragma mark - Protected

- (SFApiQuery *)createDownloadQuery {
    SFApiQuery *downloadQuery = nil;
    
    if (self.config.shareURL) {
        downloadQuery = [self.sfaClient.shares downloadWithAliasWithShareUrl:self.config.shareURL aliasid:self.config.shareAliasId itemId:self.item.Id andRedirect:@YES];
    }
    else {
        downloadQuery = [[SFApiQuery alloc] initWithClient:self.sfaClient];
        [downloadQuery addUrl:self.item.url];
        [downloadQuery setAction:SFADownload];
    }
    
    if (self.config && self.config.rangeRequest) {
        if (!self.config.rangeRequest.end) {
            [downloadQuery addHeaderWithKey:SFARange value:[NSString stringWithFormat:@"%@=%llu", SFABytes, self.config.rangeRequest.begin.unsignedLongLongValue]];
        }
        else {
            [downloadQuery addHeaderWithKey:SFARange value:[NSString stringWithFormat:@"%@=%llu-%llu", SFABytes, self.config.rangeRequest.begin.unsignedLongLongValue, self.config.rangeRequest.end.unsignedLongLongValue]];
        }
    }
    return downloadQuery;
}

- (id)handleSuccessResponseForQuery:(id <SFAQuery> )query apiRequest:(SFAApiRequest *)apiRequest httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)container error:(SFAError **)error {
    return nil;
}

#pragma mark - SFAURLSessionTaskHttpDelegate

- (NSURLSessionTask *)URLSession:(NSURLSession *)session taskNeedsNewTask:(NSURLSessionTask *)task {
    NSMutableDictionary *contextObject;
    if (task) {
        contextObject = objc_getAssociatedObject(task, [kSFAURLSessionTaskRuntimeAssociationContextObject UTF8String]);
    }
    NSURLRequest *request = nil;
    SFAuthenticationContext *authContext = contextObject[SFAAuthContextKey];
    if (!authContext) {
        authContext = [SFAuthenticationContext new];
        authContext.backgroundRequest = YES;
    }
    if (!contextObject) {
        contextObject = [NSMutableDictionary new];
    }
    
    if (self.item) {
        contextObject[SFAAuthContextKey] = authContext;
        SFApiQuery *query = [self createDownloadQuery];
        request = [self _task:nil needsRequestForQuery:query usingContextObject:&contextObject];
    }
    else {
        request = task.originalRequest;
        NSMutableURLRequest *mRequest = [request mutableCopy];
        authContext = [self.sfaClient.authHandler prepareRequest:mRequest authContext:authContext interactiveHandler:nil];
        contextObject[SFAAuthContextKey] = authContext;
        request = [mRequest copy];
    }
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];
    objc_setAssociatedObject(downloadTask, [kSFAURLSessionTaskRuntimeAssociationContextObject UTF8String], contextObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(downloadTask, [kSFAURLSessionTaskRuntimeAssociationHttpDelegate UTF8String], self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return downloadTask;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task receivedAuthChallenge:(NSURLAuthenticationChallenge *)challenge httpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary *__autoreleasing *)contextObject completionHandler:(void (^)(SFIURLAuthChallengeDisposition, NSURLCredential *))completionHandler {
    [self _task:task receivedAuthChallenge:challenge httpRequestResponseDataContainer:httpRequestResponseDataContainer usingContextObject:contextObject completionHandler:completionHandler];
}

- (SFAHttpHandleResponseReturnData *)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needsResponseHandlingForHttpRequestResponseDataContainer:(SFAHttpRequestResponseDataContainer *)httpRequestResponseDataContainer usingContextObject:(NSMutableDictionary *__autoreleasing *)contextObject {
    id <SFAQuery> query = [self createDownloadQuery];
    return [self _task:task needsResponseHandlingForQuery:query httpRequestResponseDataContainer:httpRequestResponseDataContainer usingContextObject:contextObject];
}

#pragma mark - HttpTaskDelegate

// Handle nil task as its called for SFAURLSessionTaskHttpDelegate
- (NSURLRequest *)task:(SFAHttpTask *)task needsRequestForQuery:(id <SFAQuery> )query usingContextObject:(NSMutableDictionary **)contextObject {
    // Fetch data from context
    NSMutableDictionary *dict = (*contextObject) ? :[NSMutableDictionary dictionary];
    SFAEventHandlerResponse *action = [SFAUtils nilForNSNull:dict[SFAAction]];
    int retryCount = ((NSNumber *)[SFAUtils nilForNSNull:dict[SFARetryCount]]).intValue;
    SFAuthenticationContext *authContext = [SFAUtils nilForNSNull:dict[SFAAuthContextKey]];
    
    // Make ApiRequest
    SFAApiRequest *apiRequest = [SFAApiRequest apiRequestFromQuery:(SFAQueryBase *)query];
    if (action != nil && action.redirection != nil && action.redirection.Body != nil) {
        apiRequest.composed = YES;
        apiRequest.url = action.redirection.Uri;
        apiRequest.body = action.redirection.Body;
        apiRequest.httpMethod = action.redirection.Method ? action.redirection.Method : SFAGet;
    }
    action = nil;
    NSMutableURLRequest *httpRequest = [[self buildRequest:apiRequest] copy];
    
    authContext = [self.sfaClient.authHandler prepareRequest:httpRequest authContext:authContext interactiveHandler:task.interactiveHandler];
    
    // Put data back in context
    [dict setObject:[NSNumber numberWithInt:retryCount] forKey:SFARetryCount];
    [dict setObject:[SFAUtils nullForNil:action] forKey:SFAAction];
    [dict setObject:apiRequest forKey:SFAApiRequestString];
    [dict setObject:[SFAUtils nullForNil:authContext] forKey:SFAAuthContextKey];
    
    *contextObject = dict;
    return httpRequest;
}

@end
