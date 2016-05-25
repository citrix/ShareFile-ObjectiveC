#import "SFAEqualToFilter.h"

@interface SFAEqualToFilter ()

@property (strong, nonatomic) NSString *functionName;

- (instancetype)initWithFunctionName:(NSString *)functionName propertyName:(NSString *)propertyName value:(NSString *)value eqValue:(BOOL)eqValue;

@end
