#import <Foundation/Foundation.h>

@interface SFACryptoUtils : NSObject

+ (NSData *)hmac256ForKey:(NSData *)key andData:(NSData *)data;
+ (NSString *)md5StringWithData:(NSData *)data;

@end
