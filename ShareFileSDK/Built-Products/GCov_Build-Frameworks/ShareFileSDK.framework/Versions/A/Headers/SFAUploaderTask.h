#import "SFATransferTask.h"
#import "SFACompositeUploaderTask.h"

@interface SFAUploaderTask : SFAHttpTask

// This is convenience initializer override initWithDelegate:contextObject:callbackQueue:client: for any implementation changes.
- (instancetype)initWithDelegate:(id <SFACompositeTaskDelegate> )delegate client:(SFAClient *)client;
// This is convenience initializer override initWithDelegate:contextObject:callbackQueue:client: for any implementation changes.
- (instancetype)initWithDelegate:(id <SFACompositeTaskDelegate> )delegate contextObject:(id)contextObj client:(SFAClient *)client;

@end
