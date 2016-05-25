#import "NSArray+sfapi.h"

@implementation NSArray (sfapi)

#pragma mark - SFAHttpBodyDataProvider Methods
- (void)addHttpBodyDataForMutableRequest:(NSMutableURLRequest *)request {
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil];
    if (request.HTTPBody.length > 0) {
        [request setValue:SFAApplicationJson forHTTPHeaderField:SFAContentType];
    }
}

@end
