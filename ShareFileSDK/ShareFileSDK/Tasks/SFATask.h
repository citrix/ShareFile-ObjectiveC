#import <Foundation/Foundation.h>
#import "SFAError.h"
#import "SFAInteractiveAuthHandling.h"

@protocol SFATask;
/**
 *  Completion callback called when a task finishes.
 *
 * `returnValue`: The response object as a result of query. This can be nil in case of `error`.
 *
 * `error`: object of SFAError or one of its subclass. You can check error type property to determine type of `error`. For ease of use `error` can be type casted to one of SFAError subclass after necessary isKindOfClass: checks. `error` must be checked before trying to use `returnValue`. `error` is nil in case of success.
 *
 * `additionalInfo` dictionary contains additional information objects related to the task.
 *
 * `additionalInfo` and `error.userInfo` are good starting points for debugging a problem.
 *
 * - 'kSFAHttpRequestResponseDataContainer': Key for SFAHttpRequestResponseDataContainer object in additionalInfo dictionary passed to completionCallback.
 *
 */
typedef void (^SFATaskCompletionCallback)(id returnValue, SFAError *error, NSDictionary *additionalInfo);
/**
 *  Cancel callback is called when a task gets cancelled i.e. finishes due to cancellation.
 */
typedef void (^SFATaskCancelCallback)();

static NSString *const kSFATaskCompleteNotification = @"SFATaskCompleteNotification";
static NSString *const kSFATaskCancelNotification = @"SFATaskCancelNotification";
static NSString *const kSFATaskNotificationUserInfoReturnValue = @"SFATaskNotificationUserInfoReturnValue";
static NSString *const kSFATaskNotificationUserInfoError = @"SFATaskNotificationUserInfoError";
static NSString *const kSFATaskNotificationUserInfoAdditionalInfo = @"SFATaskNotificationUserInfoAdditionalInfo";

/**
 *  The SFATask protocol contain methods that allow API user to interact with asynchronous tasks.
 *
 *  `kSFATaskCompleteNotification`: Completion notification name.
 *
 *  `kSFATaskCancelNotification`: Cancellation notification name.
 *
 *  `kSFATaskNotificationUserInfoReturnValue`: Key for return value in notification's user info dictionary.
 *
 *  `kSFATaskNotificationUserInfoError`: Key for error in notification's user info dictionary.
 *
 *  `kSFATaskNotificationUserInfoAdditionalInfo`: Key for additional user info in notification's user info dictionary.
 *
 */
@protocol SFATask <NSObject>

/**
 *  Interactive handler for the current task. When present, auth failures will be forwarded to the handler for attempted recovery.
 */
@property (atomic, weak) NSObject <SFAInteractiveAuthHandling> *interactiveHandler;

/**
 *  Task's completion callback block. See SFATaskCompletionCallback.
 */
@property (atomic, copy) SFATaskCompletionCallback completionCallback;
/**
 *  Task's cancel callback block. See SFATaskCancelCallback.
 */
@property (atomic, copy) SFATaskCancelCallback cancelCallback;
/**
 *  Calling this method will start the task if it is not already started.
 */
- (void)start;
/**
 *  Calling this method will mark task for cancellation.
 *  @warning Behavior of default SFATask implementation used by SDK: This does not gurantee that task will be cancelled right away or will ever be cancelled. If task is actually cancelled, cancelCallback will be called.
 */
- (void)cancel;
/**
 *  Check if task is marked for cancellation.
 *
 *  @return Retruns YES if task is cancelled.
 *  @warning Behavior of default SFATask implementation used by SDK: This does not gurantee that task has been cancelled. If task was actually cancelled, cancelCallback would have been called.
 */
- (BOOL)isCancelled;
/**
 *  Checks if task is in finished state
 *
 *  @return Returns YES if task is finished.
 *  @warning This does not say anything about success, failure or cancellation of task. Parameters passed in completionCallback or cancelCallback can be used to determine how task actually ended.
 */
- (BOOL)isFinished;
/**
 *  Check if task is in execution state
 *
 *  @return Returns YES if the task is executing.
 */
- (BOOL)isExecuting;

@end
