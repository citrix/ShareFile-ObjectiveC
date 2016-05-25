#import "SFASharedThreadManager.h"

@implementation SFASharedThreadManager
static NSThread *_sharedConnectionThread;

#pragma mark - Threading

+ (NSThread *)sharedThread {
    static NSThread *sharedThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^
    {
        sharedThread = [[NSThread alloc] initWithTarget:self selector:@selector(runSharedThreadRunLoop) object:nil];
        [sharedThread start];
    });
    return sharedThread;
}

+ (void)runSharedThreadRunLoop {
    @autoreleasepool
    {
        [[NSThread currentThread] setName:@"ShareFile Shared Thread"];
        // Current Runloop
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        // Add port so run loop never stops.
        NSPort *port = [NSPort port];
        [runLoop addPort:port forMode:NSDefaultRunLoopMode];
        BOOL runAlways = YES;
        while (runAlways) {
            @autoreleasepool
            {
                // Start the run loop but return after each source is handled.
                [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
        }
        [runLoop removePort:port forMode:NSDefaultRunLoopMode];
    }
}

@end
