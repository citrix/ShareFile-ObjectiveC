#import "SFAQueryBase.h"
#import "SFAClient.h"

@interface SFAQueryBase ()

- (instancetype)initWithClient:(id <SFAClient> )shareFileClient;
- (void)protectedSetShareFileClient:(id <SFAClient> )client;
- (void)protectedAddId:(NSString *)ide;
- (void)protectedAddIds:(NSString *)ide;
- (void)protectedAddIds:(NSString *)key withKey:(NSString *)ide;
- (void)protectedSetFrom:(NSString *)fromEntity;
- (void)protectedSetAction:(NSString *)action;
- (void)protectedAddActionIds:(NSString *)ide;
- (void)protectedAddActionIds:(NSString *)ids withKey:(NSString *)key;
- (void)protectedAddSubAction:(NSString *)subAction;
- (void)protectedAddSubAction:(NSString *)subAction withValue:(NSString *)ide;
- (void)protectedAddSubAction:(NSString *)subAction key:(NSString *)key withValue:(NSString *)ide;
- (void)protectedAddQueryString:(NSString *)key value:(NSString *)object;
- (void)protectedAddQueryString:(NSString *)key object:(id <NSObject> )object;
- (void)protectedAddHeaderWithKey:(NSString *)key value:(NSString *)value;
- (void)protectedSetBaseUrl:(NSURL *)url;
- (NSString *)protectedTryToGetUrlRootFrom:(NSURL *)providedUrl;

@end
