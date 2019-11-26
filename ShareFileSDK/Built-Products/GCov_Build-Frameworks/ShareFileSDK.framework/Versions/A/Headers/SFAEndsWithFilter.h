#import <Foundation/Foundation.h>
#import "SFAEqualToFilter.h"

/**
 * SFAEndsWithFilter is an SFAEqualToFilter with 'endswith' function.
 */
@interface SFAEndsWithFilter : SFAEqualToFilter

/**
 *  Initializes SFAEndsWithFilter with provided paramters
 *
 *  @param propertyName NSString property name on which filter should be applied.
 *  @param value        NSString value passed to filter function as first parameter.
 *  @param isEqual      BOOL YES if filter function should evaluate to true with given property and value.
 *
 *  @return Initialized SFAEndsWithFilter object.
 */
- (instancetype)initWithPropertyName:(NSString *)propertyName value:(NSString *)value isEqual:(BOOL)isEqual;

@end
