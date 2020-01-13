#import "SFARequestProviderFactory.h"
#import "NSString+sfapi.h"
#import "SFAAsyncStandardFileUploader.h"
#import "SFAAsyncStreamedFileUploader.h"
#import "SFAAsyncThreadedFileUploader.h"
#import "SFAAsyncFileDownloaderInternal.h"

@interface SFAClient ()

@property (nonatomic, strong) SFARequestProviderFactory *requestProviderFactory;
@property (nonatomic, strong) NSMutableArray *internalChangeDomainHandlers;
@property (nonatomic, strong) NSMutableArray *internalErrorHandlers;

@end

@implementation SFAClient

@synthesize accounts = _accounts;
@synthesize accessControls = _accessControls;
@synthesize asyncOperations = _asyncOperations;
@synthesize capabilities = _capabilities;
@synthesize connectorGroups = _connectorGroups;
@synthesize favoriteFolders = _favoriteFolders;
@synthesize groups = _groups;
@synthesize metadata = _metadata;
@synthesize sessions = _sessions;
@synthesize shares = _shares;
@synthesize users = _users;
@synthesize items = _items;
@synthesize storageCenters = _storageCenters;
@synthesize zones = _zones;
@synthesize baseUrl = _baseUrl;
@synthesize configuration = _configuration;

- (NSArray *)changeDomainHandlers {
    @synchronized(self) // Do not want a read while some other thread is writing.
    {
        return [self.internalChangeDomainHandlers copy];
    }
}

- (NSArray *)errorHandlers {
    @synchronized(self) // Do not want a read while some other thread is writing.
    {
        return [self.internalErrorHandlers copy];
    }
}

@synthesize loggingProvider = _loggingProvider;
#if ShareFile
@synthesize configs = _configs;
@synthesize devices = _devices;
@synthesize fileLocks = _fileLocks;
@synthesize oAuthClients = _oAuthClients;
@synthesize zoneAuthentication = _zoneAuthentication;
#endif

@synthesize authHandler = _authHandler;

// It is safe to use a single NSOperationQueue object from multiple threads without creating additional locks to synchronize access to that object.
// So we do not need any sync block because as per documentation, NSOperationQueue is thread-safe, and sharedOperationQueue is also thread safe.
- (NSInteger)maxConcurrentTaskCount {
    return [[self class] sharedOperationQueue].maxConcurrentOperationCount;
}

- (void)setMaxConcurrentTaskCount:(NSInteger)maxConcurrentTaskCount {
    [[self class] sharedOperationQueue].maxConcurrentOperationCount = maxConcurrentTaskCount;
}

@synthesize backgroundSessionManager = _backgroundSessionManager;

- (instancetype)initWithBaseUrl:(NSString *)baseUrl andConfiguration:(SFAConfiguration *)configuration {
    self = [super init];
    if (self) {
        self.baseUrl = [NSURL URLWithString:baseUrl];
        self.configuration = configuration ? configuration :[SFAConfiguration defaultConfiguration];
        _accessControls = [[SFIAccessControlsEntity alloc] initWithClient:self];
        _asyncOperations = [[SFIAsyncOperationsEntity alloc] initWithClient:self];
        _capabilities = [[SFICapabilitiesEntity alloc] initWithClient:self];
        _connectorGroups = [[SFIConnectorGroupsEntity alloc] initWithClient:self];
        _favoriteFolders = [[SFIFavoriteFoldersEntity alloc] initWithClient:self];
        _groups = [[SFIGroupsEntity alloc] initWithClient:self];
        _metadata = [[SFIMetadataEntity alloc] initWithClient:self];
        _sessions = [[SFISessionsEntity alloc] initWithClient:self];
        _shares = [[SFISharesEntity alloc] initWithClient:self];
        _users = [[SFIUsersEntity alloc] initWithClient:self];
        _items = [[SFIItemsEntity alloc] initWithClient:self];
        _storageCenters = [[SFIStorageCentersEntity alloc] initWithClient:self];
        _zones = [[SFIZonesEntity alloc] initWithClient:self];
#if ShareFile
        _devices = [[SFIDevicesEntityInternal alloc] initWithClient:self];
        _configs = [[SFIConfigsEntityInternal alloc] initWithClient:self];
        _accounts = [[SFIAccountsEntityInternal alloc] initWithClient:self];
        _oAuthClients = [[SFIOAuthClientsEntityInternal alloc] initWithClient:self];
        _fileLocks = [[SFIFileLockEntityInternal alloc] initWithClient:self];
#else
        _accounts = [[SFIAccountsEntity alloc] initWithClient:self];
#endif
        [self registerRequestProviders];
        _loggingProvider = [[SFALoggingProvider alloc] initWithLogger:configuration.logger];
        _backgroundSessionManager = [[SFABackgroundSessionManager alloc] initWithClient:self];
    }
    return self;
}

- (id <SFATransferTask> )executeQueryAsync:(id <SFAQuery> )query {
    return [self executeQueryAsync:query callbackQueue:nil completionCallback:nil cancelCallback:nil];
}

