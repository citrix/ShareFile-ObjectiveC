#import <Foundation/Foundation.h>
#import "SFAError.h"
#import "SFIAsyncOperation.h"
/**
 *  String constant for async operation key in user info dictionary.
 */
extern NSString *const kSFAErrorScheduledAsyncOperation;
/**
 *  The SFAAsyncOperationScheduledError is used to inform user if a SFIAsyncOperation was scheduled as result of an API call.
 */
@interface SFAAsyncOperationScheduledError : SFAError
/**
 *  SFIAsyncOperation object representing operation that got scheduled.
 */
@property (nonatomic, strong, readonly) SFIAsyncOperation *scheduledAsyncOperation;
/**
 *  Initializes SFAAsyncOperationScheduledError with provided parameters.
 *
 *  @param asyncOperation SFIAsyncOperation representing operation that got scheduled.
 *
 *  @return Returns initialized object of SFAAsyncOperationScheduledError or nil if an object could not be created for some reason.
 */
+ (instancetype)errorWithScheduleAsyncOperation:(SFIAsyncOperation *)asyncOperation;

@end
