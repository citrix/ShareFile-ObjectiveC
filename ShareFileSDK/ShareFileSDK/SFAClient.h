#import <Foundation/Foundation.h>
#import "SFATask.h"
#import "SFAChangeDomainCallback.h"
#import "SFAErrorCallback.h"
#import "SFAAsyncRequestProvider.h"
#import "SFAOAuthToken.h"
#import "SFAConfiguration.h"
#import "SFALoggingProvider.h"
#import "SFAUploadSpecificationRequest.h"
#import "SFAFileInfo.h"
#import "SFAFileUploaderConfig.h"
#import "SFAAsyncUploaderBase.h"
#import "SFAAsyncFileDownloader.h"
#import "SFAConfig.h"
#import "SFAAuthHandling.h"
#import "SFACredentialStatusTracking.h"
#import "SFABackgroundSessionManager.h"
#if TARGET_OS_IPHONE
#import <AssetsLibrary/AssetsLibrary.h>
#endif

#if ShareFile

#import "SFAZoneAuthentication.h"

#endif

#if ShareFile
@class SFIAccountsEntityInternal;
@class SFIOAuthClientsEntityInternal;
@class SFIDevicesEntityInternal;
@class SFIConfigsEntityInternal;
@class SFIFileLockEntityInternal;
#endif
@class SFIItem;
@class SFIAccountsEntity;
@class SFIAccessControlsEntity;
@class SFIAsyncOperationsEntity;
@class SFICapabilitiesEntity;
@class SFIConnectorGroupsEntity;
@class SFIFavoriteFoldersEntity;
@class SFIGroupsEntity;
@class SFIMetadataEntity;
@class SFISessionsEntity;
@class SFISharesEntity;
@class SFIUsersEntity;
@class SFIItemsEntity;
@class SFIStorageCentersEntity;
@class SFIZonesEntity;
@class SFIZonesEntity;

@protocol SFAClient <NSObject>

#if ShareFile
/**
 *  A SFIAccountEntityInternal/SFIAccountsEntity readonly object.
 *
 *  @warning The type of this property depends on:
 *
 *  - if #define ShareFile is set to 1 in 'SFAConfig.h': SFIAccountEntityInternal
 *  - else  SFIAccountsEntity.
 *
 *  Simply changing #define ShareFile will cause run-time exception if the code is not recompiled. You should only do this if you have access to the code.
 */
@property (strong, nonatomic, readonly) SFIAccountsEntityInternal *accounts;
/**
 *  A SFIOAuthClientsEntityInternal readonly object.
 *
 *  @warning The property is only available if:
 *
 *  - if #define ShareFile is set to 1 in 'SFAConfig.h'.
 *
 *  Simply changing #define ShareFile will cause run-time exception if the code is not recompiled. You should only do this if you have access to the code.
 */
@property (strong, nonatomic, readonly) SFIOAuthClientsEntityInternal *oAuthClients;
#else

@property (strong, nonatomic, readonly) SFIAccountsEntity *accounts;

#endif
/**
 *  A SFIAccessControlsEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFIAccessControlsEntity *accessControls;
/**
 *  A SFIAsyncOperationsEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFIAsyncOperationsEntity *asyncOperations;
/**
 *  A SFICapabilitiesEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFICapabilitiesEntity *capabilities;
/**
 *  A SFIConnectorGroupsEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFIConnectorGroupsEntity *connectorGroups;
/**
 *  A SFIFavoriteFoldersEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFIFavoriteFoldersEntity *favoriteFolders;
/**
 *  A SFIGroupsEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFIGroupsEntity *groups;
/**
 *  A SFIMetadataEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFIMetadataEntity *metadata;
/**
 *  A SFISessionsEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFISessionsEntity *sessions;
/**
 *  A SFISharesEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFISharesEntity *shares;
/**
 *  A SFIUsersEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFIUsersEntity *users;

/**
 *  A SFIItemsEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFIItemsEntity *items;
/**
 *  A SFIStorageCentersEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFIStorageCentersEntity *storageCenters;
/**
 *  A SFIZonesEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFIZonesEntity *zones;
/**
 *  A base url of ShareFile client.
 */
@property (strong, atomic) NSURL *baseUrl;
/**
 *  A SFAConfiguration object.
 */
