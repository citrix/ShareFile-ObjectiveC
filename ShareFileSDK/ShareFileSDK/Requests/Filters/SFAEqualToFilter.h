#import <Foundation/Foundation.h>
#import "SFAFilter.h"

/**
 *  Base Filter class conforming to SFAFilter protocol. Implements filter based on a filter function result evaluating to true or false.
 */
@interface SFAEqualToFilter : NSObject <SFAFilter>

/**
 *  Property name on which filter should be applied.
 */
@property (strong, nonatomic) NSString *propertyName;
/**
 *  Value passed to filter function as first parameter.
 */
@property (strong, nonatomic) NSString *value;
/**
 *  YES if filter function should evaluate to true with given property and value.
 */
@property (nonatomic, getter = isEq) BOOL eq;

@end
