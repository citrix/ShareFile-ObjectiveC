#import "SFATypeFilter.h"
#import "SFAEqualToFilterProtected.h"
#import "SFAJSONToODataMapper.h"

@implementation SFATypeFilter

- (instancetype)initWithType:(NSString *)sfType expression:(NSString *)expression {
    self = [super initWithFunctionName:@"isof" propertyName:[NSString stringWithFormat:@"%@%@", kSFOdataModelPrefix, sfType] value:expression eqValue:YES];
    if (self) {
    }
    return self;
}

- (NSString *)description {
    if (self.value) {
        return [NSString stringWithFormat:@"%@(%@,'%@')", self.functionName, self.value, self.propertyName];
    }
    else {
        return [NSString stringWithFormat:@"%@('%@')", self.functionName, self.propertyName];
    }
}

@end