@property (copy, atomic) SFAConfiguration *configuration;
/**
 *  An array of SFAChangeDomainCallback blocks, called when domain changes.
 */
@property (atomic, readonly) NSArray *changeDomainHandlers;
/**
 *  An array of SFAErrorCallback blocks, called when error occurs in query request.
 */
@property (atomic, readonly) NSArray *errorHandlers;

@property (strong, nonatomic) id <SFAAuthHandling> authHandler;

#if ShareFile
/**
 *  A SFIConfigsEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFIConfigsEntityInternal *configs;

/**
 *  A SFIDevicesEntity readonly object.
 */
@property (strong, nonatomic, readonly) SFIDevicesEntityInternal *devices;

/**
 *  A SFIFileLockEntity readonly object
 */
@property (strong, nonatomic, readonly) SFIFileLockEntityInternal *fileLocks;

/**
 *  A SFAZoneAuthentication object.
 */
@property (strong, nonatomic) SFAZoneAuthentication *zoneAuthentication;
#endif
/**
 *  The maximum number of queued operations that can execute at the same time. Default is NSOperationQueueDefaultMaxConcurrentOperationCount.
 */
@property (atomic) NSInteger maxConcurrentTaskCount;
/**
 *  Background Session Manager that can be used to initiate background transfers.
 */
@property (strong, atomic, readonly) SFABackgroundSessionManager *backgroundSessionManager;
/**
 *  Async request provider being used for creating task from query.
 */
@property (strong, nonatomic, readonly) id <SFAAsyncRequestProvider> asyncRequestProvider;
/**
 *  Get provider from the given URL.
 *
 *  @param url NSURL from which to extract provider.
 *
 *  @return Returns NSString representing provider. If no provider found it returns "sf" by default.
 */
+ (NSString *)providerWithURL:(NSURL *)url;
/**
 *  Initializes SFAClient instance with base url and configuration object.
 *
 *  @param baseUrl       A base url of ShareFile Client.
 *  @param configuration A SFAConfiguration object. Can be nil. If nil, default configuration is used.
 *
 *  @return Returns initilized SFAClient object or nil if an object could not be created for some reason.
 */
- (instancetype)initWithBaseUrl:(NSString *)baseUrl andConfiguration:(SFAConfiguration *)configuration;
/**
 *  Creates a task conforming to SFATransferTask and starts the task, configuring it with provided parameters.
 *
 *  @param query A query to be executed.
 *
 *  @return Returns initilized and started task, conforming SFATransferTask, configured with provided parameters.
 */
- (id <SFATransferTask> )executeQueryAsync:(id <SFAQuery> )query;
/**
 *  Creates a task conforming to SFATransferTask and starts the task, configuring it with provided parameters.
 *
 *  @param query              A query to be executed.
 *  @param callbackQueue      NSOperationQueue on which the callbacks will be called. For SFAAsyncRequestProvider:if nil, defaults to main queue.
 *  @param completionCallback SFATask completion callback.
 *
 *  @return Returns initilized and started task, conforming SFATransferTask, configured with provided parameters.
 */
- (id <SFATransferTask> )executeQueryAsync:(id <SFAQuery> )query callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback;
/**
 *  Creates a task conforming to SFATransferTask and starts the task, configuring it with provided parameters.
 *
 *  @param query              A query to be executed.
 *  @param callbackQueue      NSOperationQueue on which the callbacks will be called. For SFAAsyncRequestProvider:if nil, defaults to main queue.
 *  @param completionCallback SFATask completion callback.
 *  @param cancelCallback     SFATask cancel callback.
 *
 *  @return Returns initilized and started task, conforming SFATransferTask, configured with provided parameters.
 */
- (id <SFATransferTask> )executeQueryAsync:(id <SFAQuery> )query callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback;

/**
 *  Execute a SFAQuery
 *
 *  @param query              Query to execute
 *  @param callbackQueue      NSOperationQueue for callback
 *  @param interactiveHandler Interactive handler used by the task.
 *  @param completionCallback Callback after task has completed
 *  @param cancelCallback     Callback called if task is canceled
 *
 *  @return Reference to new SFATransferTask
 */
