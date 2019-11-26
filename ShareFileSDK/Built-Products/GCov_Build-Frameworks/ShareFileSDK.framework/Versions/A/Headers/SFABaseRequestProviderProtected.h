#import <Foundation/Foundation.h>
#import "SFABaseRequestProvider.h"

@class SFAApiRequest;

@interface SFABaseRequestProvider ()

- (instancetype)initWithSFAClient:(SFAClient *)client;
- (NSURLRequest *)buildRequest:(SFAApiRequest *)apiRequest;
- (void)setSfaClient:(SFAClient *)client;
- (void)dataWithObject:(id)body forRequest:(NSMutableURLRequest *)request;
- (void)logApiRequest:(SFAApiRequest *)apiRequest headers:(NSString *)headers;
- (void)logApiRequestURL:(SFAApiRequest *)request;
- (void)logResponseWithHttpRequestResponseContainer:(SFAHttpRequestResponseDataContainer *)container responseObj:(id)responseObj;

@end
