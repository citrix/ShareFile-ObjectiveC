#import <Foundation/Foundation.h>
/**
 *  The SFAHttpBodyDataProvider protocol contain method to let various type of objects to provide HTTP body data.
 */
@protocol SFAHttpBodyDataProvider <NSObject>
/**
 *  Add body to given HTTP request.
 *
 *  @param request An HTTP request to be filled with body data.
 */
- (void)addHttpBodyDataForMutableRequest:(NSMutableURLRequest *)request;

@end
