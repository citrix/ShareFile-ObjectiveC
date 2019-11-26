#import <Foundation/Foundation.h>
#import "SFAHttpBodyDataProvider.h"

@interface NSObject (sfapi) <SFAHttpBodyDataProvider>

@property (nonatomic, strong) NSString *defaultModel;

- (NSDictionary *)setPropertiesWithJSONDictionary:(NSDictionary *)JSONDictionaryRepresentation;
- (NSDictionary *)setPropertiesWithJSONDictionary:(NSDictionary *)JSONdictionaryRepresentation andExclusionList:(NSArray *)excludedPropertyNames;
- (NSString *)JSONRepresentationWithExcludedProperties:(NSArray *)excludedPropertyNames;
- (NSString *)JSONRepresentationWithSelectProperties:(NSArray *)selectPropertyNames;
- (NSString *)JSONRepresentation;
- (NSString *)JSONRepresentationWithExcludedProperties:(NSArray *)excludedPropertyNames orSelectProperties:(NSArray *)selectPropertyNames;
- (NSDictionary *)JSONDictionaryRepresentation;
- (NSDictionary *)JSONDictionaryRepresentationWithExcludedProperties:(NSArray *)excludedPropertyNames;
- (NSDictionary *)JSONDictionaryRepresentationWithSelectProperties:(NSArray *)selectPropertyNames;
- (NSDictionary *)JSONDictionaryRepresentationWithExcludedProperties:(NSArray *)excludedPropertyNames orSelectProperties:(NSArray *)selectPropertyNames;
- (NSMutableArray *)propertyNamesIgnoredByJSONSerializer;

#pragma mark - Old SDK Methods

+ (NSMutableArray *)propertyNamesIncludingInheritedProperties:(BOOL)includeInherited;
+ (NSMutableArray *)propertyNames;
+ (NSMutableDictionary *)propertyNamesAndTypes;
void RunOnThread(NSThread *thread, BOOL wait, void (^block)(void));
void RunOnThreadWithObject(NSThread *thread, id object, BOOL wait, void (^block)(id object));

@end
