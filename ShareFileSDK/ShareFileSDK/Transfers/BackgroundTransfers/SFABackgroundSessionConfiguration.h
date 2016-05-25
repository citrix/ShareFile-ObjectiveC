#import <Foundation/Foundation.h>

/**
 *  This class provides a way for user to customize NSURLSessionConfiguration used for creation of NSURLSession.
 */
@interface SFABackgroundSessionConfiguration : NSObject

/**
 *  Identifier to be used as identifier of NSURLSession.
 */
@property (strong, nonatomic, readwrite) NSString *identifier;
/**
 *  Identifier to be used as sharedContainerIdentifier of NSURLSession.
 */
@property (strong, nonatomic, readwrite) NSString *sharedContainerIdentifier;

@end
