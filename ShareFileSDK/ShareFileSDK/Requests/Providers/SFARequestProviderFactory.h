#import <Foundation/Foundation.h>

@interface SFARequestProviderFactory : NSObject

@property (nonatomic, strong) id <SFAAsyncRequestProvider> asyncProvider;

@end
