#import "SFAEndsWithFilter.h"
#import "SFAEqualToFilterProtected.h"

@implementation SFAEndsWithFilter

- (instancetype)initWithPropertyName:(NSString *)propertyName value:(NSString *)value isEqual:(BOOL)isEqual {
    self = [super initWithFunctionName:@"endswith" propertyName:propertyName value:value eqValue:isEqual];
    if (self) {
    }
    return self;
}

@end
