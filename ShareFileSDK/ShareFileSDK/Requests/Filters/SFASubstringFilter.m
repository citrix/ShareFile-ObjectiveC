#import "SFASubstringFilter.h"
#import "SFAEqualToFilterProtected.h"

@implementation SFASubstringFilter

- (instancetype)initWithPropertyName:(NSString *)propertyName value:(NSString *)value isEqual:(BOOL)isEqual {
    self = [super initWithFunctionName:@"substringof" propertyName:propertyName value:value eqValue:isEqual];
    if (self) {
    }
    return self;
}

@end
