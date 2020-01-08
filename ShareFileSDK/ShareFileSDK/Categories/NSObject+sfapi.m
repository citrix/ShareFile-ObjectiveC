#import "NSDictionary+sfapi.h"
#import "NSDate+sfapi.h"
#import "NSString+sfapi.h"
#import "SFAJSONToODataMapper.h"
#import <objc/message.h>

#pragma mark - SFIObjectPropertyContainer

@interface SFIObjectPropertyContainer : NSObject
{
}

@property (nonatomic, strong) NSMutableArray *parentPropertyNames;
@property (nonatomic, strong) NSMutableArray *propertyNames;

@property (nonatomic, strong) NSMutableDictionary *allPropertyNamesAndTypes;

@end

@implementation SFIObjectPropertyContainer

@end

#pragma mark - NSObject(sfapi)

@implementation NSObject (sfapi)

@dynamic defaultModel;

#pragma mark - SFIODataObject mapping support

- (void)setDefaultModel:(NSString *)defaultModel {
    objc_setAssociatedObject(self, @selector(defaultModel), defaultModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)defaultModel {
    return objc_getAssociatedObject(self, @selector(defaultModel));
}

#pragma mark - JSON Related

/**
 *  Take from latest NSObject+sfapi.m ... in order to get around posting "Description" and "description" when creating folders and notes
 */
/**
 *  Helper function to fetch all properties for any given Class object.
 *
 *  @param class The class for which property names are to be fetched.
 *
 *  @return an array of NSString objects representing all property names of a given class
 */
+ (NSMutableArray *)propertyNamesForClass:(Class)class {
    return [self propertyNamesForClass:class filter:nil];
}

/**
 *  Take from latest NSObject+sfapi.m ... in order to get around posting "Description" and "description" when creating folders and notes
 */
/**
 *  Returns a filtered list of properties for any given Class.
 *
 *  @param class  The class for which property names are to be fetched
 *  @param filter A set of NSString objects to be used as a filter.  Values included in this set will not be returned.
 *
 *  @return an array of NSString objects represeting a filtered subset of property names for a given class
 */
+ (NSMutableArray *)propertyNamesForClass:(Class)class filter:(NSSet *)filter {
    NSMutableArray *propertyNames = [NSMutableArray array];
    
    unsigned int propCount, i;
    objc_property_t *props = class_copyPropertyList(class, &propCount);
    for (i = 0; i < propCount; i++) {
        objc_property_t prop = props[i];
        const char *propNameCString = property_getName(prop);
        if (propNameCString) {
            NSString *propName = [NSString stringWithCString:propNameCString encoding:NSUTF8StringEncoding];
            if (propName.length > 0 && ![filter containsObject:propName]) {
                [propertyNames addObject:propName];
            }
        }
    }
    free(props);
    return propertyNames;
}

static NSMutableDictionary *__strong _odataModelCache;

+ (void)initOdataObjectCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ _odataModelCache = [[NSMutableDictionary alloc] init]; });
}

