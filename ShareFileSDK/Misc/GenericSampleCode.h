#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import "ShareFileSDK.h"
#else
#import <ShareFileSDK/ShareFileSDK.h>
#endif

@interface GenericSampleCode : NSObject

@property (strong, nonatomic) SFAClient *client;
- (void)runSample;

@end
