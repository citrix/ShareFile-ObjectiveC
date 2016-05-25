#import <Foundation/Foundation.h>

@protocol SFAStopwatch <NSObject>

- (void)start;
- (void)stop;
- (BOOL)isRunning;
- (NSTimeInterval)elapsedTime;

@end

@interface SFAStopwatch : NSObject <SFAStopwatch> {
    NSTimeInterval _startTime;
    NSTimeInterval _stopTime;
    BOOL _running;
}

@end
