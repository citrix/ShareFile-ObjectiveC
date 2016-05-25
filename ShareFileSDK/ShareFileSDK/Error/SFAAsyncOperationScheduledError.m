#import "SFAAsyncOperationScheduledError.h"

NSString *const kSFAErrorScheduledAsyncOperation = @"scheduledAsyncOperation";

@implementation SFAAsyncOperationScheduledError

- (SFAsyncOperation *)scheduledAsyncOperation {
    return self.userInfo[kSFAErrorScheduledAsyncOperation];
}

+ (instancetype)errorWithScheduleAsyncOperation:(SFAsyncOperation *)asyncOperation {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    dictionary[kSFAErrorMessage] = SFAAsyncOperationSchedule;
    dictionary[kSFAErrorType] = [NSNumber numberWithInteger:SFAErrorTypeAsyncOperationScheduledError];
    if (asyncOperation) {
        dictionary[kSFAErrorScheduledAsyncOperation] = asyncOperation;
    }
    return [[[self class] alloc] initWithDomain:NSStringFromClass([self class]) code:202 userInfo:[dictionary copy]];
}

- (NSString *)description {
    NSMutableString *desc = [[super description] mutableCopy];
    [desc appendFormat:@"\n%@:%@", SFAAsyncOperationSchedule, self.scheduledAsyncOperation];
    return [desc copy];
}

@end
