#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"

@interface ShareFileSDKOAuthResponseTests : ShareFileSDKTests

@end

@implementation ShareFileSDKOAuthResponseTests

- (void)testOAuthResponse {
    BOOL result;
    result = [self OAuthResponseTestCaseWithKey1:@"code" key2:@"state" includeCompleteURL:YES type:[SFAOAuthAuthorizationCode class]];
    XCTAssertTrue(result, @"Get Authorization Code Successfully - Test Failed");
    result = [self OAuthResponseTestCaseWithKey1:@"code" key2:@"state" includeCompleteURL:NO type:[SFAOAuthAuthorizationCode class]];
    XCTAssertFalse(result, @"Get Authorization Code Failure - Test Failed");
    result = [self OAuthResponseTestCaseWithKey1:@"access_token" key2:@"refresh_token" includeCompleteURL:YES type:[SFAOAuthToken class]];
    XCTAssertTrue(result, @"Get OAuth Token Successfully - Test Failed");
    result = [self OAuthResponseTestCaseWithKey1:@"access_token" key2:@"refresh_token" includeCompleteURL:NO type:[SFAOAuthToken class]];
    XCTAssertFalse(result, @"Get OAuth Token Failure - Test Failed");
    result = [self OAuthResponseTestCaseWithKey1:@"error" key2:@"error_description" includeCompleteURL:YES type:[SFAOAuthError class]];
    XCTAssertTrue(result, @"Get OAuthError Successfully - Test Failed");
    result = [self OAuthResponseTestCaseWithKey1:@"error" key2:@"error_description" includeCompleteURL:NO type:[SFAOAuthError class]];
    XCTAssertFalse(result, @"Get OAuthError Failure - Test Failed");
    result = [self OAuthResponseTestCaseWithKey1:@"random1" key2:@"random2" includeCompleteURL:YES type:[SFAOAuthResponseBase class]];
    XCTAssertTrue(result, @"Get OAuth Response Base Successfully - Test Failed");
    result = [self OAuthResponseTestCaseWithKey1:@"random1" key2:@"random2" includeCompleteURL:NO type:[SFAOAuthResponseBase class]];
    XCTAssertFalse(result, @"Get OAuth Response Base Failure - Test Failed");
}

- (void)testOAuthResponseBasePropertiesMapping {
    // Arrange
    SFAOAuth2AuthenticationHelper *oauth2AuthHelper = [[SFAOAuth2AuthenticationHelper alloc] initWithUrl:[self OAuthCompleteURL]];
    NSMutableArray *array = [[self navigationURLsArrayWithCount:1] mutableCopy];
    NSDictionary *dictionary = @{ @"appcp" : @"sharefile.com", @"apicp" : @"sf-api.com", @"randomKey" : @"randomValue" };
    [array addObject:[self OAuthCompleteUriWithParametersFromDictionary:dictionary]];
    // Act
    id <SFAOAuthResponse> response = nil;
    for (NSURL *url in array) {
        response = [oauth2AuthHelper isComplete:url];
        if (response) {
            break;
        }
    }
    XCTAssertTrue([response isMemberOfClass:[SFAOAuthResponseBase class]], @"Response Type expected to be SFAOAuthResponseBase");
    XCTAssertNotNil(response.properties, @"Expected Properties to be non-nil.");
    SFAOAuthResponseBase *oauthResponseBase = nil;
    if ([response isKindOfClass:[SFAOAuthResponseBase class]]) {
        oauthResponseBase = (SFAOAuthResponseBase *)response;
    }
    XCTAssertTrue([oauthResponseBase.apiControlPlane isEqualToString:@"sf-api.com"], @"Api Control Plane expected value not found");
    XCTAssertTrue([oauthResponseBase.applicationControlPlane isEqualToString:@"sharefile.com"], @"Application Control Plane expected value not found");
    XCTAssertTrue([oauthResponseBase.properties[@"randomKey"] isEqualToString:@"randomValue"], @"Properties expected value not found");
}

#pragma mark - Helper Method(s)

- (BOOL)OAuthResponseTestCaseWithKey1:(NSString *)key1 key2:(NSString *)key2 includeCompleteURL:(BOOL)includeCompleteURL type:(Class)expectedClass {
    SFAOAuth2AuthenticationHelper *helper = [[SFAOAuth2AuthenticationHelper alloc] initWithUrl:[self OAuthCompleteURL]];
    NSMutableArray *array = [[self navigationURLsArrayWithCount:3] mutableCopy];
    NSDictionary *dictionary = @{ key1 : [NSString stringWithFormat:@"%@123", key1], key2 : [NSString stringWithFormat:@"%@123", key2] };
    if (includeCompleteURL) {
        [array addObject:[self OAuthCompleteUriWithParametersFromDictionary:dictionary]];
    }
    id response = nil;
    for (NSURL *url in array) {
        response = [helper isComplete:url];
        if (response) {
            break;
        }
    }
    return ((response != nil) && [response isKindOfClass:expectedClass]);
}

@end
