#import <Foundation/Foundation.h>

@class SFAClient;
/**
 * SFABaseRequestProvider provides basic functionality of Request Provider. SFAAsyncRequestProvider is subclass of SFABaseRequestProvider.
 */
@interface SFABaseRequestProvider : NSObject
/**
 *  Readonly reference to SFAClient object.
 */
@property (nonatomic, weak, readonly) SFAClient *sfaClient;

@end
