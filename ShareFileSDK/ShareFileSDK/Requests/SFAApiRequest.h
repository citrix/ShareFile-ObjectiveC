#import <Foundation/Foundation.h>

@interface SFAApiRequest : NSObject

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSMutableDictionary *headerCollection;
@property (nonatomic, strong) NSString *httpMethod;
@property (nonatomic, strong) id body;
@property (nonatomic, strong) SFAODataParameterCollection *queryStringCollection;
@property (nonatomic, strong, readonly) SFAQueryBase *queryBase;
@property (nonatomic, getter = isComposed) BOOL composed;

+ (BOOL)isUrl:(NSString *)urlString;
+ (SFAApiRequest *)apiRequestFromQuery:(SFAQueryBase *)queryBase;
- (NSURL *)composedUrl;

@end