- (id <SFATransferTask> )executeQueryAsync:(id <SFAQuery> )query callbackQueue:(NSOperationQueue *)callbackQueue interactiveHandler:(NSObject <SFAInteractiveAuthHandling> *)interactiveHandler completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback;

/**
 *  Creates a task from provided parameters
 *
 *  @param query              Query for task.
 *  @param callbackQueue      Queue on which callbacks are to be called
 *  @param completionCallback Callback called upon completion
 *  @param cancelCallback     Callback called upon cancellation
 *
 *  @return Returns Transfer Task.
 */
- (id <SFATransferTask> )taskWithQuery:(id <SFAQuery> )query callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback;
/**
 *  Start execution of the passed task.
 *
 *  @param task Task to be executed.
 */
- (void)executeTask:(id <SFATask> )task;

#if ShareFile
/**
 *  Creates uploader with provided parameters.
 *
 *  @param uploadSpecificationRequest A upload specificaton request.
 *  @param filePath                   A path of the file to be uploaded.
 *  @param config                     A uploader config object. Can be nil.
 *  @param expirationDays             The expiration days. Default number of expiration days is 30. -1 disables share expiration.
 *
 *  @return Returns the uploader configured with provided parameters.
 *  @warning This method is only available if #define ShareFile is set to 1 in 'SFAConfig.h'. See asyncFileUploaderWithUploadSpecificationRequest:filePath:fileUploaderConfig: if #define ShareFile is set to 0. Simply changing #define ShareFile will cause run-time exception if the code is not recompiled. You should only do this if you have access to the code.
 */
- (SFAAsyncUploaderBase *)asyncFileUploaderWithUploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config expirationDays:(int)expirationDays;
/**
 *  Recreate HTTP delegate for URLSessionTask(upload). This can be needed at app-relaunch.
 *
 *  @param uploadSpecificationRequest Upload specification request used the first time task was created.
 *  @param filePath                   File path used the first time task was created.
 *  @param config                     Config used the first time task was created. For standard upload nil can be used.
 *  @param expirationDays             Expiration day used the first time task was created.
 *  @param uploadSpecification        Upload Specification returned in background upload initiation response.
 *
 *  @return Intantiated HTTP delegate for URLSessionTask(upload).
 *  @warning This method is only available if #define ShareFile is set to 1 in 'SFAConfig.h'. See recreateURLSessionTaskHttpDelegateWithUploadSpecificationRequest:filePath:fileUploaderConfig:uploadSpecification: if #define ShareFile is set to 0. Simply changing #define ShareFile will cause run-time exception if the code is not recompiled. You should only do this if you have access to the code.
 */
- (id <SFAURLSessionTaskHttpDelegate> )recreateURLSessionTaskHttpDelegateWithUploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config expirationDays:(int)expirationDays uploadSpecification:(SFIUploadSpecification *)uploadSpecification;
#if TARGET_OS_IPHONE
/**
 *  Creates uploader with provided parameters.
 *
 *  @param uploadSpecificationRequest A upload specificaton request.
 *  @param asset                      An ALAsset instance whose default representation is to be uploaded.
 *  @param config                     A uploader config object. Can be nil.
 *  @param expirationDays             The expiration days. Default number of expiration days is 30. -1 disables share expiration.
 *
 *  @return Returns the uploader configured with provided parameters.
 *  @warning This method is only available if #define ShareFile is set to 1 in 'SFAConfig.h'. See asyncFileUploaderWithUploadSpecificationRequest:asset:fileUploaderConfig: if #define ShareFile is set to 0. Simply changing #define ShareFile will cause run-time exception if the code is not recompiled. You should only do this if you have access to the code.
 *  @warning This method is only available with iOS SDK.
 */
- (SFAAsyncUploaderBase *)asyncFileUploaderWithUploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset fileUploaderConfig:(SFAFileUploaderConfig *)config expirationDays:(int)expirationDays;
#endif
#else
- (SFAAsyncUploaderBase *)asyncFileUploaderWithUploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config;
- (id <SFAURLSessionTaskHttpDelegate> )recreateURLSessionTaskHttpDelegateWithUploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config uploadSpecification:(SFIUploadSpecification *)uploadSpecification;
#if TARGET_OS_IPHONE
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (SFAAsyncUploaderBase *)asyncFileUploaderWithUploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset fileUploaderConfig:(SFAFileUploaderConfig *)config;
#pragma clang diagnostic pop
#endif
#endif
/**
 *  Creates downloader with given item and download config.
 *
 *  @param item   An item to be downloaded.
 *  @param config A downloader config. Set to defautl values if not provided.
 *
 *  @return Returns SFAAsyncFileDownloader for given item.
 */
