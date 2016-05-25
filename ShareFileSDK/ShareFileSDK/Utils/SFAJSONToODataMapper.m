#import "SFAJSONToODataMapper.h"
#import "NSDictionary+sfapi.h"
#import "NSString+sfapi.h"
#import "SFAModelClassMapper.h"

@implementation SFAJSONToODataMapper

NSString *const kSFOdataMetadataKey_BaseURI = @"kSFOdataMetadataKey_BaseURI";
NSString *const kSFOdataMetadataKey_Entity = @"kSFOdataMetadataKey_Entity";
NSString *const kSFOdataMetadataKey_Model = @"kSFOdataMetadataKey_Model";
NSString *const kSFOdataMetadataKey_Version = @"kSFOdataMetadataKey_Version";
NSString *const kSFOdataMetadataKey_Provider = @"kSFOdataMetadataKey_Provider";
NSString *const kSFOdataModelPrefix = @"ShareFile.Api.Models.";

#pragma mark - Public

+ (SFODataObject *)ODataObjectWithJSONDictionaryRepresentation:(NSDictionary *)JSONDictionaryRepresentation {
    if ([JSONDictionaryRepresentation isKindOfClass:[NSDictionary class]]) {
        NSString *type = [JSONDictionaryRepresentation objectForKey:SFAODataTypeKey andClass:[NSString class]];
        NSString *metadata = [JSONDictionaryRepresentation objectForKey:SFAOdataMetadataKey andClass:[NSString class]];
        if (type.length > 0) {
            return [SFAJSONToODataMapper objectWithType:type andJSONDictionaryRepresentation:JSONDictionaryRepresentation];
        }
        else if (metadata.length > 0) {
            return [SFAJSONToODataMapper objectWithMetadata:metadata andJSONDictionaryRepresentation:JSONDictionaryRepresentation];
        }
    }
    return nil;
}

+ (NSMutableDictionary *)metadataDictionaryWithStringValue:(NSString *)uriStringRepresentation {
    return [SFAJSONToODataMapper metadataDictionaryWithURI:[uriStringRepresentation URL]];
}

+ (NSMutableDictionary *)metadataDictionaryWithURI:(NSURL *)uri {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:5];
    if (uri) {
        @autoreleasepool
        {
            NSString *uriString = [uri absoluteString];
            
            NSURL *baseURI = nil;
            NSString *entityName = nil;
            NSString *modelName = nil;
            NSNumber *apiVersion = nil;
            NSString *connectorType = nil;
            
            static NSRegularExpression *regex;
            static NSString *providerAndVersionPattern;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{ providerAndVersionPattern = [NSString stringWithFormat:@"[/][^/]+[/]v[0-9]+[/]"]; });
            
            NSArray *split = [uriString componentsSeparatedByString:@"$metadata"];
            if (split.count == 2) {
                NSString *baseURIString = [split objectAtIndex:0];
                if ([baseURIString characterAtIndex:baseURIString.length - 1] != '/') {
                    baseURIString = [NSString stringWithFormat:@"%@/", baseURIString];
                }
                baseURI = [baseURIString URL];
                if (baseURI) {
                    NSString *versionString = [[baseURI lastPathComponent].lowercaseString stringByReplacingOccurrencesOfString:@"v" withString:@""];
                    apiVersion = [NSNumber numberWithInteger:[versionString integerValue]];
                    connectorType = [[baseURI URLByDeletingLastPathComponent] lastPathComponent].lowercaseString;
                }
                
                split = [[split objectAtIndex:1] componentsSeparatedByString:@"/"];
                NSString *modelPrefix = kSFOdataModelPrefix;
                if (split.count >= 2) {
                    entityName = [[split objectAtIndex:0] stringByReplacingOccurrencesOfString:@"#" withString:@""];
                    modelName = [[[split objectAtIndex:1] stringByReplacingOccurrencesOfString:modelPrefix withString:@""] stringByReplacingOccurrencesOfString:@"@Element" withString:@""];
                }
                else if (split.count == 1) {
                    NSString *possibleModelName = [split lastObject];
                    modelName = [[[possibleModelName stringByReplacingOccurrencesOfString:modelPrefix withString:@""] stringByReplacingOccurrencesOfString:@"@Element" withString:@""] stringByReplacingOccurrencesOfString:@"#" withString:@""];
                }
            }
            else if (split.count == 1) {
                // e.g. {"url":"https://onprem.sharefile.local:19443/cifs/v3/Items(1)"}
                
                static dispatch_once_t onceToken;
                dispatch_once(&onceToken, ^{ regex = [NSRegularExpression regularExpressionWithPattern:providerAndVersionPattern options:NSRegularExpressionCaseInsensitive error:nil]; });
                NSArray *providerAndVersionMatches = [regex matchesInString:uriString options:0 range:NSMakeRange(0, uriString.length)];
                NSTextCheckingResult *lastProviderAndVersionMatch = [providerAndVersionMatches lastObject];
                
                if (lastProviderAndVersionMatch) {
                    NSRange providerAndVersionRange = [lastProviderAndVersionMatch range];
                    NSString *providerAndVersionString = [uriString substringWithRange:providerAndVersionRange].lowercaseString;
                    
                    NSString *baseURIString = [uriString substringToIndex:providerAndVersionRange.location + providerAndVersionRange.length];
                    if ([baseURIString characterAtIndex:baseURIString.length - 1] != '/') {
                        baseURIString = [NSString stringWithFormat:@"%@/", baseURIString];
                    }
                    baseURI = [baseURIString URL];
                    
                    NSArray *pathComps = [[providerAndVersionString pathComponents] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", @"/"]];
                    if (pathComps.count == 2) {
                        connectorType = [pathComps objectAtIndex:0];
                        NSString *apiVersionString = [pathComps lastObject];
                        if (apiVersionString.length > 1) {
                            apiVersionString = [apiVersionString substringFromIndex:1];
                        }
                        apiVersion = [NSNumber numberWithInt:[apiVersionString intValue]];
                        
                        NSString *pathCompsAfterVersioString = [uriString substringFromIndex:providerAndVersionRange.location + providerAndVersionRange.length];
                        pathComps = [pathCompsAfterVersioString pathComponents];
                        if (pathComps.count > 0) {
                            entityName = [pathComps objectAtIndex:0];
                            NSRange parenRange = [entityName rangeOfString:@"("];
                            if (parenRange.location != NSNotFound) {
                                entityName = [entityName substringToIndex:parenRange.location];
                            }
                        }
                    }
                }
            }
            
            if (baseURI && apiVersion && connectorType.length > 0) {
                [result setDictionary:@{ kSFOdataMetadataKey_BaseURI : baseURI, kSFOdataMetadataKey_Provider : connectorType, kSFOdataMetadataKey_Version : apiVersion }];
                if (modelName.length > 0) {
                    [result setObject:modelName forKey:kSFOdataMetadataKey_Model];
                }
                if (entityName.length > 0) {
                    [result setObject:entityName forKey:kSFOdataMetadataKey_Entity];
                }
            }
        }
    }
    return result;
}

