#import "SFAStartsWithFilter.h"
#import "SFAEqualToFilterProtected.h"

@implementation SFAStartsWithFilter

- (instancetype)initWithPropertyName:(NSString *)propertyName value:(NSString *)value isEqual:(BOOL)isEqual {
    self = [super initWithFunctionName:@"startswith" propertyName:propertyName value:value eqValue:isEqual];
    if (self) {
    }
    return self;
}

@end
