#import "NSDate+sfapi.h"

@implementation NSDate (sfapi)

+ (NSDateFormatter *)formatterWithFormat:(NSString *)format andLocale:(NSLocale *)locale {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:locale];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return formatter;
}

+ (NSDate *)dateWithString:(NSString *)dateString {
    /**
     *  Creating and resetting formatters is expensive.  Here, we cache all common date formatters
     *  and re-use them
     */
    static NSDateFormatter *topDateFormatter;
    static NSDateFormatter *v1DateFormatter;
    static NSArray *formatterArrayWithZ;
    static NSArray *formatterArray;
    
    /**
     *  This queue is used for synchronization.  NSDateFormatter is not thread safe.
     */
    static dispatch_queue_t formatterSyncQueue;
    static dispatch_once_t formatterToken;
    dispatch_once(&formatterToken, ^{
        formatterSyncQueue = dispatch_queue_create("com.sharefile.dateformatter.sync", NULL);
        NSLocale *dateFormatterLocal = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        topDateFormatter = [self formatterWithFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"
                                           andLocale:dateFormatterLocal];
                                           
        v1DateFormatter = [self formatterWithFormat:@"yyyyMMddHHmmss"
                                          andLocale:dateFormatterLocal];
                                          
        static NSString *optionalFormat0 = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'";
        static NSString *optionalFormat1 = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'";
        static NSString *optionalFormat2 = @"yyyy-MM-dd'T'HH:mm:ss.SSSSS'Z'";
        static NSString *optionalFormat3 = @"yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'";
        static NSString *optionalFormat4 = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
        static NSString *optionalFormat5 = @"yyyy-MM-dd'T'HH:mm:ss.SS'Z'";
        static NSString *optionalFormat6 = @"yyyy-MM-dd'T'HH:mm:ss.S'Z'";
        static NSString *optionalFormat7 = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        static NSString *optionalFormat8 = @"yyyy-MM-dd'T'HH:mm:ssXXXXX"; //Parses the date from 'box' connector
        
        NSArray *tempArray = @[optionalFormat0, optionalFormat1, optionalFormat2, optionalFormat3, optionalFormat4, optionalFormat5, optionalFormat6, optionalFormat7, optionalFormat8];
        
        NSMutableArray *tempZ = [NSMutableArray arrayWithCapacity:9];
        NSMutableArray *tempN = [NSMutableArray arrayWithCapacity:9];
        
        [tempArray enumerateObjectsUsingBlock: ^(NSString *obj, NSUInteger idx, BOOL *stop) {
             if ([obj hasSuffix:@"'Z'"]) {
                 [tempZ addObject:[self formatterWithFormat:obj andLocale:dateFormatterLocal]];
                 [tempN addObject:[self formatterWithFormat:[obj substringToIndex:obj.length - 3] andLocale:dateFormatterLocal]];
             }
             else {
                 [tempN addObject:[self formatterWithFormat:obj andLocale:dateFormatterLocal]];
             }
         }];
         
        formatterArrayWithZ = [tempZ copy];
        formatterArray = [tempN copy];
    });
    
    __block NSDate *result = nil;
    if (dateString.length > 0) {
        BOOL containsZ = [dateString hasSuffix:@"Z"];
        
        dispatch_sync(formatterSyncQueue, ^{
            result = [topDateFormatter dateFromString:dateString];
            
            if (!result) {
                NSArray *formatters = containsZ ? formatterArrayWithZ : formatterArray;
                for (NSDateFormatter *formatter in formatters) {
                    result = [formatter dateFromString:dateString];
                    
                    if (result) {
                        break;
                    }
                }
                
                if (!containsZ && !result) {
                    result = [v1DateFormatter dateFromString:dateString];
                }
            }
        });
    }
    
    NSAssert(result != nil, @"Date formatting failed: %@", dateString);
    
    return result;
}

static NSDateFormatter *_utcFormatter;

+ (void)initUTCFormatter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _utcFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [_utcFormatter setTimeZone:timeZone];
        [_utcFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"];
    });
}

- (NSString *)UTCStringRepresentation {
    [NSDate initUTCFormatter];
    
    NSString *dateString = [_utcFormatter stringFromDate:self];
    
    return dateString;
}

+ (NSDate *)dateWithUTCStringRepresentation:(NSString *)utcDate {
    if (utcDate.length > 0) {
        [self initUTCFormatter];
        return [_utcFormatter dateFromString:utcDate];
    }
    return nil;
}

+ (SFTick)UTCTicks {
    NSInteger epochSecondsGMT = (NSInteger)[[NSDate date] timeIntervalSince1970];
    return [NSDate ticksFromEpochSeconds:epochSecondsGMT];
}

+ (SFTick)nowTicks {
    NSInteger epochSecondsGMT = (NSInteger)[[NSDate date] timeIntervalSince1970];
    NSInteger secondsDiff = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSInteger epochSecondsZulu = epochSecondsGMT + secondsDiff;
    return [NSDate ticksFromEpochSeconds:epochSecondsZulu];
}

+ (SFTick)ticksFromEpochSeconds:(NSInteger)epochSeconds {
    long long ticksFromEpoch = ((long long)epochSeconds) * SFATicksPerSecond;
    SFTick ticks = (SFTick)(SFAEpochTicks + ticksFromEpoch);
    return ticks;
}

@end