- (id <SFATransferTask> )executeQueryAsync:(id <SFAQuery> )query callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback {
    return [self executeQueryAsync:query callbackQueue:callbackQueue completionCallback:completionCallback cancelCallback:nil];
}

- (id <SFATransferTask> )executeQueryAsync:(id <SFAQuery> )query callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback {
    return [self executeQueryAsync:query callbackQueue:callbackQueue interactiveHandler:nil completionCallback:completionCallback cancelCallback:cancelCallback];
}

- (id <SFATransferTask> )executeQueryAsync:(id <SFAQuery> )query callbackQueue:(NSOperationQueue *)callbackQueue interactiveHandler:(NSObject <SFAInteractiveAuthHandling> *)interactiveHandler completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback {
    NSAssert(query != nil, @"Passed parameter query can not be nil.");
    id <SFATransferTask> task = [self taskWithQuery:query callbackQueue:callbackQueue completionCallback:completionCallback cancelCallback:cancelCallback];
    task.interactiveHandler = interactiveHandler;
    [self executeTask:task];
    return task;
}

- (id <SFATransferTask> )taskWithQuery:(id <SFAQuery> )query callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback;
{
    id <SFATransferTask> task = [[self.requestProviderFactory asyncProvider] taskWithQuery:query callbackQueue:callbackQueue completionCallback:completionCallback cancelCallback:cancelCallback];
    return task;
}

- (void)executeTask:(id <SFATask> )task {
    NSAssert([task isKindOfClass:[NSOperation class]], @"Task should be subclass of NSOperation");
    [[[self class] sharedOperationQueue] addOperation:(NSOperation *)task];
}

+ (NSOperationQueue *)sharedOperationQueue {
    static NSOperationQueue *operationQueue = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        operationQueue = [NSOperationQueue new];
        operationQueue.name = @"SFAClient Shared Operation Queue";
    });
    return operationQueue;
}

- (void)addChangeDomainHandler:(SFAChangeDomainCallback)handler {
    @synchronized(self) // Do not want a change to array while some other thread is reading.
    {
        if (!self.internalChangeDomainHandlers) {
            self.internalChangeDomainHandlers = [[NSMutableArray alloc] init];
        }
        [self.internalChangeDomainHandlers addObject:handler];
    }
}

- (void)addErrorHandler:(SFAErrorCallback)handler {
    @synchronized(self) // Do not want a change to array while some other thread is reading.
    {
        if (!self.internalErrorHandlers) {
            self.internalErrorHandlers = [[NSMutableArray alloc] init];
        }
        [self.internalErrorHandlers addObject:handler];
    }
}

- (BOOL)removeChangeDomainHandler:(SFAChangeDomainCallback)handler {
    @synchronized(self) // Do not want a change to array while some other thread is reading.
    {
        if ([self.internalChangeDomainHandlers containsObject:handler]) {
            [self.internalChangeDomainHandlers removeObject:handler];
            return YES;
        }
        return NO;
    }
}

- (BOOL)removeErrorHandler:(SFAErrorCallback)handler {
    @synchronized(self) // Do not want a change to array while some other thread is reading.
    {
        if ([self.internalErrorHandlers containsObject:handler]) {
            [self.internalErrorHandlers removeObject:handler];
            return YES;
        }
        return NO;
    }
}

- (SFAEventHandlerResponse *)onErrorWithDataContainer:(SFAHttpRequestResponseDataContainer *)dataContainer retryCount:(int)retryCount {
    NSArray *handlers = self.errorHandlers;
    for (SFAErrorCallback handler in handlers) {
        SFAEventHandlerResponse *action = handler(dataContainer, retryCount);
        if (action.action != SFAEventHandlerResponseActionIgnore) {
            return action;
        }
    }
    return [SFAEventHandlerResponse failWithErrorEventResponseHandler];
}

- (SFAEventHandlerResponse *)onChangeDomainWithRequest:(NSURLRequest *)requestMessage redirection:(SFIRedirection *)redirection {
    NSArray *handlers = self.changeDomainHandlers;
    for (SFAChangeDomainCallback handler in handlers) {
        SFAEventHandlerResponse *action = handler(requestMessage, redirection);
        if (action.action != SFAEventHandlerResponseActionIgnore) {
            return action;
        }
    }
    return [SFAEventHandlerResponse eventHandlerResponseWithRedirection:redirection];
}

- (void)registerAsyncRequestProvider:(id <SFAAsyncRequestProvider> )asyncRequestProvider {
    [self.requestProviderFactory setAsyncProvider:asyncRequestProvider];
}

- (id <SFAAsyncRequestProvider> )asyncRequestProvider {
    return [self.requestProviderFactory asyncProvider];
}

+ (NSString *)providerWithURL:(NSURL *)url {
    NSArray *items = [[url absoluteString] componentsSeparatedByString:@"/" removeEmptyEntries:YES];
    NSString *retStr = @"sf";
    if ([items count]) {
        retStr = items[0];
    }
    return retStr;
}

