#import "SFAStopwatch.h"

@interface SFAActionStopwatch ()

@property (strong, nonatomic) id <SFAStopwatch> stopwatch;
@property (strong, nonatomic) SFALoggingProvider *loggingProvider;

@end

@implementation SFAActionStopwatch

- (instancetype)initWithName:(NSString *)name loggingProvider:(SFALoggingProvider *)loggingProvider {
    self = [super init];
    if (self) {
        self.stopwatch = [SFAStopwatch new];
        self.name = name;
        self.loggingProvider = loggingProvider;
        [self start];
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (void)start {
    if ([self.loggingProvider isTraceEnabled]) {
        [_stopwatch start];
    }
}

- (void)stop {
    if ([self.loggingProvider isTraceEnabled]) {
        [_stopwatch stop];
    }
}

- (NSTimeInterval)elapsedTime {
    return [_stopwatch elapsedTime];
}

@end