+ (NSMutableArray *)propertyNamesIncludingInheritedProperties:(BOOL)includeInherited {
    [self initOdataObjectCache];
    
    NSMutableArray *result;
    
    NSString *className = NSStringFromClass([self class]);
    SFIObjectPropertyContainer *classPropertyContainer = [_odataModelCache objectForKey:className];
    
    if (!classPropertyContainer) {
        classPropertyContainer = [[SFIObjectPropertyContainer alloc] init];
    }
    
    NSMutableArray *parentPropertyNames = nil;
    if (includeInherited) {
        if (classPropertyContainer) {
            parentPropertyNames = classPropertyContainer.parentPropertyNames;
        }
        
        if (!parentPropertyNames) {
            if (![NSStringFromClass([self superclass]) isEqualToString:SFANsObjectClassName]) {
                if ([[self superclass] respondsToSelector:@selector(propertyNames)]) {
                    @try {
                        parentPropertyNames = [[self superclass] propertyNames];
                    }
                    @catch (NSException *ex)
                    {
                    }
                    
                    if (classPropertyContainer) {
                        classPropertyContainer.parentPropertyNames = [parentPropertyNames mutableCopy];
                    }
                }
            }
        }
    }
    
    NSMutableArray *mPropertyNames = [classPropertyContainer.propertyNames mutableCopy];
    
    /**
     *  Take from latest NSObject+sfapi.m ... in order to get around posting "Description" and "description" when creating folders and notes
     */
    /**
       We filter "base" properties that are contained by NSObject.   In Xcode 6 Beta 4 a bug was introduced that
       makes children of NSObject class return NSObject properties.
       
       This in turn may cause a stack overflow given a circular recursion between debugDescription and JSON mapping logic here.
       
       To prevent this from happening, we use a set of known properties fetched from NSObject as a filter.
     */
    static NSSet *baseObjFilterProperties;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *properties = [self propertyNamesForClass:[NSObject class]];
        baseObjFilterProperties = [NSSet setWithArray:properties];
    });
    
    if (!mPropertyNames) {
        mPropertyNames = [self propertyNamesForClass:[self class] filter:baseObjFilterProperties];
        if (classPropertyContainer) {
            classPropertyContainer.propertyNames = [mPropertyNames mutableCopy];
        }
        
        result = mPropertyNames;
    }
    else {
        result = mPropertyNames;
    }
    
    if (parentPropertyNames.count > 0) {
        [result addObjectsFromArray:parentPropertyNames];
    }
    
    if (classPropertyContainer) {
        [_odataModelCache setObject:classPropertyContainer forKey:className];
    }
    
    return result;
}

+ (NSMutableArray *)propertyNames {
    return [self propertyNamesIncludingInheritedProperties:YES];
}

+ (NSMutableDictionary *)propertyNamesAndTypes {
    [self initOdataObjectCache];
    
    NSMutableDictionary *result = nil;
    NSMutableArray *allPropertyNames = [self propertyNames];
    SFIObjectPropertyContainer *classPropContainer = nil;
    NSString *className = NSStringFromClass([self class]);
    
    if (className.length > 0) {
        classPropContainer = [_odataModelCache objectForKey:className];
    }
    
    if (classPropContainer && classPropContainer.allPropertyNamesAndTypes) {
        result = [classPropContainer.allPropertyNamesAndTypes mutableCopy];
    }
    else {
        result = [NSMutableDictionary dictionaryWithCapacity:allPropertyNames.count];
        @autoreleasepool
        {
            for (NSString *propName in allPropertyNames) {
                objc_property_t prop = class_getProperty([self class], [propName cStringUsingEncoding:NSUTF8StringEncoding]);
                if (prop) {
                    NSString *propertyType = [[self class] propertyTypeForProperty:prop];
                    if (propertyType.length > 0) {
                        [result setObject:propertyType forKey:propName];
                    }
                }
            }
        }
        
        if (classPropContainer) {
            classPropContainer.allPropertyNamesAndTypes = [result mutableCopy];
        }
    }
    
    // save to cache
    if (classPropContainer) {
        [_odataModelCache setObject:classPropContainer forKey:className];
    }
    
    return result;
}