- (SFAAsyncUploaderBase *)asyncFileUploaderWithUploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config expirationDays:(int)expirationDays {
    switch (uploadSpecificationRequest.method) {
        case SFAUploadMethodStandard:
            return [[SFAAsyncStandardFileUploader alloc] initWithSFAClient:self uploadSpecificationRequest:uploadSpecificationRequest filePath:filePath fileUploaderConfig:config andExpirationDays:expirationDays];
            break;
            
        case SFAUploadMethodStreamed:
            return [[SFAAsyncStreamedFileUploader alloc] initWithSFAClient:self uploadSpecificationRequest:uploadSpecificationRequest filePath:filePath fileUploaderConfig:config andExpirationDays:expirationDays];
            break;
            
        case SFAUploadMethodThreaded:
            return [[SFAAsyncThreadedFileUploader alloc] initWithSFAClient:self uploadSpecificationRequest:uploadSpecificationRequest filePath:filePath fileUploaderConfig:config andExpirationDays:expirationDays];
            break;
            
        default:
            break;
    }
    NSAssert(NO, @"Upload specification Request method not supported");
    return nil;
}

- (id <SFAURLSessionTaskHttpDelegate> )recreateURLSessionTaskHttpDelegateWithUploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config expirationDays:(int)expirationDays uploadSpecification:(SFIUploadSpecification *)uploadSpecification {
    if (uploadSpecificationRequest.method != SFAUploadMethodStandard) {
        NSAssert(NO, @"Standard Upload is the only supported method.");
        return nil;
    }
    else {
        return [SFAAsyncStandardFileUploader uploaderForURLSessionTaskDelegateWithClient:self uploadSpecificationRequest:uploadSpecificationRequest filePath:filePath fileUploaderConfig:config andExpirationDays:expirationDays uploadSpecification:uploadSpecification];
    }
}

- (SFAAsyncUploaderBase *)asyncFileUploaderWithUploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config {
    return [self asyncFileUploaderWithUploadSpecificationRequest:uploadSpecificationRequest filePath:filePath fileUploaderConfig:config expirationDays:-1];
}

- (id <SFAURLSessionTaskHttpDelegate> )recreateURLSessionTaskHttpDelegateWithUploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config uploadSpecification:(SFIUploadSpecification *)uploadSpecification {
    return [self recreateURLSessionTaskHttpDelegateWithUploadSpecificationRequest:uploadSpecificationRequest filePath:filePath fileUploaderConfig:config expirationDays:-1 uploadSpecification:uploadSpecification];
}

#if TARGET_OS_IPHONE
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (SFAAsyncUploaderBase *)asyncFileUploaderWithUploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset fileUploaderConfig:(SFAFileUploaderConfig *)config expirationDays:(int)expirationDays {
    switch (uploadSpecificationRequest.method) {
        case SFAUploadMethodStandard:
            return [[SFAAsyncStandardFileUploader alloc] initWithSFAClient:self uploadSpecificationRequest:uploadSpecificationRequest asset:asset fileUploaderConfig:config andExpirationDays:expirationDays];
            break;
            
        case SFAUploadMethodStreamed:
            return [[SFAAsyncStreamedFileUploader alloc] initWithSFAClient:self uploadSpecificationRequest:uploadSpecificationRequest asset:asset fileUploaderConfig:config andExpirationDays:expirationDays];
            break;
            
        case SFAUploadMethodThreaded:
            return [[SFAAsyncThreadedFileUploader alloc] initWithSFAClient:self uploadSpecificationRequest:uploadSpecificationRequest asset:asset fileUploaderConfig:config andExpirationDays:expirationDays];
            break;
            
        default:
            break;
    }
    NSAssert(NO, @"Upload specificationrRequest method not supported");
    return nil;
}

- (SFAAsyncUploaderBase *)asyncFileUploaderWithUploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset fileUploaderConfig:(SFAFileUploaderConfig *)config {
    return [self asyncFileUploaderWithUploadSpecificationRequest:uploadSpecificationRequest asset:asset fileUploaderConfig:config expirationDays:-1];
}

#pragma clang diagnostic pop
#endif

- (SFAAsyncFileDownloader *)asyncFileDownloaderForItem:(SFIItem *)item withDownloaderConfig:(SFADownloaderConfig *)config {
    return [[SFAAsyncFileDownloader alloc] initWithItem:item withSFAClient:self andDownloaderConfig:config];
}

- (SFAAsyncFileDownloader *)recreateURLSessionTaskHttpDelegateForDownloadingItem:(SFIItem *)item withDownloaderConfig:(SFADownloaderConfig *)config {
    return [SFAAsyncFileDownloader downloaderForURLSessionTaskHTTPDelegateWithItem:item client:self config:config];
}

#pragma mark - Private

- (void)registerRequestProviders {
    self.requestProviderFactory = [[SFARequestProviderFactory alloc] init];
    [self.requestProviderFactory setAsyncProvider:[[SFAAsyncRequestProvider alloc] initWithSFAClient:self]];
}

@end
