#import <Foundation/Foundation.h>
#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
// Hidden APIs
#import "NSDate+sfapi.h"
//

@interface ShareFileSDKZoneAuthenticationTests : ShareFileSDKTests

@end

@implementation ShareFileSDKZoneAuthenticationTests

- (void)testURLSigning {
#if ShareFile
    SFAZoneAuthentication *zAuth = [[SFAZoneAuthentication alloc] initWithZoneId:@"z1" zoneSecret:@"YWJj" opId:@"op1" userId:@"111"];
    NSURL *signedURL = [zAuth signUrl:[NSURL URLWithString:@"http://www.google.com/taha/email?q=1&k=2&ht=635573583354844782&h=abc"]];
    XCTAssertTrue([signedURL.absoluteString isEqualToString:@"http://www.google.com/taha/email?q=1&k=2&ht=635573583354844782&zoneid=z1&opid=op1&zuid=111&h=kV3voljWVVbQmMwcKgL1n%2F7hGEgRgdClZcwd%2BTEqe7k%3D"], @"*1 Signed URL is not correct");
    signedURL = [zAuth signUrl:[NSURL URLWithString:@"http://www.google.com/taha/email?q=1&k=2&zoneid=zid&ht=635573583354913141&h=abc"]];
    XCTAssertTrue([signedURL.absoluteString isEqualToString:@"http://www.google.com/taha/email?q=1&k=2&zoneid=zid&ht=635573583354913141&opid=op1&zuid=111&h=V6kHxXNzFP4XS9%2FTU2NuOtJ8GDbXocoYRm1mSnT6PLg%3D"], @"*2 Signed URL is not correct");
    SFITick before = [NSDate nowTicks];
    signedURL = [zAuth signUrl:[NSURL URLWithString:@"http://www.google.com"]];
    NSRange range = [signedURL.absoluteString rangeOfString:@"ht="];
    BOOL htAdded = NO;
    if (range.location != NSNotFound) {
        NSString *trimmedString = [signedURL.absoluteString substringFromIndex:(range.location + 3)];
        range = [trimmedString rangeOfString:@"&"];
        if (range.location != NSNotFound) {
            htAdded = YES;
            trimmedString = [trimmedString substringToIndex:range.location];
            SFITick tickThen = strtoull([trimmedString UTF8String], NULL, 10);
            SFITick now = [NSDate nowTicks];
            XCTAssertTrue(before <= tickThen && tickThen <= now, @"Time is not in expected range.");
        }
    }
    XCTAssertTrue(htAdded, @"ht query string key not added with proper value");
#endif
}

@end