+ (NSString *)propertyTypeForProperty:(objc_property_t)property {
    static NSString *boolString = @"BOOL";
    static NSString *nsIntString = @"NSInteger";
    static NSString *nsUintString = @"NSUInteger";
    static NSString *luString = @"long long";
    static NSString *lluString = @"unsigned long long";
    static NSString *longString = @"long";
    static NSString *floatString = @"float";
    static NSString *doubleString = @"double";
    static NSString *idString = @"id";
    
    static NSString *boolPrefix = @"Tc";
    static NSString *nsIntPrefix = @"Ti";
    static NSString *nsUintPrefix = @"TI";
    static NSString *luPrefix = @"Tq";
    static NSString *lluPrefix = @"TQ";
    static NSString *longPrefix = @"Tl";
    static NSString *floatPrefix = @"Tf";
    static NSString *doublePrefix = @"Td";
    static NSString *objectPrefix = @"T@";
    
    NSString *result = nil;
    
    @try {
        const char *attribs = property_getAttributes(property);
        NSString *attributes = [NSString stringWithCString:attribs encoding:NSUTF8StringEncoding];
        if (attributes.length > 0) {
            // use NSScanner, it's faster and doesn't create extra strings... cuz we only care about the string before the first ","
            // NSArray *comps = [attributes componentsSeparatedByString:@","];
            
            NSString *dirtyType = nil;
            [[NSScanner scannerWithString:attributes] scanUpToString:@"," intoString:&dirtyType];
            
            if (dirtyType.length > 0) {
                if ([dirtyType rangeOfString:objectPrefix].location == 0) {
                    // object or id
                    if (dirtyType.length > 2) {
                        result = [[dirtyType substringFromIndex:2] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    }
                    else {
                        result = idString;
                    }
                }
                else if ([dirtyType rangeOfString:boolPrefix].location == 0) {
                    result = boolString;
                }
                else if ([dirtyType rangeOfString:nsIntPrefix].location == 0) {
                    result = nsIntString;
                }
                else if ([dirtyType rangeOfString:nsUintPrefix].location == 0) {
                    result = nsUintString;
                }
                else if ([dirtyType rangeOfString:luPrefix].location == 0) {
                    result = luString;
                }
                else if ([dirtyType rangeOfString:lluPrefix].location == 0) {
                    result = lluString;
                }
                else if ([dirtyType rangeOfString:longPrefix].location == 0) {
                    result = longString;
                }
                else if ([dirtyType rangeOfString:floatPrefix].location == 0) {
                    result = floatString;
                }
                else if ([dirtyType rangeOfString:doublePrefix].location == 0) {
                    result = doubleString;
                }
            }
        }
    }
    @catch (NSException *ex)
    {
        NSAssert(NO, @"NSObject<propertyTypeForProperty>(NSException):%@", ex);
    }
    
    return result;
}

+ (NSMutableArray *)jsonSafeArrayValue:(NSArray *)array {
    if (array) {
        NSMutableArray *result = [NSMutableArray arrayWithCapacity:array.count];
        @autoreleasepool
        {
            for (NSObject *subO in array) {
                if ([subO isKindOfClass:[NSString class]]) {
                    [result addObject:subO];
                }
                else if ([subO isKindOfClass:[NSNumber class]]) {
                    [result addObject:subO];
                }
                else if ([subO isKindOfClass:[NSArray class]]) {
                    [result addObject:[self jsonSafeArrayValue:(NSArray *)subO]];
                }
                else if ([subO isKindOfClass:[NSDate class]]) {
                    [result addObject:[(NSDate *)subO UTCStringRepresentation]];
                }
                else if ([subO isKindOfClass:[NSURL class]]) {
                    [result addObject:[(NSURL *)subO absoluteString]];
                }
                else if ([subO isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dictionaryRep = [self jsonSafeDictionary:(NSDictionary *)subO];
                    if (dictionaryRep) {
                        [result addObject:dictionaryRep];
                    }
                }
                else {
                    NSDictionary *dictionaryRep = [subO JSONDictionaryRepresentation];
                    if (!dictionaryRep) {
                        NSString *description = subO.description;
                        if (description.length > 0) {
                            [result addObject:description];
                        }
                    }
                    else {
                        [result addObject:dictionaryRep];
                    }
                }
            }
        }
        return result;
    }
    return nil;
}

+ (NSMutableDictionary *)jsonSafeDictionary:(NSDictionary *)dictionary {
    if (dictionary) {
        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:dictionary.count];
        NSArray *keys = [dictionary allKeys];
        @autoreleasepool
        {
            for (NSObject *o in keys) {
                if ([o isKindOfClass:[NSString class]]) {
                    id value = [dictionary objectForKey:o];
                    if ([value isKindOfClass:[NSString class]]) {
                        [result setObject:value forKey:(NSString *)o];
                    }
                    else if ([value isKindOfClass:[NSNumber class]]) {
                        [result setObject:value forKey:(NSString *)o];
                    }
                    else if ([value isKindOfClass:[NSArray class]]) {
                        [result setObject:[self jsonSafeArrayValue:(NSArray *)value] forKey:(NSString *)o];
                    }
                    else if ([value isKindOfClass:[NSDate class]]) {
                        [result setObject:[(NSDate *)value UTCStringRepresentation] forKey:(NSString *)o];
                    }
                    else if ([value isKindOfClass:[NSURL class]]) {
                        [result setObject:[(NSURL *)value absoluteString] forKey:(NSString *)o];
                    }
                    else if ([value isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dictionaryRep = [self jsonSafeDictionary:(NSDictionary *)value];
                        if (dictionaryRep) {
                            [result setObject:dictionaryRep forKey:(NSString *)o];
                        }
                    }
                    else {
                        NSDictionary *dictionaryRep = [value JSONDictionaryRepresentation];
                        if (dictionaryRep) {
                            [result setObject:dictionaryRep forKey:(NSString *)o];
                        }
                    }
                }
            }
        }
        return result;
    }
    return nil;
}

- (NSDictionary *)JSONDictionaryRepresentationWithExcludedProperties:(NSArray *)excludedPropertyNames orSelectProperties:(NSArray *)selectPropertyNames {
    NSDictionary *propsAndTypes = [[self class] propertyNamesAndTypes];
    NSArray *allPropNames = [propsAndTypes allKeys];
    NSString *propType = nil;
    NSMutableDictionary *dictionaryRep = [NSMutableDictionary dictionaryWithCapacity:allPropNames.count];
    
    @try {
        BOOL selectOnly = selectPropertyNames.count > 0;
        NSMutableArray *ignoredPropertyNames = nil;
        if (!selectOnly) {
            ignoredPropertyNames = [NSMutableArray array];
            [ignoredPropertyNames addObjectsFromArray:[self propertyNamesIgnoredByJSONSerializer]];
            [ignoredPropertyNames addObjectsFromArray:excludedPropertyNames];
        }
        
        @autoreleasepool
        {
            for (NSString *propName in allPropNames) {
                if ((selectOnly && [selectPropertyNames containsObject:propName]) || (!selectOnly && ![ignoredPropertyNames containsObject:propName])) {
                    id o = [self valueForKey:propName];
                    propType = [propsAndTypes objectForKey:propName];
                    if (o) {
                        if ([o isKindOfClass:[NSNumber class]]) {
                            if ([o isKindOfClass:NSClassFromString(@"NSCFBoolean")] || [propType isEqualToString:@"BOOL"]) {
                                //[jsonDictionary setObject:[(NSNumber*)o boolValue]?@"true":@"false" forKey:propName];
                                [dictionaryRep setObject:[NSNumber numberWithBool:[(NSNumber *)o boolValue] ? YES : NO] forKey:propName];
                            }
                            else {
                                [dictionaryRep setObject:o forKey:propName];
                            }
                        }
                        else if ([o isKindOfClass:[NSArray class]]) {
                            NSArray *array = [NSObject jsonSafeArrayValue:(NSArray *)o];
                            if (array) {
                                [dictionaryRep setObject:array forKey:propName];
                            }
                        }
                        else if ([o isKindOfClass:[NSSet class]] || [o isKindOfClass:[NSOrderedSet class]]) {
                            NSArray *array = [NSObject jsonSafeArrayValue:(NSArray *)o];
                            if (array) {
                                [dictionaryRep setObject:array forKey:propName];
                            }
                        }
                        else if ([o isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *dictionary = [NSObject jsonSafeDictionary:(NSDictionary *)o];
                            if (dictionary) {
                                [dictionaryRep setObject:dictionary forKey:propName];
                            }
                        }
                        else if ([o isKindOfClass:[NSURL class]]) {
                            [dictionaryRep setObject:[(NSURL *)o absoluteString] forKey:propName];
                        }
                        else if ([o isKindOfClass:[NSString class]]) {
                            [dictionaryRep setObject:o forKey:propName];
                        }
                        else if ([o isKindOfClass:[NSDate class]]) {
                            NSString *dateAsString = [(NSDate *)o UTCStringRepresentation];
                            [dictionaryRep setObject:dateAsString forKey:propName];
                        }
                        else {
                            NSMutableDictionary *linkedObjectDictionary = [[o JSONDictionaryRepresentation] mutableCopy];
                            if (linkedObjectDictionary.count > 0) {
                                [dictionaryRep setObject:linkedObjectDictionary forKey:propName];
                            }
                        }
                    }
                }
            }
        }
    }
    @catch (NSException *ex)
    {
        NSAssert(NO, @"NSObject<JSONDictionaryRepresentationWithExcludedProperties:orSelectProperties:>(NSException):%@", ex);
    }
    
    return [dictionaryRep copy];
}

- (NSMutableArray *)propertyNamesIgnoredByJSONSerializer {
    NSMutableArray *result = [NSMutableArray array];
    return result;
}

- (NSMutableDictionary *)dictionaryWithParsedOdataObjects:(NSDictionary *)dictionary {
    NSArray *allKeys = [dictionary allKeys];
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:dictionary.count];
    for (NSString *key in allKeys) {
        id item = [dictionary objectForKey:key];
        if ([item isKindOfClass:[NSDictionary class]]) {
            BOOL isMappingPossible;
            NSDictionary *dict = [self prepareParsingDictionaryFromItem:item returningIsMappingPossible:&isMappingPossible];
            
            if (isMappingPossible) {
                SFIODataObject *o = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
                if (o) {
                    [result setObject:o forKey:key];
                }
                else {
                    [result setObject:dict forKey:key];
                }
            }
            else {
                [result setObject:dict forKey:key];
            }
        }
        else if ([item isKindOfClass:[NSArray class]]) {
            [result setObject:[self arrayWithParsedOdataObjects:(NSArray *)item] forKey:key];
        }
        else {
            [result setObject:item forKey:key];
        }
    }
    return result;
}

- (NSMutableArray *)arrayWithParsedOdataObjects:(NSArray *)array {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[array count]];
    for (id item in array) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            BOOL isMappingPossible;
            NSDictionary *dict = [self prepareParsingDictionaryFromItem:item returningIsMappingPossible:&isMappingPossible];
            
            if (isMappingPossible) {
                SFIODataObject *o = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
                if (o) {
                    [result addObject:o];
                }
                else {
                    [result addObject:dict];
                }
            }
            else {
                [result addObject:dict];
            }
        }
        else if ([item isKindOfClass:[NSArray class]]) {
            [result addObject:[self arrayWithParsedOdataObjects:(NSArray *)item]];
        }
        else {
            [result addObject:item];
        }
    }
    return result;
}

