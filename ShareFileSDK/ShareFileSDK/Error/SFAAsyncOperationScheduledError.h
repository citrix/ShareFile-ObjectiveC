#import <Foundation/Foundation.h>
#import "SFAError.h"
#import "SFAsyncOperation.h"
/**
 *  String constant for async operation key in user info dictionary.
 */
extern NSString *const kSFAErrorScheduledAsyncOperation;
/**
 *  The SFAAsyncOperationScheduledError is used to inform user if a SFAsyncOperation was scheduled as result of an API call.
 */
@interface SFAAsyncOperationScheduledError : SFAError
/**
 *  SFAsyncOperation object representing operation that got scheduled.
 */
@property (nonatomic, strong, readonly) SFAsyncOperation *scheduledAsyncOperation;
/**
 *  Initializes SFAAsyncOperationScheduledError with provided parameters.
 *
 *  @param asyncOperation SFAsyncOperation representing operation that got scheduled.
 *
 *  @return Returns initialized object of SFAAsyncOperationScheduledError or nil if an object could not be created for some reason.
 */
+ (instancetype)errorWithScheduleAsyncOperation:(SFAsyncOperation *)asyncOperation;

@end
