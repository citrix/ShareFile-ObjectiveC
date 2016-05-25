#import "SFODataFeed+sfapi.h"
#import "NSDictionary+sfapi.h"

@implementation SFODataFeed (sfapi)

NSString * const kSFAODataCountKey = @"odata.count";
NSString *const kSFAODataNextLinkKey = @"odata.nextLink";

- (NSDictionary *)setPropertiesWithJSONDictionary:(NSDictionary *)JSONDictionaryRepresentation andExclusionList:(NSArray *)excludedPropertyNames {
    NSMutableDictionary *unmappedProperties = [[super setPropertiesWithJSONDictionary:JSONDictionaryRepresentation andExclusionList:excludedPropertyNames] mutableCopy];
    self.count = [unmappedProperties objectForKey:kSFAODataCountKey andClass:[NSNumber class]];
    [unmappedProperties removeObjectForKey:kSFAODataCountKey];
    self.nextLink = [unmappedProperties objectForKey:kSFAODataNextLinkKey andClass:[NSString class]];
    [unmappedProperties removeObjectForKey:kSFAODataNextLinkKey];
    self.Properties = unmappedProperties;
    return [unmappedProperties copy];
}

- (NSDictionary *)JSONDictionaryRepresentationWithExcludedProperties:(NSArray *)excludedPropertyNames orSelectProperties:(NSArray *)selectPropertyNames {
    NSDictionary *dict = [super JSONDictionaryRepresentationWithExcludedProperties:excludedPropertyNames orSelectProperties:selectPropertyNames];
    if (dict) {
        NSMutableDictionary *mDict = [dict mutableCopy];
        if (self.count) {
            mDict[kSFAODataCountKey] = self.count;
        }
        if (self.nextLink) {
            mDict[kSFAODataNextLinkKey] = self.nextLink;
        }
        dict = [mDict copy];
    }
    return dict;
}

- (NSMutableArray *)propertyNamesIgnoredByJSONSerializer {
    NSMutableArray *result = [super propertyNamesIgnoredByJSONSerializer];
    [result addObjectsFromArray:@[NSStringFromSelector(@selector(nextLink)), NSStringFromSelector(@selector(count))]];
    return result;
}

@end