#pragma mark - Internal

+ (SFODataObject *)objectWithMetadata:(NSString *)metadata andJSONDictionaryRepresentation:(NSDictionary *)JSONDictionaryRepresentation {
    // e.g. "https://example.sharefile.com/sf/v3/$metadata#Items/ShareFile.Api.Models.Folder@Element"
    if (metadata.length > 0) {
        @autoreleasepool
        {
            NSString *modelName = nil;
            
            NSMutableDictionary *metadataDictionary = [SFAJSONToODataMapper metadataDictionaryWithStringValue:metadata];
            modelName = [metadataDictionary objectForKey:kSFOdataMetadataKey_Model andClass:[NSString class]];
            
            if (modelName.length > 0) {
                Class matchingClass = NSClassFromString([[SFEntityTypeMap getModelTypes] objectForKey:modelName]);
                if (!matchingClass) {
                    matchingClass = NSClassFromString(modelName);
                }
                if (matchingClass) {
                    return [SFAJSONToODataMapper objectWithClass:matchingClass andJSONDictionaryRepresentation:JSONDictionaryRepresentation];
                }
            }
        }
    }
    return nil;
}

+ (SFODataObject *)objectWithType:(NSString *)type andJSONDictionaryRepresentation:(NSDictionary *)JSONDictionaryRepresentation {
    if (type.length > 0) {
        @autoreleasepool
        {
            NSString *modelName = [type stringByReplacingOccurrencesOfString:kSFOdataModelPrefix withString:@""];
            if (modelName.length > 0) {
                Class matchingClass = NSClassFromString([[SFEntityTypeMap getModelTypes] objectForKey:modelName]);
                if (!matchingClass) {
                    matchingClass = NSClassFromString(modelName);
                }
                if (matchingClass) {
                    return [SFAJSONToODataMapper objectWithClass:matchingClass andJSONDictionaryRepresentation:JSONDictionaryRepresentation];
                }
            }
        }
    }
    return nil;
}

+ (SFODataObject *)objectWithClass:(Class)class andJSONDictionaryRepresentation:(NSDictionary *)JSONDictionaryRepresentation {
    Class mappedClass = [SFAModelClassMapper mappedModelClassForDefaultModelClass:class];
    SFODataObject *result = [mappedClass new];
    [result setPropertiesWithJSONDictionary:JSONDictionaryRepresentation];
    return result;
}

@end