/**
 *  Wrapper to assure that we will have proper API Model information to parse JSON into an API oData object
 *  (see updatedItemDictionary:withDefaultModel)
 *
 *  @param item                 item NSDictionary to prepare
 *  @param isMappingPossible    Will be set to TRUE if SFAJSONToODataMapper is possible; FALSE otherwise
 *
 *  @return original or updated dictionary
 */
- (NSDictionary *)prepareParsingDictionaryFromItem:(NSDictionary *)item returningIsMappingPossible:(BOOL *)isMappingPossible {
    NSDictionary *dict = item;
    NSString *metadata = [dict objectForKey:SFAOdataMetadataKey andClass:[NSString class]];  // try odata.metadata first
    if (metadata.length == 0) {
        metadata = [dict objectForKey:SFAODataTypeKey andClass:[NSString class]];  // try odata.type next
    }
    if (metadata.length == 0 && self.defaultModel) {
        // One last chance to parse model properly with our defaultModel
        NSDictionary *updatedItemDict = [self updatedItemDictionary:dict withDefaultModel:self.defaultModel];
        if (updatedItemDict) {
            dict = updatedItemDict;
            metadata = self.defaultModel;
        }
    }
    *isMappingPossible = (metadata.length > 0) ? TRUE : FALSE;
    return dict;
}

