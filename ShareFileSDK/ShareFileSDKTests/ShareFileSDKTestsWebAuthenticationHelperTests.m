#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"

@interface ShareFileSDKTestsWebAuthenticationHelperTests : ShareFileSDKTests

@end

@implementation ShareFileSDKTestsWebAuthenticationHelperTests

- (void)testWebAuthenticationResponseSuccess {
    SFAWebAuthenticationHelper *helper = [[SFAWebAuthenticationHelper alloc] initWithURL:[self OAuthCompleteURL]];
    NSMutableArray *array = [[self navigationURLsArrayWithCount:3] mutableCopy];
    NSDictionary *dictionary = @{ @"test" : @"test123", @"test2" : @"test2123" };
    [array addObject:[self OAuthCompleteUriWithParametersFromDictionary:dictionary]];
    NSDictionary *response = nil;
    for (NSURL *url in array) {
        response = [helper isComplete:url];
        if (response) {
            break;
        }
    }
    XCTAssertNotNil(response, @"Response not found");
    XCTAssertNotNil(response[@"test"], @"test key not found in response");
    XCTAssertNotNil(response[@"test2"], @"test2 key not found in response");
}

- (void)testWebAuthenticationResponseFail {
    SFAWebAuthenticationHelper *helper = [[SFAWebAuthenticationHelper alloc] initWithURL:[self OAuthCompleteURL]];
    NSMutableArray *array = [[self navigationURLsArrayWithCount:1] mutableCopy];
    NSDictionary *response = nil;
    for (NSURL *url in array) {
        response = [helper isComplete:url];
        if (response) {
            break;
        }
    }
    XCTAssertNil(response, @"Expected Response to be not found.");
}

#pragma mark - Helper Method(s)


@end
