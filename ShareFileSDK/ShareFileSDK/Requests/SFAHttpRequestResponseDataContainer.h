#import <Foundation/Foundation.h>
/**
 *  The SFAHttpRequestResponseDataContainer class contains request, response, data and error from the HTTTP communication performed for a query.
 */
@interface SFAHttpRequestResponseDataContainer : NSObject
/**
 *  NSURLRequest used to make the request to server.
 */
@property (nonatomic, strong, readonly) NSURLRequest *request;
/**
 *  NSHTTPURLResponse received from server.
 */
@property (nonatomic, strong, readonly) NSHTTPURLResponse *response;
/**
 *  NSData object containing data returned by the server.
 */
@property (nonatomic, strong, readonly) NSData *data;
/**
 *  NSError object representing error in HTTP communication.
 */
@property (nonatomic, strong, readonly) NSError *error;
/**
 *  Initializes SFAHttpRequestResponseDataContainer object with provided parameters.
 *
 *  @param request  NSURLRequest used to make the request to server.
 *  @param response NSHTTPURLResponse received from server.
 *  @param data     NSData object containing data returned by the server.
 *  @param error    NSError object representing error in HTTP communication.
 *
 *  @return Returns SFAHttpRequestResponseDataContainer object or nil if an object could not be created for some reason.
 */
- (instancetype)initWithRequest:(NSURLRequest *)request response:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *)error;

@end
