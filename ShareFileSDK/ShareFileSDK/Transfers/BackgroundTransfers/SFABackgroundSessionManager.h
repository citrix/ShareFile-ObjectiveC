#import <Foundation/Foundation.h>
#import "SFABackgroundSessionConfiguration.h"
#import "SFAURLSessionTaskHttpDelegate.h"
@class SFAClient;

static const NSString *kSFAURLSessionTaskDelegateAdditionalInfoHttpRequestResponseDataContainer = @"SFAURLSessionTaskDelegateAdditionalInfoHttpRequestResponseDataContainer";

/**
 *  This protocol defines functions that can be used by user to interact, control and be notified about various events that occur during life-span of a NSURLSessionTask.
 */
@protocol SFAURLSessionTaskDelegate <NSObject>

/**
 *  This delegate function is called when task has been completed.
 *
 *  @param session        NSURLSession for the task.
 *  @param task           Task which was completed.
 *  @param returnValue    Object representing the result. This is an appropiate model in case of upload and file URL in case of download. Will be nil in case of error.
 *  @param error          Error object representing if an error occured. Error's type can be useful. Also userInfo dictionary may contain NSError that caused the task to fail against 'error' key.
 *  @param additionalInfo Dictionary containing any other necessary information. HTTP related information is found against key: kSFAURLSessionTaskDelegateAdditionalInfoHttpRequestResponseDataContainer and value of type: SFAHttpRequestResponseDataContainer.
 *
 *  @return Return YES if event was handled.
 */
- (BOOL)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithReturnValue:(id)returnValue error:(SFAError *)error additionalInfo:(NSDictionary *)additionalInfo;

@optional

/**
 *  This delegate function is called to get destination file URL. Downloaded file will be copied to location specified in URL.
 *
 *  @param session      NSURLSession for the task.
 *  @param downloadTask Task for which event has been called.
 *
 *  @return Return non-nil if event was handled.
 */
- (NSURL *)URLSession:(NSURLSession *)session downloadTaskNeedsDestinationFileURL:(NSURLSessionDownloadTask *)downloadTask;
/**
 *  This delegate function is called to notify about download task progress.
 *
 *  @param session                   NSURLSession for the task.
 *  @param downloadTask              Task for which event has been called.
 *  @param bytesWritten              Bytes written since last event.
 *  @param totalBytesWritten         Total bytes written by task.
 *  @param totalBytesExpectedToWrite Total bytes that task will write.
 *
 *  @return Return YES if event was handled.
 */
- (BOOL)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;
/**
 *  This delegate function is called to notify about upload task progress.
 *
 *  @param session                  NSURLSession for the task.
 *  @param task                     Task for which event has been called.
 *  @param bytesSent                Bytes sent since last event.
 *  @param totalBytesSent           Total bytes sent by task.
 *  @param totalBytesExpectedToSend Total bytes that task will send.
 *
 *  @return Return YES if event was handled.
 */
- (BOOL)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;
/**
 *  This delegate function is called to get appropiate HTTP delegate and context object for task on app re-launch. In case these are not provided, a default delegate and
 *  context object will be used. In SDKs built-in implementation uploader and downloader can act as delegate. You can re-create upload/downloader using APIs
 *  in SFAClient.
 *
 *  @param session                  NSURLSession for the task.
 *  @param task                     Task for which event has been called.
 *  @param bytesSent                Bytes sent since last event.
 *  @param totalBytesSent           Total bytes sent by task.
 *  @param totalBytesExpectedToSend Total bytes that task will send.
 *
 *  @return Return YES if event was handled.
 */
- (BOOL)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needsHttpDelegate:(id <SFAURLSessionTaskHttpDelegate> *)delegate andNeedsContextObject:(NSMutableDictionary **)contextObjectDictionary;
/**
 *  This delegate function is called whenever task starts using a new HTTP delegate.
 *
 *  @param session  NSURLSession for the task.
 *  @param task     Task for which event has been called.
 *  @param delegate Delegate which will be used from now onwards.
 *
 *  @return Return YES if event was handled.
 */
