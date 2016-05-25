#import <Foundation/Foundation.h>
#import "SFAEqualToFilter.h"

/**
 * SFAStartsWithFilter is an SFAEqualToFilter with 'startswith' function.
 */
@interface SFAStartsWithFilter : SFAEqualToFilter
/**
 *  Initializes SFAStartsWithFilter with provided paramters
 *
 *  @param propertyName NSString property name on which filter should be applied.
 *  @param value        NSString value passed to filter function as first parameter.
 *  @param isEqual      BOOL YES if filter function should evaluate to true with given property and value.
 *
 *  @return Initialized SFAStartsWithFilter object.
 */
- (instancetype)initWithPropertyName:(NSString *)propertyName value:(NSString *)value isEqual:(BOOL)isEqual;

@end
