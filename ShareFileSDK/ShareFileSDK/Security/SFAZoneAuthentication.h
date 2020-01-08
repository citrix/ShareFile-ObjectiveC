#if ShareFile
#import <Foundation/Foundation.h>

@interface SFAZoneAuthentication : NSObject

@property (nonatomic, strong) SFIZone *zone;
@property (nonatomic, strong) NSString *opId;
@property (nonatomic, strong) NSString *userId;

- (instancetype)initWithZoneId:(NSString *)zoneId zoneSecret:(NSString *)zoneSecret opId:(NSString *)opId userId:(NSString *)userId;
- (NSURL *)signUrl:(NSURL *)requestUrl;

@end
#endif