- (BOOL)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task hasHttpDelegate:(id <SFAURLSessionTaskHttpDelegate> )delegate;
/**
 *  This delegate function is called whenever task starts using a new context object. Note: Objects inside the context object may still change after this function is called. If you want to re-create context object on app-relaunch. It may be a good idea to store information in this object when app is about to be terminated.
 *
 *  @param session       NSURLSession for the task.
 *  @param task          Task for which event has been called.
 *  @param contextObject Context object being used from now onwards.
 *
 *  @return Return YES if event was handled.
 */
- (BOOL)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willUseContextObject:(NSMutableDictionary *)contextObject;
/**
 *  This delegate function is called to notify task that request may be re-attempted for varios reasons. This delegate function is way of SDK to let user knowm
 *  about creation of new task, so that delagates may be added etc.
 *
 *  @param session NSURLSession for the task.
 *  @param task    Task for which event has been called.
 *  @param newTask New task through which re-attempt will be made.
 *
 *  @return Return YES if event was handled.
 */
- (BOOL)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willRetryWithNewTask:(NSURLSessionTask *)newTask;

@end

/**
 *  A class that encapsulates most of the functionality needed for performing task's with background NSURLSession.
 */
@interface SFABackgroundSessionManager : NSObject

/**
 *  Configuration used for customizing NSURLSessionConfiguration, when creating new background NSURLSession instance.
 */
@property (copy, atomic, readwrite) SFABackgroundSessionConfiguration *configurationForNewBackgroundSession;
/**
 *  The background NSURLSession instance being used by manager, if nil will be created.
 */
@property (strong, atomic, readonly) NSURLSession *backgroundSession;
/**
 *  Delegate that will receive events for all URL Session Task's, if task specific delegate failed to handle the event.
 */
@property (weak, atomic, readwrite) id <SFAURLSessionTaskDelegate> universalTaskDelegate;

/**
 *  Initializes a new background session manager with provided parameters.
 *
 *  @param client Client to be used by this manager.
 *
 *  @return An initialized background session manager.
 */
- (instancetype)initWithClient:(SFAClient *)client;
/**
 *  This method allows user to check if manager has an instance of Background NSURLSession.
 *
 *  @return Returns YES if NSURLSession instance exists.
 */
- (BOOL)hasBackgroundSession;
/**
 *  Creates a new background NSURLSession, customizing NSURLSessionConfiguration by configurationForNewBackgroundSession.
 */
- (void)setupBackgroundSession;
/**
 *  Creates a new background NSURLSession, customizing NSURLSessionConfiguration by configurationForNewBackgroundSession. Also stores completion handler
 *  against session, so that it can be called when appropiate.
 *
 *  @param completionHandler Completion handler block provided by app delegate to be called when background session events have been handled.
 */
- (void)setupBackgroundSessionWithCompletionHandler:(void (^)())completionHandler;
/**
 *  Add and store completion handler for existing URLSession instance. Provide nil for removal of any existing block.
 *
 *  @param completionHandler Completion handler block provided by app delegate to be called when background session events have been handled.
 */
- (void)setCompletionHandlerForCurrentBackgroundSession:(void (^)())completionHandler;
/**
 *  Add and store completion handler for URLSession instance. Provide nil for removal of any existing block.
 *
 *  @param session           URLSession for which block is intended.
 *  @param completionHandler Completion handler block provided by app delegate to be called when background session events have been handled.
 */
- (void)setForBackgroundSession:(NSURLSession *)session completionHandler:(void (^)())completionHandler;
/**
 *  Add task specific delegate for URLSession(current background session) and task combination, identified by their respective identifier's. Passing nil will remove any existing delegate.
 *  Task specific delegates have priority over universalTaskDelegate. universalTaskDelegate only gets events in case task specific delegate fails to handle an event.
 *
 *  @param delegate   Delegate to be added.
 *  @param identifier Identifier of the NSURLSessionTask.
 */
