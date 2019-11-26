#import <Foundation/Foundation.h>
#import "SFATransferProgress.h"
#import "SFATask.h"
/**
 *  Callback for informing API user of task's data transfer progress.
 *
 * `transferProgress`: A SFATransferProgress object containing information about transfer progress.
 *
 */
typedef void (^SFATransferTaskProgressCallback)(SFATransferProgress *transferProgress);

static NSString *const kSFATransferTaskProgressNotification = @"SFATransferTaskProgressNotification";
static NSString *const kSFATransferTaskNotificationUserInfoProgress = @"SFATransferTaskNotificationUserInfoProgress";

/**
 * The SFATransferTask extends from SFATask. It contains all method from super class in addition to progress callback.
 *
 * `kSFATransferTaskProgressNotification`: Progress notification name.
 *
 * `kSFATransferTaskNotificationUserInfoProgress`: Key for progress information in notfication's user info dictionary.
 *
 */
@protocol SFATransferTask <SFATask>
/**
 *  A transfer progress callback block. See SFATransferTaskProgressCallback.
 */
@property (atomic, copy) SFATransferTaskProgressCallback progressCallback;
@property (atomic, copy) NSDictionary *transferMetaData;

@end
