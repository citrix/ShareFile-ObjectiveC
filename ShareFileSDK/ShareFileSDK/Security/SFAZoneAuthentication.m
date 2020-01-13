#if ShareFile
#import "SFACryptoUtils.h"
#import "NSURL+sfapi.h"
#import "NSString+sfapi.h"
#import "NSDate+sfapi.h"
#import "SFABase64.h"

@implementation SFAZoneAuthentication

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (instancetype)initWithZoneId:(NSString *)zoneId zoneSecret:(NSString *)zoneSecret opId:(NSString *)opId userId:(NSString *)userId {
    self = [super init];
    if (self) {
        self.opId = opId;
        self.userId = userId;
        SFIZone *zone = [[SFIZone alloc] init];
        zone.Id = zoneId;
        zone.Secret = zoneSecret;
        self.zone = zone;
    }
    return self;
}

- (NSURL *)signUrl:(NSURL *)requestUrl {
    NSMutableString *urlToHash = [requestUrl.path mutableCopy];
    if (requestUrl.query && requestUrl.query.length > 0) {
        [urlToHash appendFormat:@"?%@", requestUrl.query];
    }
    NSString *urlCheck = [urlToHash lowercaseString];
    // strip anything after an existing &h parameter
    NSRange hParamRange = [urlCheck rangeOfString:@"&h="];
    if (hParamRange.location != NSNotFound) {
        urlToHash = [[urlToHash substringToIndex:hParamRange.location] mutableCopy];
    }
    // add a timestamp validation
    if ([urlCheck rangeOfString:@"ht="].location == NSNotFound) {
        if (requestUrl.query && requestUrl.query.length > 0) {
            [urlToHash appendString:@"&"];
        }
        else {
            [urlToHash appendString:@"?"];
        }
        [urlToHash appendFormat:@"ht=%llu", [NSDate nowTicks]];
    }
    // add any missing authentication/impersonation parameters
    if ([urlCheck rangeOfString:@"zoneid="].location == NSNotFound) {
        [urlToHash appendFormat:@"&zoneid=%@", self.zone.Id];
    }
    if ((self.opId != nil && self.opId.length > 0) && ([urlCheck rangeOfString:@"opid="].location == NSNotFound)) {
        [urlToHash appendFormat:@"&opid=%@", self.opId];
    }
    if ((self.userId != nil && self.userId.length > 0) && ([urlCheck rangeOfString:@"zuid"].location == NSNotFound)) {
        [urlToHash appendFormat:@"&zuid=%@", self.userId];
    }
    NSData *secretData = [NSData dataWithBase64EncodedString:self.zone.Secret];
    NSData *urlToHashData = [urlToHash dataUsingEncoding:NSUTF8StringEncoding];
    NSData *hash = [SFACryptoUtils hmac256ForKey:secretData andData:urlToHashData];
    NSString *escapedHashStringBase64 = [[hash base64EncodedString] escapeString];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@&h=%@", [requestUrl getAuthority], urlToHash, escapedHashStringBase64]];
}

@end
#endif
