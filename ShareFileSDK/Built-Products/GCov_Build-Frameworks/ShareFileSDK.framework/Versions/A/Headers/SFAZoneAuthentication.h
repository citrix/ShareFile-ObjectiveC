#if ShareFile
#import <Foundation/Foundation.h>

@interface SFAZoneAuthentication : NSObject

@property (nonatomic, strong) SFZone *zone;
@property (nonatomic, strong) NSString *opId;
@property (nonatomic, strong) NSString *userId;

- (instancetype)initWithZoneId:(NSString *)zoneId zoneSecret:(NSString *)zoneSecret opId:(NSString *)opId userId:(NSString *)userId;
- (NSURL *)signUrl:(NSURL *)requestUrl;

@end
#endif
