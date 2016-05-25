#import "SFADefaultLogger.h"

@implementation SFADefaultLogger

@synthesize logLevel = _logLevel;

- (instancetype)init {
    self = [super init];
    if (self) {
#ifdef DEBUG
        self.logLevel = SFALogLevelInfo | SFALogLevelWarn | SFALogLevelError | SFALogLevelFatal;
#else
        self.logLevel = SFALogLevelError;
#endif
    }
    return self;
}

- (void)trace:(NSString *)message {
    NSLog(@"%@: %@", SFALogTrace, message);
}

- (void)traceWithError:(NSError *)error message:(NSString *)message {
    NSLog(@"%@: %@ : %@", SFALogTrace, message, error);
}

- (void)debug:(NSString *)message {
    NSLog(@"%@: %@", SFALogDebug, message);
}

- (void)debugWithError:(NSError *)error message:(NSString *)message {
    NSLog(@"%@: %@ : %@", SFALogDebug, message, error);
}

- (void)info:(NSString *)message {
    NSLog(@"%@: %@", SFALogInfo, message);
}

- (void)infoWithError:(NSError *)error message:(NSString *)message {
    NSLog(@"%@: %@ : %@", SFALogInfo, message, error);
}

- (void)warn:(NSString *)message {
    NSLog(@"%@: %@", SFALogWarn, message);
}

- (void)warnWithError:(NSError *)error message:(NSString *)message {
    NSLog(@"%@: %@ : %@", SFALogWarn, message, error);
}

- (void)error:(NSString *)message {
    NSLog(@"%@: %@", SFALogError, message);
}

- (void)errorWithError:(NSError *)error message:(NSString *)message {
    NSLog(@"%@: %@ : %@", SFALogError, message, error);
}

- (void)fatal:(NSString *)message {
    NSLog(@"%@: %@", SFALogFatal, message);
}

- (void)fatalWithError:(NSError *)error message:(NSString *)message {
    NSLog(@"%@: %@ : %@", SFALogFatal, message, error);
}

@end
