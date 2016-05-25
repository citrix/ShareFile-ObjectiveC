#import "SFAUploadResponse.h"
#import "NSDictionary+sfapi.h"

@implementation SFAUploadFile

- (NSDictionary *)setPropertiesWithJSONDictionary:(NSDictionary *)JSONDictionaryRepresentation andExclusionList:(NSArray *)excludedPropertyNames {
    NSMutableDictionary *unmappedProperties = [[super setPropertiesWithJSONDictionary:JSONDictionaryRepresentation andExclusionList:excludedPropertyNames] mutableCopy];
    //
    self.displayName = [unmappedProperties objectForKey:SFADisplayName andClass:[NSString class]];
    self.idString = [unmappedProperties objectForKey:SFAId andClass:[NSString class]];
    self.fileHash = [unmappedProperties objectForKey:SFAMd5 andClass:[NSString class]];
    self.size = [[unmappedProperties objectForKey:SFASize andClass:[NSNumber class]] unsignedLongLongValue];
    self.uploadId = [unmappedProperties objectForKey:SFAUploadId andClass:[NSString class]];
    //
    [unmappedProperties removeObjectForKey:SFADisplayName];
    [unmappedProperties removeObjectForKey:SFAId];
    [unmappedProperties removeObjectForKey:SFAMd5];
    [unmappedProperties removeObjectForKey:SFASize];
    [unmappedProperties removeObjectForKey:SFAUploadId];
    return [unmappedProperties copy];
}

- (NSDictionary *)JSONDictionaryRepresentationWithExcludedProperties:(NSArray *)excludedPropertyNames orSelectProperties:(NSArray *)selectPropertyNames {
    NSDictionary *dict = [super JSONDictionaryRepresentationWithExcludedProperties:excludedPropertyNames orSelectProperties:selectPropertyNames];
    if (dict) {
        NSMutableDictionary *mDict = [dict mutableCopy];
        if (self.displayName) {
            mDict[SFADisplayName] = self.displayName;
        }
        if (self.idString) {
            mDict[SFAId] = self.idString;
        }
        if (self.fileHash) {
            mDict[SFAMd5] = self.fileHash;
        }
        mDict[SFASize] = [NSNumber numberWithUnsignedLongLong:self.size];
        if (self.uploadId) {
            mDict[SFAUploadId] = self.uploadId;
        }
        dict = [mDict copy];
    }
    return dict;
}

- (NSMutableArray *)propertyNamesIgnoredByJSONSerializer {
    NSMutableArray *result = [super propertyNamesIgnoredByJSONSerializer];
    [result addObjectsFromArray:@[NSStringFromSelector(@selector(displayName)), NSStringFromSelector(@selector(idString)), NSStringFromSelector(@selector(fileHash)), NSStringFromSelector(@selector(size)), NSStringFromSelector(@selector(uploadId))]];
    return result;
}

@end

@implementation SFAUploadResponse

- (instancetype)init {
    self = [super init];
    if (self) {
        self.files = [NSMutableArray new];
    }
    return self;
}

#pragma mark NSArray

- (NSUInteger)count {
    return [self.files count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self.files objectAtIndex:index];
}

#pragma mark NSMutableArray

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    NSAssert([anObject isKindOfClass:[SFAUploadFile class]], @"Invalid Object");
    [self.files insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self.files removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject {
    NSAssert([anObject isKindOfClass:[SFAUploadFile class]], @"Invalid Object");
    [self.files addObject:anObject];
}

- (void)removeLastObject {
    [self.files removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [self.files replaceObjectAtIndex:index withObject:anObject];
}

// JSON

- (NSDictionary *)setPropertiesWithJSONDictionary:(NSDictionary *)JSONDictionaryRepresentation andExclusionList:(NSArray *)excludedPropertyNames {
    NSMutableDictionary *jsonRep = [JSONDictionaryRepresentation mutableCopy];
    //
    NSArray *filesJSONArray = jsonRep[SFAValue];
    if (filesJSONArray) {
        for (NSDictionary *fileJSONRep in filesJSONArray) {
            SFAUploadFile *file = [SFAUploadFile new];
            [file setPropertiesWithJSONDictionary:fileJSONRep andExclusionList:nil];
            [self.files addObject:file];
        }
    }
    [jsonRep removeObjectForKey:SFAValue];
    return [jsonRep copy];
    //
}

- (NSDictionary *)JSONDictionaryRepresentationWithExcludedProperties:(NSArray *)excludedPropertyNames orSelectProperties:(NSArray *)selectPropertyNames {
    NSMutableDictionary *mDict = [NSMutableDictionary new];
    NSMutableArray *filesJSONRep = [NSMutableArray new];
    for (SFAUploadFile *file in self.files) {
        NSDictionary *fileJSONRep = [file JSONDictionaryRepresentation];
        [filesJSONRep addObject:fileJSONRep];
    }
    mDict[SFAValue] = [filesJSONRep copy];
    return [mDict copy];
}

@end
