#import <Foundation/Foundation.h>

extern NSString *const kSFOdataMetadataKey_BaseURI;
extern NSString *const kSFOdataMetadataKey_Entity;
extern NSString *const kSFOdataMetadataKey_Model;
extern NSString *const kSFOdataMetadataKey_Version;
extern NSString *const kSFOdataMetadataKey_Provider;
extern NSString *const kSFOdataModelPrefix;

@interface SFAJSONToODataMapper : NSObject

+ (SFIODataObject *)ODataObjectWithJSONDictionaryRepresentation:(NSDictionary *)JSONDictionaryRepresentation;
+ (NSMutableDictionary *)metadataDictionaryWithStringValue:(NSString *)uriStringRepresentation;
+ (NSMutableDictionary *)metadataDictionaryWithURI:(NSURL *)uri;

@end
