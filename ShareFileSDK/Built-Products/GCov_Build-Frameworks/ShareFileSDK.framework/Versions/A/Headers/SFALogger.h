#import <Foundation/Foundation.h>
#import "SFALogLevel.h"
/**
 * The SFALogger protocol contains methods that should be implemented by the class providing logging functionality.
 */
@protocol SFALogger <NSObject>

/**
 * SFALogLevel option value representing currently set log levels.
 */
@property (atomic) SFALogLevel logLevel;
/**
 *  Logs message with logLevel SFALogLevelTrace.
 *
 *  @param message NSString message to be logged.
 */
- (void)trace:(NSString *)message;
/**
 *  Logs error and message with logLevel SFALogLevelTrace.
 *
 *  @param error   NSError to be logged.
 *  @param message NSString message to be logged.
 */
- (void)traceWithError:(NSError *)error message:(NSString *)message;
/**
 *  Logs message with logLevel SFALogLevelDebug.
 *
 *  @param message NSString message to be logged.
 */
- (void)debug:(NSString *)message;
/**
 *  Logs error and message with logLevel SFALogLevelDebug.
 *
 *  @param error   NSError to be logged.
 *  @param message NSString message to be logged.
 */
- (void)debugWithError:(NSError *)error message:(NSString *)message;
/**
 *  Logs message with logLevel SFALogLevelInfo.
 *
 *  @param message NSString message to be logged.
 */
- (void)info:(NSString *)message;
/**
 *  Logs error and message with logLevel SFALogLevelInfo.
 *
 *  @param error   NSError to be logged.
 *  @param message NSString message to be logged.
 */
- (void)infoWithError:(NSError *)error message:(NSString *)message;
/**
 *  Logs message with logLevel SFALogLevelWarn.
 *
 *  @param message NSString message to be logged.
 */
- (void)warn:(NSString *)message;
/**
 *  Logs error and message with logLevel SFALogLevelWarn.
 *
 *  @param error   NSError to be logged.
 *  @param message NSString message to be logged.
 */
- (void)warnWithError:(NSError *)error message:(NSString *)message;
/**
 *  Logs message with logLevel SFALogLevelError.
 *
 *  @param message message to be logged.
 */
- (void)error:(NSString *)message;
/**
 *  Logs error and message with logLevel SFALogLevelError.
 *
 *  @param error   NSError to be logged
 *  @param message NSString message to be logged.
 */
- (void)errorWithError:(NSError *)error message:(NSString *)message;
/**
 *  Logs message with logLevel SFALogLevelFatal.
 *
 *  @param message NSString message to be logged.
 */
- (void)fatal:(NSString *)message;
/**
 *  Logs error and message with logLevel SFALogLevelFatal.
 *
 *  @param error   NSError to be logged.
 *  @param message NSString message to be logged.
 */
- (void)fatalWithError:(NSError *)error message:(NSString *)message;

@end