/**
 *  Update a JSON dictionary that is destined for SFAJSONToODataMapper parsing to meet minimum V3 API contract.
 *  Relaxed our reliance on odata.type or odata.metadata requirement in every JSON element being returned in a V3 API response
 *  Reason: odata.metadata in the main JSON body is enough per our API contract.
 *
 *  @param item NSDictionary to add a sparse "odata.metadata" element to
 *
 *  @return Updated NSDictionary ready for parsing; nil if item was not a NSDictionary
 */
- (NSDictionary *)updatedItemDictionary:(NSDictionary *)item withDefaultModel:defaultModel
{
    id result = nil;
    if ([item isKindOfClass:[NSDictionary class]]) {
        result = [NSMutableDictionary dictionaryWithDictionary:item];
        // Satisfy the metadata parser with a sample odata.metadata URL so that model shows up (using defaultModel)
        [result setObject:[NSString stringWithFormat:@"https://moose.sharefile.com/moose/v3/$metadata#ShareFile.Api.Models.%@", defaultModel] forKey:SFAOdataMetadataKey];
    }
    return [result copy];
}

- (NSDictionary *)setPropertiesWithJSONDictionary:(NSDictionary *)JSONdictionaryRepresentation andExclusionList:(NSArray *)excludedPropertyNames {
    if (JSONdictionaryRepresentation.count > 0) {
        NSDictionary *propNamesAndTypes = [[self class] propertyNamesAndTypes];
        NSArray *propNames = [propNamesAndTypes allKeys];
        NSArray *allDictionaryRepKeys = [JSONdictionaryRepresentation allKeys];
        NSMutableArray *unmappedDictionaryKeys = [NSMutableArray arrayWithArray:[allDictionaryRepKeys copy]];
        NSMutableDictionary *unmappedKVP = [NSMutableDictionary dictionary];
        
        NSMutableArray *ignoredPropertyNames = [NSMutableArray array];
        [ignoredPropertyNames addObjectsFromArray:excludedPropertyNames];
        [ignoredPropertyNames addObjectsFromArray:[self propertyNamesIgnoredByJSONSerializer]];
        
        BOOL isOdataObject = [self isKindOfClass:[SFIODataObject class]];
        
        for (NSString *propName in propNames) {
            if ([allDictionaryRepKeys containsObject:propName]) {
                if (![ignoredPropertyNames containsObject:propName]) {
                    id propValue = [JSONdictionaryRepresentation valueForKey:propName];
                    NSString *acceptedPropValueType = [propNamesAndTypes objectForKey:propName];
                    NSString *propValueType = NSStringFromClass([propValue class]);
                    
                    Class acceptedPropValueClass = NSClassFromString(acceptedPropValueType);
                    BOOL isSubClass = [[propValue class] isSubclassOfClass:acceptedPropValueClass];
                    BOOL isMember = [propValue isMemberOfClass:acceptedPropValueClass];
                    
                    // mutables
                    if (!isMember && !isSubClass) {
                        if ([acceptedPropValueType isEqualToString:SFAMutableArrayClassName] && [[propValue class] isSubclassOfClass:[NSArray class]]) {
                            propValue = [NSMutableArray arrayWithArray:(NSArray *)propValue];
                            propValueType = acceptedPropValueType;
                            isMember = YES;
                        }
                        else if ([acceptedPropValueType isEqualToString:SFAMutableStringClassName] && [[propValue class] isSubclassOfClass:[NSString class]]) {
                            propValue = [NSMutableString stringWithString:(NSString *)propValue];
                            propValueType = acceptedPropValueType;
                            isMember = YES;
                        }
                        else if ([acceptedPropValueType isEqualToString:SFAMutableDictionaryClassName] && [[propValue class] isSubclassOfClass:[NSDictionary class]]) {
                            propValue = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)propValue];
                            propValueType = acceptedPropValueType;
                            isMember = YES;
                        }
                        else if ([acceptedPropValueType isEqualToString:SFAMutableSetClassName] && ([[propValue class] isSubclassOfClass:[NSSet class]] || [[propValue class] isSubclassOfClass:[NSArray class]])) {
                            if ([[propValue class] isSubclassOfClass:[NSSet class]]) {
                                propValue = [NSMutableSet setWithSet:(NSSet *)propValue];
                            }
                            else {
                                propValue = [NSMutableSet setWithArray:(NSArray *)propValue];
                            }
                            propValueType = acceptedPropValueType;
                            isMember = YES;
                        }
                        else if ([acceptedPropValueClass isSubclassOfClass:[NSDate class]] && [propValue isKindOfClass:[NSString class]]) {
                            BOOL canSetStringRepInstead = NO;
                            NSString *stringRepPropName = nil;
                            if (isOdataObject) {
                                stringRepPropName = [NSString stringWithFormat:@"%@String", propName];
                                if ([propNames containsObject:stringRepPropName]) {
                                    canSetStringRepInstead = YES;
                                }
                            }
                            
                            if (canSetStringRepInstead) {
                                [self setValue:propValue forKey:stringRepPropName];
                            }
                            else {
                                if ([(NSString *)propValue length] > 0) {
                                    NSDate *date = [NSDate dateWithString:(NSString *)propValue];
                                    if (date) {
                                        propValue = date;
                                        propValueType = acceptedPropValueType;
                                        isMember = YES;
                                    }
                                }
                            }
                        }
                        else if ([acceptedPropValueClass isSubclassOfClass:[NSURL class]] && [propValue isKindOfClass:[NSString class]]) {
                            if ([(NSString *)propValue length] > 0) {
                                NSURL *url = [(NSString *)propValue URL];
                                if (url) {
                                    propValue = url;
                                    propValueType = acceptedPropValueType;
                                    isMember = YES;
                                }
                            }
                        }
                        else if ([acceptedPropValueClass isSubclassOfClass:[SFIODataObject class]]) {
                            if ([[propValue class] isSubclassOfClass:[NSDictionary class]] || [propValue isMemberOfClass:[NSDictionary class]]) {
                                [self setValue:[SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:(NSDictionary *)propValue] forKey:propName];
                                [unmappedDictionaryKeys removeObject:propName];
                            }
                        }
                    }
                    
                    if ([acceptedPropValueType isEqualToString:propValueType] || isSubClass || isMember) {
                        if ([propValue isKindOfClass:[NSArray class]]) {
                            [self setValue:[self arrayWithParsedOdataObjects:(NSArray *)propValue] forKey:propName];
                        }
                        else if ([propValue isKindOfClass:[NSDictionary class]]) {
                            [self setValue:[self dictionaryWithParsedOdataObjects:(NSDictionary *)propValue] forKey:propName];
                        }
                        else {
                            [self setValue:propValue forKey:propName];
                        }
                        [unmappedDictionaryKeys removeObject:propName];
                    }
                }
            }
        }
        
        if (unmappedDictionaryKeys.count > 0) {
            for (NSString *propName in unmappedDictionaryKeys) {
                [unmappedKVP setObject:[JSONdictionaryRepresentation objectForKey:propName] forKey:propName];
            }
        }
        return [unmappedKVP copy];
    }
    return nil;
}

