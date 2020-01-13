#import <Foundation/Foundation.h>

typedef unsigned long long SFITick;

@interface NSDate (sfapi)

/**
 *  This method parses the following date formats
 
   yyyy-MM-dd'T'HH:mm:ss.SSS
   yyyyMMddHHmmss
   "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'";
   "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'";
   "yyyy-MM-dd'T'HH:mm:ss.SSSSS'Z'";
   "yyyy-MM-dd'T'HH:mm:ss.SSSS'Z'";
   "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
   "yyyy-MM-dd'T'HH:mm:ss.SS'Z'";
   "yyyy-MM-dd'T'HH:mm:ss.S'Z'";
   "yyyy-MM-dd'T'HH:mm:ss'Z'";
   "yyyy-MM-dd'T'HH:mm:ssXXXXX"; //Parses the date from 'box' connector
   
    The formatter attempts both "Z" and without.
    
 *  @param dateString An NSString representation of a date in one of the above formats.
 *
 *  @return Returns a parsed date.  Parsing occurs using en_US_POSIX locale and UTC timezone.
 */
+ (NSDate *)dateWithString:(NSString *)dateString;
- (NSString *)UTCStringRepresentation;
+ (NSDate *)dateWithUTCStringRepresentation:(NSString *)utcDate;
+ (SFITick)UTCTicks;
+ (SFITick)nowTicks;
+ (SFITick)ticksFromEpochSeconds:(NSInteger)epochSeconds;

@end