- (SFAAsyncFileDownloader *)asyncFileDownloaderForItem:(SFIItem *)item withDownloaderConfig:(SFADownloaderConfig *)config;
/**
 *  Recreate HTTP delegate for URLSessionTask(download). This can be needed at app-relaunch.
 *
 *  @param item   Item used the first time task was created.
 *  @param config Config used the first time task was created.
 *
 *  @return Intantiated HTTP delegate for URLSessionTask(download).
 */
- (SFAAsyncFileDownloader *)recreateURLSessionTaskHttpDelegateForDownloadingItem:(SFIItem *)item withDownloaderConfig:(SFADownloaderConfig *)config;
/**
 *  Adds change domain handler to changeDomainHandlers.
 *
 *  @param handler A SFAChangeDomainCallback block to be called on domain change.
 */
- (void)addChangeDomainHandler:(SFAChangeDomainCallback)handler;
/**
 *  Adds error handler to errorHandlers.
 *
 *  @param handler A SFAErrorCallback block to be called on query request error.
 */
- (void)addErrorHandler:(SFAErrorCallback)handler;
/**
 *  Remove domain change handler.
 *
 *  @param handler A SFAChangeDomainCallback block to be removed.
 *
 *  @return Returns YES if callback has be been successfully removed from array.
 */
- (BOOL)removeChangeDomainHandler:(SFAChangeDomainCallback)handler;
/**
 *  Remove error handler.
 *
 *  @param handler A SFAErrorCallback block to be removed.
 *
 *  @return Returns YES if callback has be been successfully removed from array.
 */
- (BOOL)removeErrorHandler:(SFAErrorCallback)handler;
/**
 *  Notify error handlers with SFAHttpRequestResponseDataContainer and retry count.
 *
 *  @param dataContainer A SFAHttpRequestResponseDataContainer object containing request and response etc.
 *  @param retryCount    Retry count of request.
 *
 *  @return Returns appropiate SFAEventHandlerResponse. For default SFAClient: SFAEventHandlerResponse returned by first handler that does not return SFAEventHandlerResponse with action equal to SFAEventHandlerResponseActionIgnore. If all handlers returned SFAEventHandlerResponseActionIgnore or no handlers were available SFAEventHandlerResponse with action equal to SFAEventHandlerResponseActionFailWithError.
 */
- (SFAEventHandlerResponse *)onErrorWithDataContainer:(SFAHttpRequestResponseDataContainer *)dataContainer retryCount:(int)retryCount;
/**
 *  Notify domain change handlers with request and redirection.
 *
 *  @param requestMessage A URL request for which domain change event occured.
 *  @param redirection    A SFIRedirection object.
 *
 *  @return Returns appropiate SFAEventHandlerResponse. For default SFAClient: SFAEventHandlerResponse returned by first handler that does not return SFAEventHandlerResponse with action equal to SFAEventHandlerResponseActionIgnore. If all handlers returned SFAEventHandlerResponseActionIgnore or no handlers were available SFAEventHandlerResponse with action equal to SFAEventHandlerResponseActionRedirect and given redirection is returned.
 */
- (SFAEventHandlerResponse *)onChangeDomainWithRequest:(NSURLRequest *)requestMessage redirection:(SFIRedirection *)redirection;
/**
 *  Change async request provider used to setup task from query.
 *
 *  @param asyncRequestProvider A request provider that conforms to SFAAsyncRequestProvider protocol.
 */
- (void)registerAsyncRequestProvider:(id <SFAAsyncRequestProvider> )asyncRequestProvider;

@end

/**
 * The SFAClient class conforms to SFAClient protocol. Application code will be interacting with this class most of the time.
 */
@interface SFAClient : NSObject <SFAClient>
/**
 *  SFALoggingProvider object.
 */
@property (atomic, strong, readonly) SFALoggingProvider *loggingProvider;

@end