- (NSDictionary *)setPropertiesWithJSONDictionary:(NSDictionary *)JSONDictionaryRepresentation {
    return [self setPropertiesWithJSONDictionary:JSONDictionaryRepresentation andExclusionList:nil];
}

- (NSString *)JSONRepresentationWithExcludedProperties:(NSArray *)excludedPropertyNames {
    return [self JSONRepresentationWithExcludedProperties:excludedPropertyNames orSelectProperties:nil];
}

- (NSString *)JSONRepresentationWithSelectProperties:(NSArray *)selectPropertyNames {
    return [self JSONRepresentationWithExcludedProperties:nil orSelectProperties:selectPropertyNames];
}

- (NSString *)JSONRepresentation {
    return [self JSONRepresentationWithExcludedProperties:nil orSelectProperties:nil];
}

- (NSString *)JSONRepresentationWithExcludedProperties:(NSArray *)excludedPropertyNames orSelectProperties:(NSArray *)selectPropertyNames {
    NSMutableString *jsonRep = [NSMutableString string];
    NSMutableDictionary *jsonDictionary = [[self JSONDictionaryRepresentationWithExcludedProperties:excludedPropertyNames orSelectProperties:selectPropertyNames] mutableCopy];
    if (jsonDictionary) {
        @try {
            NSError *error = nil;
            NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:jsonDictionary options:kNilOptions error:&error] encoding:NSUTF8StringEncoding];
            if (jsonString.length > 0) {
                [jsonRep appendString:jsonString];
            }
        }
        @catch (NSException *ex)
        {
            NSAssert(NO, @"NSObject<JSONRepresentationWithExcludedProperties:orSelectProperties>(NSException):%@", ex);
        }
    }
    
    return [jsonRep copy];
}

