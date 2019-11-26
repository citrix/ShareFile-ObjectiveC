#import <Foundation/Foundation.h>

@interface SFAHttpRequestUtils : NSObject

+ (void)addFormDataWithParameters:(NSDictionary *)parameters toURLRequest:(NSMutableURLRequest *)request;
+ (void)addMultipartDataWithParameters:(NSDictionary *)parameters toURLRequest:(NSMutableURLRequest *)request;
+ (NSData *)multipartDataWithParameters:(NSDictionary *)parameters boundary:(NSString **)boundary;
+ (void)appendToMultipartData:(NSMutableData *)data key:(NSString *)key value:(id)value;
+ (NSString *)urlWithBase:(NSString *)root path:(NSArray *)path query:(NSDictionary *)query;
+ (NSString *)joinPathWithArray:(NSArray *)array;
+ (NSString *)joinQueryWithDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)splitQueryWithString:(NSString *)string;
+ (NSString *)unescape:(NSString *)string;
+ (NSString *)escape:(NSString *)string;
+ (NSArray *)flatten:(NSDictionary *)dictionary;

@end
