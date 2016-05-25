#import "SFAModelClassMapper.h"

@interface SFAModelClassMapper ()

@property (strong, nonatomic) NSMutableDictionary *mappedClasses;

@end

@implementation SFAModelClassMapper

- (NSMutableDictionary *)mappedClasses {
    if (!_mappedClasses) {
        _mappedClasses = [NSMutableDictionary new];
    }
    return _mappedClasses;
}

+ (instancetype)sharedModelClassMapper {
    static dispatch_once_t oncePredicate;
    static SFAModelClassMapper *mapper;
    dispatch_once(&oncePredicate, ^{ mapper = [SFAModelClassMapper new]; });
    return mapper;
}

+ (void)addMappingForDefaultModelClass:(Class)defaultModelClass withNewModelClass:(Class)newModelClass {
    if (defaultModelClass && newModelClass && [newModelClass isSubclassOfClass:defaultModelClass]) {
        SFAModelClassMapper *mapper = [[self class] sharedModelClassMapper];
        mapper.mappedClasses[NSStringFromClass(defaultModelClass)] = newModelClass;
    }
    else {
        NSAssert(NO, @"One of/Both defaultModelClass or newModelClass parameter(s) is/are nil OR newModelClass is not subclass of defaultModelClass.");
    }
}

+ (void)removeMappingForDefaultModelClass:(Class)defaultModelClass {
    if (defaultModelClass) {
        SFAModelClassMapper *mapper = [[self class] sharedModelClassMapper];
        [mapper.mappedClasses removeObjectForKey:NSStringFromClass(defaultModelClass)];
    }
    else {
        NSAssert(NO, @"defaultModelClass is nil.");
    }
}

+ (void)removeAllMappings {
    SFAModelClassMapper *mapper = [[self class] sharedModelClassMapper];
    [mapper.mappedClasses removeAllObjects];
}

+ (Class)mappedModelClassForDefaultModelClass:(Class)defaultModelClass {
    if (defaultModelClass) {
        SFAModelClassMapper *mapper = [[self class] sharedModelClassMapper];
        Class mappedClass = mapper.mappedClasses[NSStringFromClass(defaultModelClass)];
        if (mappedClass != nil) {
            return mappedClass;
        }
    }
    return defaultModelClass;
}

@end
