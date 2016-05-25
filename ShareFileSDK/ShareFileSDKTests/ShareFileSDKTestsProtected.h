#import "ShareFileSDKTests.h"
#if TARGET_OS_IPHONE
#import "ShareFileSDK.h"
#else
#import <ShareFileSDK/ShareFileSDK.h>
#endif

#import "SFASDKAuthHandler.h"

@interface ShareFileSDKTests ()

@property (strong, nonatomic) SFAClient *client;
@property (strong, nonatomic) id <SFAAuthHandling> authHandler;

- (NSArray *)navigationURLsArrayWithCount:(int)count;
- (NSURL *)OAuthCompleteUriWithParametersFromDictionary:(NSDictionary *)dictionary;
- (NSURL *)OAuthCompleteURL;
- (NSString *)joinByAmpersandSeparatingCollection:(SFAODataParameterCollection *)collection;
- (NSString *)joinByCommaSeparatingCollection:(SFAODataParameterCollection *)collection;
- (NSString *)joinByCommaSeparatingParam:(SFAODataParameter *)param;
- (BOOL)compareObjectsInDictionary:(NSDictionary *)dict1 toDictionary:(NSDictionary *)dict2;
- (BOOL)compareObjectsInArray:(NSArray *)array1 toArray:(NSArray *)array2;

@end
