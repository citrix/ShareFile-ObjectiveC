#import "SFAEqualToFilter.h"
#import "SFAEqualToFilterProtected.h"

@implementation SFAEqualToFilter

#pragma mark - Protected

- (instancetype)initWithFunctionName:(NSString *)functionName propertyName:(NSString *)propertyName value:(NSString *)value eqValue:(BOOL)eqValue {
    self = [super init];
    if (self) {
        self.functionName = functionName;
        self.propertyName = propertyName;
        self.value = value;
        self.eq = eqValue;
    }
    return self;
}

#pragma mark - Public

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@(%@,'%@') eq %@", self.functionName, self.propertyName, self.value, self.eq ? @"true" : @"false"];
}

@end
