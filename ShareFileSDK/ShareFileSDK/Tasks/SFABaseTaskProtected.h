#import "SFABaseTask.h"

typedef NS_ENUM (NSInteger, SFATaskState) {
    SFATaskStateNotStarted = 0,
    SFATaskStateExecuting = 1,
    SFATaskStateFinished = 2
};

@interface SFABaseTask ()

@property (atomic) SFATaskState state;
@property (nonatomic, strong) NSObject *lock;

- (BOOL)markStateStarted;
- (void)startForcefully;
- (void)taskCompleted:(id)retVal;
- (void)didMarkFinishedWithValue:(id)retVal;

@end