- (void)addDelegate:(id <SFAURLSessionTaskDelegate> )delegate forCurrentBackgroundSessionAndTaskWithIdentifier:(NSUInteger)identifier;
/**
 *  Add task specific delegate for URLSession and task combination, identified by their respective identifier's. Passing nil will remove any existing delegate.
 *  Task specific delegates have priority over universalTaskDelegate. universalTaskDelegate only gets events in case task specific delegate fails to handle an event.
 *
 *  @param delegate   Delegate to be added.
 *  @param session    Session for the session-task combination.
 *  @param identifier Identifier of the NSURLSessionTask.
 */
- (void)addDelegate:(id <SFAURLSessionTaskDelegate> )delegate forSession:(NSURLSession *)session andTaskWithIdentifier:(NSUInteger)identifier;
/**
 *  Removes task specific delegate for URLSession(current background session) and task combination, identified by their respective identifier's.
 *
 *  @param identifier Identifier of the NSURLSessionTask.
 */
- (void)removeDelegateForCurrentBackgroundSessionAndTaskWithIdentifier:(NSUInteger)identifier;
/**
 *  Removes task specific delegate for URLSession and task combination, identified by their respective identifier's.
 *
 *  @param session    Session for the session-task combination.
 *  @param identifier Identifier of the NSURLSessionTask.
 */
- (void)removeDelegateForSession:(NSURLSession *)session andTaskWithIdentifier:(NSUInteger)identifier;
/**
 *  Removes all task specific delegate for URLSession(current background session), identified by its identifier.
 */
- (void)removeAllTaskSpecificDelegatesForCurrentBackgroundSession;
/**
 *  Removes all task specific delegate for URLSession(current background session), identified by its identifier.
 *
 *  @param session Session for whose tasks, all delegates will be removed.
 */
- (void)removeAllTaskSpecificDelegatesForSession:(NSURLSession *)session;
/**
 *  Task specific delegate, if any, for URLSession(current background session) and task combination, identified by their respective identifier's.
 *
 *  @param identifier Identifier of the NSURLSessionTask.
 *
 *  @return Task specific delegate, if any
 */
- (id <SFAURLSessionTaskDelegate> )delegateForCurrentBackgroundSessionAndTaskWithIdentifier:(NSUInteger)identifier;
/**
 *  Task specific delegate, if any, for URLSession and task combination, identified by their respective identifier's.
 *
 *  @param session    Session for the session-task combination.
 *  @param identifier Identifier of the NSURLSessionTask.
 *
 *  @return Task specific delegate, if any
 */
- (id <SFAURLSessionTaskDelegate> )delegateForSession:(NSURLSession *)session andTaskWithIdentifier:(NSUInteger)identifier;
/**
 *  Notify delegates about update of context object used by the task-session combination identified by their respective identifier's.
 *  Task specific delegates have priority over universalTaskDelegate. universalTaskDelegate only gets events in case task specific delegate fails to handle an event.
 *
 *  @param session       Session for the session-task combination.
 *  @param task          Task for the session-task combination.
 *  @param contextObject New context object being used.
 */
- (void)notifyContextUpdateForSession:(NSURLSession *)session task:(NSURLSessionTask *)task contextObject:(NSMutableDictionary *)contextObject;
/**
 *  Notify delegates about update of context object used by the task-session combination identified by their respective identifier's.
 *  Task specific delegates have priority over universalTaskDelegate. universalTaskDelegate only gets events in case task specific delegate fails to handle an event.
 *
 *  @param session      Session for the session-task combination.
 *  @param task         Task for the session-task combination.
 *  @param httpDelegate New http delegate being used.
 */
- (void)notifiyDelegateUpdateForURLSession:(NSURLSession *)session task:(NSURLSessionTask *)task delegate:(id <SFAURLSessionTaskHttpDelegate> )httpDelegate;

@end
