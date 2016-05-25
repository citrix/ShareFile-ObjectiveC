#import "SFABaseTask.h"
#import "SFABaseTaskProtected.h"

@implementation SFABaseTask

static NSString *const SFAFinishedKey = @"isFinished";
static NSString *const SFAExecutingKey = @"isExecuting";

@synthesize interactiveHandler = _interactiveHandler;
@synthesize completionCallback = _completionCallback;
@synthesize cancelCallback = _cancelCallback;

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lock = [NSObject new];
    }
    return self;
}

- (void)start {
    if ([self markStateStarted]) {
        [self startForcefully];
    }
    else if (self.isCancelled) { // This is needed in case the task was cancelled before start was called, we need to mark it finished at this point.
        [self taskCompleted:nil shouldCancelIfNotStarted:YES];
    }
}

- (void)cancel {
    [super cancel];
    if (self.isCancelled) {
        [self taskCompleted:nil];
    }
}

- (BOOL)isExecuting {
    return self.state == SFATaskStateExecuting;
}

- (BOOL)isFinished {
    return self.state == SFATaskStateFinished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)markStateStarted {
    // This syncronize is needed so two threads can not start operation
    // simultaneously.
    @synchronized(self.lock) // To avoid deadlock on self. As KVO observer might
    // shift to another thread with
    // performOnThreadAndWait which will create
    // deadlock on self.
    {
        if (!self.isFinished && !self.isExecuting && !self.isCancelled) {
            [self willChangeValueForKey:SFAExecutingKey];
            self.state = SFATaskStateExecuting;
            [self didChangeValueForKey:SFAExecutingKey];
            return YES;
        }
        else {
            return NO;
        }
    }
}

- (void)startForcefully {
}

- (void)taskCompleted:(id)retVal {
    [self taskCompleted:retVal shouldCancelIfNotStarted:NO];
}

- (void)taskCompleted:(id)retVal shouldCancelIfNotStarted:(BOOL)shouldCancelIfNotStarted {
    // This function could have been called from various threads simultaneously.
    // But only one thread will get past the synchronized block and only once in
    // operation lifetime.
    @synchronized(self.lock) // To avoid deadlock on self. As KVO observer might
    // shift to another thread with
    // performOnThreadAndWait which will create deadlock
    // on self.
    {
        if (!self.isFinished) {
            if (self.isExecuting) {
                [self willChangeValueForKey:SFAExecutingKey];
                [self willChangeValueForKey:SFAFinishedKey];
                self.state = SFATaskStateFinished;
                [self didChangeValueForKey:SFAExecutingKey];
                [self didChangeValueForKey:SFAFinishedKey];
            }
            else if (shouldCancelIfNotStarted) {
                [self willChangeValueForKey:SFAFinishedKey];
                self.state = SFATaskStateFinished;
                [self didChangeValueForKey:SFAFinishedKey];
            }
            else {
                return;
            }
        }
        else {
            return;
        }
    }
    [self didMarkFinishedWithValue:retVal];
}

- (void)didMarkFinishedWithValue:(id)retVal {
}

+ (BOOL)automaticallyNotifiesObserversOfFinished {
    return NO;
}

+ (BOOL)automaticallyNotifiesObserversOfExecuting {
    return NO;
}

@end
