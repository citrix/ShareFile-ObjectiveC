#import <Foundation/Foundation.h>
#import "SFAQuery.h"
#import "SFAClient.h"
/**
 *  The SFAQueryBase class conforms to SFAReadOnlyQuery protocol.
 */
@interface SFAQueryBase : NSObject <SFAReadOnlyQuery>
/**
 *  Reference to client conforming to SFAClient protocol.
 */
@property (nonatomic, strong, readonly) id <SFAClient> client;
/**
 *  NSURL representing base url of ShareFile client.
 */
@property (nonatomic, strong, readonly) NSURL *baseUrl;
/**
 *  Setter for HTTP request method.
 *
 *  @param httpMethod NSString representing HTTP request method e.g. @"GET".
 */
- (void)setHttpMethod:(NSString *)httpMethod;
/**
 *  Set the object that will be used for obtaining HTTP request body.
 *
 *  @param body SFAHttpBodyDataProvider conforming object to be used for obtaining HTTP request body.
 */
- (void)setBody:(id <SFAHttpBodyDataProvider> )body;

@end
