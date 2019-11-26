#import <Foundation/Foundation.h>
#import "SFALogger.h"
#import "SFAActionStopwatch.h"
/**
   The SFALoggingProvider class uses logger conforming to SFALogger protocl to provide logging.
 */
@interface SFALoggingProvider : NSObject
/**
 *  Initializes the SFALoggingProvider with SFALogger.
 *
 *  @param logger Object conforming SFALogger protocol.
 *
 *  @return Returns initialized object of SFALoggingProvider or nil if an object could not be created for some reason.
 */
- (instancetype)initWithLogger:(id <SFALogger> )logger;
/**
 *  Checks if trace logs are enabled.
 *
 *  @return Returns YES if trace logs are enabled.
 */
- (BOOL)isTraceEnabled;
/**
 *  Checks if debug logs are enabled.
 *
 *  @return Returns YES if debug logs are enabled.
 */
- (BOOL)isDebugEnabled;
/**
 *  Checks if info logs are enabled.
 *
 *  @return Returns YES if info logs are enabled.
 */
- (BOOL)isInformationEnabled;
/**
 *  Checks if warning logs are enabled.
 *
 *  @return Returns YES if warning logs are enabled.
 */
- (BOOL)isWarningEnabled;
/**
 *  Checks if error logs are enabled.
 *
 *  @return Returns YES if error logs are enabled.
 */
- (BOOL)isErrorEnabled;
/**
 *  Checks if fatal logs are enabled.
 *
 *  @return Returns YES if fatal logs are enabled.
 */
- (BOOL)isFatalEnabled;
/**
 *  Logs SFAActionStopwatch information if trace logs are enable.
 *
 *  @param actionStopwatch SFAActionStopwatch to be logged.
 */
- (void)traceActionStopWatch:(SFAActionStopwatch *)actionStopwatch;
/**
 *  Logs message with logLevel SFALogLevelTrace.
 *
 *  @param format NSString format to be logged.
 */
- (void)traceWithFormat:(NSString *)format, ...;
/**
 *  Logs message with logLevel SFALogLevelTrace
 *
 *  @param error  NSError to be logged.
 *  @param format NSString format to be logged.
 */
- (void)traceWithError:(NSError *)error format:(NSString *)format, ...;
/**
 *  Logs message with logLevel SFALogLevelDebug.
 *
 *  @param format NSString format to be logged.
 */
- (void)debugWithFormat:(NSString *)format, ...;
/**
 *  Logs message with logLevel SFALogLevelDebug.
 *
 *  @param error  NSError to be logged.
 *  @param format NSString format to be logged.
 */
- (void)debugWithError:(NSError *)error format:(NSString *)format, ...;
/**
 *  Logs message with logLevel SFALogLevelInfo.
 *
 *  @param format NSString format to be logged.
 */
- (void)infoWithFormat:(NSString *)format, ...;
/**
 *  Logs message with logLevel SFALogLevelInfo.
 *
 *  @param error  NSError to be logged.
 *  @param format NSString format to be logged.
 */
- (void)infoWithError:(NSError *)error format:(NSString *)format, ...;
/**
 *  Logs message with logLevel SFALogLevelWarn.
 *
 *  @param format NSString format to be logged.
 */
- (void)warnWithFormat:(NSString *)format, ...;
/**
 *  Logs message with logLevel SFALogLevelWarn.
 *
 *  @param error  NSError to be logged.
 *  @param format NSString format to be logged.
 */
- (void)warnWithError:(NSError *)error format:(NSString *)format, ...;
/**
 *  Logs message with logLevel SFALogLevelError.
 *
 *  @param format NSString format to be logged.
 */
- (void)errorWithFormat:(NSString *)format, ...;
/**
 *  Logs message with logLevel SFALogLevelError.
 *
 *  @param error  NSError to be logged.
 *  @param format NSString format to be logged.
 */
- (void)errorWithError:(NSError *)error format:(NSString *)format, ...;
/**
 *  Logs message with logLevel SFALogLevelFatal.
 *
 *  @param format NSString format to be logged.
 */
- (void)fatalWithFormat:(NSString *)format, ...;
/**
 *  Logs message with logLevel SFALogLevelFatal.
 *
 *  @param error  NSError to be logged.
 *  @param format NSString format to be logged.
 */
- (void)fatalWithError:(NSError *)error format:(NSString *)format, ...;

@end
