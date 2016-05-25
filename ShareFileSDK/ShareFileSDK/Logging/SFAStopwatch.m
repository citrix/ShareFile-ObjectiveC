#import "SFAStopwatch.h"

@implementation SFAStopwatch

- (void)start {
    if (!_running) {
        _running = YES;
        _startTime = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)stop {
    if (_running) {
        _running = NO;
        _stopTime = [[NSDate date] timeIntervalSince1970];
    }
}

- (NSTimeInterval)elapsedTime {
    if (_running) {
        return [[NSDate date] timeIntervalSince1970] - _startTime;
    }
    else {
        return _stopTime - _startTime;
    }
}

- (BOOL)isRunning {
    return _running;
}

@end
