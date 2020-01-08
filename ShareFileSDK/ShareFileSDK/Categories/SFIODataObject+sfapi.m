#import "SFIODataObject+sfapi.h"
#import "NSDictionary+sfapi.h"
#import "SFAJSONToODataMapper.h"

@implementation SFIODataObject (sfapi)

NSString * const kSFAODataMetaDataKey = @"odata.metadata";
NSString *const kSFAODataTypeKey = @"odata.type";

- (NSDictionary *)setPropertiesWithJSONDictionary:(NSDictionary *)JSONDictionaryRepresentation andExclusionList:(NSArray *)excludedPropertyNames {
    // Parse metadata and populate properties before parsing JSON - defaultModel may be needed later
    NSString *metadata = [JSONDictionaryRepresentation objectForKey:kSFAODataMetaDataKey andClass:[NSString class]];
    if (metadata.length > 0) {
        //Populate Properties.
        NSMutableDictionary *metadataDictionary = [SFAJSONToODataMapper metadataDictionaryWithStringValue:metadata];
        NSURL *baseURL = [metadataDictionary objectForKey:kSFOdataMetadataKey_BaseURI andClass:[NSURL class]];
        NSString *entityName = [metadataDictionary objectForKey:kSFOdataMetadataKey_Entity andClass:[NSString class]];
        NSNumber *apiVersion = [metadataDictionary objectForKey:kSFOdataMetadataKey_Version andClass:[NSNumber class]];
        NSString *connectorType = [metadataDictionary objectForKey:kSFOdataMetadataKey_Provider andClass:[NSString class]];
        NSString *model = [metadataDictionary objectForKey:kSFOdataMetadataKey_Model andClass:[NSString class]];
        self.MetadataAPIVersion = apiVersion;
        self.MetadataBaseURI = baseURL;
        self.MetadataEntitySet = entityName;
        self.MetadataProviderType = connectorType;
        self.defaultModel = model;
    }
    self.metadata = metadata;
    
    NSMutableDictionary *unmappedProperties = [[super setPropertiesWithJSONDictionary:JSONDictionaryRepresentation andExclusionList:excludedPropertyNames] mutableCopy];
    [unmappedProperties removeObjectForKey:kSFAODataMetaDataKey];
    self.type = [unmappedProperties objectForKey:kSFAODataTypeKey andClass:[NSString class]];
    [unmappedProperties removeObjectForKey:kSFAODataTypeKey];
    self.Properties = unmappedProperties;
    return [unmappedProperties copy];
}

- (NSDictionary *)JSONDictionaryRepresentationWithExcludedProperties:(NSArray *)excludedPropertyNames orSelectProperties:(NSArray *)selectPropertyNames {
    NSDictionary *dict = [super JSONDictionaryRepresentationWithExcludedProperties:excludedPropertyNames orSelectProperties:selectPropertyNames];
    if (dict) {
        NSMutableDictionary *mDict = [dict mutableCopy];
        if (self.metadata) {
            mDict[kSFAODataMetaDataKey] = self.metadata;
        }
        if (self.type) {
            mDict[kSFAODataTypeKey] = self.type;
        }
        for (NSString *key in self.Properties) {
            mDict[key] = self.Properties[key];
        }
        dict = [mDict copy];
    }
    return dict;
}

- (NSMutableArray *)propertyNamesIgnoredByJSONSerializer {
    NSMutableArray *result = [super propertyNamesIgnoredByJSONSerializer];
    [result addObjectsFromArray:@[NSStringFromSelector(@selector(MetadataAPIVersion)), NSStringFromSelector(@selector(MetadataBaseURI)), NSStringFromSelector(@selector(MetadataEntitySet)), NSStringFromSelector(@selector(MetadataProviderType)), NSStringFromSelector(@selector(Properties)), NSStringFromSelector(@selector(metadata)), NSStringFromSelector(@selector(type))]];
    return result;
}

@end
