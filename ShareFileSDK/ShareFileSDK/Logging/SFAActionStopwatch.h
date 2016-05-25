#import <Foundation/Foundation.h>

@class SFALoggingProvider;
/**
 *  The SFAActionStopwatch class provides basic functionality of a stopwatch. It can be used for timing asynchronous operations.
 */
@interface SFAActionStopwatch : NSObject
/**
 *  Name of SFAActionStopwatch. This can be used to uniquely identify instance of SFAActionStopwatch.
 */
@property (nonatomic, strong) NSString *name;
/**
 *  Initializes SFActionStopwatch with provided parameters.
 *
 *  @param name            NSString representing name of the action stopwatch.
 *  @param loggingProvider SFALoggingProvider object.
 *
 *  @return Returns initialized object of SFAActionStopwatch or nil if an object could not be created for some reason.
 */
- (instancetype)initWithName:(NSString *)name loggingProvider:(SFALoggingProvider *)loggingProvider;
/**
 *  Start the stopwatch if trace logging level is enabled.
 */
- (void)start;
/**
 *  Stop the stopwatch if trace logging level is enabled.
 */
- (void)stop;
/**
 *  Calculates and returns the time elapsed since start if watch is running or time elaspsed between start and stop if watch is not running.
 *
 *  @return Returns NSTimeInterval representing time elapsed.
 */
- (NSTimeInterval)elapsedTime;

@end