- (NSDictionary *)JSONDictionaryRepresentation {
    return [self JSONDictionaryRepresentationWithExcludedProperties:nil orSelectProperties:nil];
}

- (NSDictionary *)JSONDictionaryRepresentationWithExcludedProperties:(NSArray *)excludedPropertyNames {
    return [self JSONDictionaryRepresentationWithExcludedProperties:excludedPropertyNames orSelectProperties:nil];
}

- (NSDictionary *)JSONDictionaryRepresentationWithSelectProperties:(NSArray *)selectPropertyNames {
    return [self JSONDictionaryRepresentationWithExcludedProperties:nil orSelectProperties:selectPropertyNames];
}

- (void)addHttpBodyDataForMutableRequest:(NSMutableURLRequest *)request {
    NSDictionary *dict = [self JSONDictionaryRepresentation];
    if (dict) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
        request.HTTPBody = jsonData;
        if (request.HTTPBody.length > 0) {
            [request setValue:SFAApplicationJson forHTTPHeaderField:SFAContentType];
        }
    }
}

#pragma mark - Threading

- (void)runOnThreadCallback {
    void (^block)(void) = (id)self;
    block();
}

- (void)runOnThreadCallbackWithObject:(id)object {
    void (^block)(id obj) = (id)self;
    block(object);
}

void RunOnThreadWithObject(NSThread *thread, id object, BOOL wait, void (^block)(id object)) {
    if (block && thread) {
        [[block copy] performSelector:@selector(runOnThreadCallbackWithObject:) onThread:thread withObject:object waitUntilDone:wait];
    }
}

void RunOnThread(NSThread *thread, BOOL wait, void (^block)(void)) {
    if (block && thread) {
        [[block copy] performSelector:@selector(runOnThreadCallback) onThread:thread withObject:nil waitUntilDone:wait];
    }
}

@end
