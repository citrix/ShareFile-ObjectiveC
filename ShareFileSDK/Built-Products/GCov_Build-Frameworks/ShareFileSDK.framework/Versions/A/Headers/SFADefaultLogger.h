#import <Foundation/Foundation.h>
#import "SFALogger.h"
/**
 *  The SFADefaultLogger class implements SFALogger protocol for logging messages. The messaged are logged using NSLog.
 */
@interface SFADefaultLogger : NSObject <SFALogger>

@end
