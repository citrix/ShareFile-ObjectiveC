#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
// Hidden APIs
#import "SFAApiRequest.h"
#import "NSObject+sfapi.h"
//

@interface ShareFileSDKApiRequestTests : ShareFileSDKTests

@end

@implementation ShareFileSDKApiRequestTests

- (void)testApiRequestWithId {
    NSString *idString = [self queryId];
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    [query setFrom:@"Items"];
    [query setAction:@"Download"];
    [query addIds:idString];
    
    SFAApiRequest *apiRequest = [SFAApiRequest apiRequestFromQuery:(SFAQueryBase *)query];
    XCTAssertNil(apiRequest.body, @"Body should be nil");
    XCTAssertTrue([apiRequest.httpMethod isEqualToString:@"GET"], @"HTTP method should be GET");
    NSString *expectedUri = [NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items(%@)/Download", idString];
    XCTAssertTrue([[[apiRequest composedUrl] absoluteString] isEqualToString:expectedUri], @"Invalid URL");
}

- (void)testApiRequestWithUri {
    NSString *idString = [self queryId];
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    [query addUrl:[NSURL URLWithString:[NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items/(%@)", idString]]];
    [query setAction:@"Download"];
    
    SFAApiRequest *apiRequest = [SFAApiRequest apiRequestFromQuery:(SFAQueryBase *)query];
    XCTAssertNil(apiRequest.body, @"Body should be nil");
    XCTAssertTrue([apiRequest.httpMethod isEqualToString:@"GET"], @"HTTP method should be GET");
    NSString *expectedUri = [NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items/(%@)/Download", idString];
    XCTAssertTrue([[[apiRequest composedUrl] absoluteString] isEqualToString:expectedUri], @"Invalid URL");
}

- (void)testApiRequestWithBodyAsPost {
    NSString *idString = [self queryId];
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    [query addUrl:[NSURL URLWithString:[NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items/(%@)", idString]]];
    [query setAction:@"CreateFolder"];
    query.httpMethod = @"POST";
    query.body = [SFIFolder new];
    
    SFAApiRequest *apiRequest = [SFAApiRequest apiRequestFromQuery:(SFAQueryBase *)query];
    XCTAssertEqual(apiRequest.body, query.body, @"Body should not be nil");
    XCTAssertTrue([apiRequest.httpMethod isEqualToString:@"POST"], @"HTTP method should be POST");
    NSString *expectedUri = [NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items/(%@)/CreateFolder", idString];
    XCTAssertTrue([[[apiRequest composedUrl] absoluteString] isEqualToString:expectedUri], @"Invalid URL");
}

- (void)testApiRequestWithBodyAsGet {
    NSString *idString = [self queryId];
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    [query addUrl:[NSURL URLWithString:[NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items/(%@)", idString]]];
    [query setAction:@"CreateFolder"];
    query.body = [SFIFolder new];
    
    SFAApiRequest *apiRequest = [SFAApiRequest apiRequestFromQuery:(SFAQueryBase *)query];
    XCTAssertEqual(apiRequest.body, query.body, @"Body should not be nil");
    XCTAssertTrue([apiRequest.httpMethod isEqualToString:@"GET"], @"HTTP method should be GET. Just because body is defined, does not mean it should be a POST");
    NSString *expectedUri = [NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items/(%@)/CreateFolder", idString];
    XCTAssertTrue([[[apiRequest composedUrl] absoluteString] isEqualToString:expectedUri], @"Invalid URL");
}

- (void)testApiRequestWithQueryString {
    NSString *idString = [self queryId];
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    [query addUrl:[NSURL URLWithString:[NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items/(%@)", idString]]];
    [query addQueryString:@"key1" withValue:@"value1"];
    [query addQueryString:@"key2" withValue:@"value2"];
    SFAApiRequest *apiRequest = [SFAApiRequest apiRequestFromQuery:(SFAQueryBase *)query];
    XCTAssertNil(apiRequest.body, @"Body should be nil");
    NSString *expectedUri = [NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items/(%@)?key1=value1&key2=value2", idString];
    XCTAssertTrue([[[apiRequest composedUrl] absoluteString] isEqualToString:expectedUri], @"Invalid URL");
}

- (void)testApiRequestWithHeader {
    NSString *idString = [self queryId];
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    [query addUrl:[NSURL URLWithString:[NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items/(%@)", idString]]];
    [query addHeaderWithKey:@"key1" value:@"value1"];
    SFAApiRequest *apiRequest = [SFAApiRequest apiRequestFromQuery:(SFAQueryBase *)query];
    XCTAssertNil(apiRequest.body, @"Body should be nil");
    NSString *expectedUri = [NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items/(%@)", idString];
    XCTAssertTrue([[[apiRequest composedUrl] absoluteString] isEqualToString:expectedUri], @"Invalid URL");
    NSString *value = [apiRequest.headerCollection objectForKey:@"key1"];
    XCTAssertTrue([value isEqualToString:@"value1"], @"Invalid header value");
}

- (void)testApiRequestWithCompositeIds {
    NSString *id1 = [self queryId];
    NSString *id2 = [self queryId];
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    query.from = @"Items";
    [query addStringIds:id1 withKey:@"id1"];
    [query addStringIds:id2 withKey:@"id2"];
    SFAApiRequest *apiRequest = [SFAApiRequest apiRequestFromQuery:(SFAQueryBase *)query];
    XCTAssertNil(apiRequest.body, @"Body should be nil");
    NSString *expectedUri = [NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items(id1=%@,id2=%@)", id1, id2];
    XCTAssertTrue([[[apiRequest composedUrl] absoluteString] isEqualToString:expectedUri], @"Invalid URL");
}

- (void)testApiRequestWithCompositeActionIds {
    NSString *id1 = [self queryId];
    NSString *id2 = [self queryId];
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    query.from = @"Items";
    [query setAction:@"Test"];
    [query addActionIds:id1 withKey:@"id1"];
    [query addActionIds:id2 withKey:@"id2"];
    SFAApiRequest *apiRequest = [SFAApiRequest apiRequestFromQuery:(SFAQueryBase *)query];
    XCTAssertNil(apiRequest.body, @"Body should be nil");
    NSString *expectedUri = [NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items/Test(id1=%@,id2=%@)", id1, id2];
    XCTAssertTrue([[[apiRequest composedUrl] absoluteString] isEqualToString:expectedUri], @"Invalid URL");
}

- (void)testApiRequestWithCompositeSubActionIds {
    NSString *id1 = [self queryId];
    NSString *id2 = [self queryId];
    
    NSString *subId1 = [self queryIdWithLength:16];
    NSString *subId2 = [self queryIdWithLength:16];
    
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    query.from = @"Items";
    [query setAction:@"Test"];
    [query addActionIds:id1 withKey:@"id1"];
    [query addActionIds:id2 withKey:@"id2"];
    [query addSubAction:@"TestSubAction" key:@"subid1" withValue:subId1];
    [query addSubAction:@"TestSubAction" key:@"subid2" withValue:subId2];
    SFAApiRequest *apiRequest = [SFAApiRequest apiRequestFromQuery:(SFAQueryBase *)query];
    XCTAssertNil(apiRequest.body, @"Body should be nil");
    NSString *expectedUri = [NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items/Test(id1=%@,id2=%@)/TestSubAction(subid1=%@,subid2=%@)", id1, id2, subId1, subId2];
    XCTAssertTrue([[[apiRequest composedUrl] absoluteString] isEqualToString:expectedUri], @"Invalid URL");
}

- (void)testApiRequestWithBaseUri {
    NSString *idString = [self queryId];
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    query.from = @"Items";
    [query setAction:@"Test"];
    [query addActionIds:idString withKey:@"id"];
    [query setBaseUrl:[NSURL URLWithString:@"https://secure.sf-api.com/sf/v3/RandomEntity(folderId)"]];
    SFAApiRequest *apiRequest = [SFAApiRequest apiRequestFromQuery:(SFAQueryBase *)query];
    XCTAssertNil(apiRequest.body, @"Body should be nil");
    NSString *expectedUri = [NSString stringWithFormat:@"https://secure.sf-api.com/sf/v3/Items/Test(id=%@)", idString];
    XCTAssertTrue([[[apiRequest composedUrl] absoluteString] isEqualToString:expectedUri], @"Invalid URL");
}

- (void)testApiRequestWithBaseUriFails {
    NSString *idString = [self queryId];
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    query.from = @"Items";
    [query setAction:@"Test"];
    [query addActionIds:idString withKey:@"id"];
    XCTAssertThrows([query setBaseUrl:[NSURL URLWithString:@"https://secure.sf-api.com/sfItems(folderId)"]], @"Invalid Base URL Accepted");
}

- (void)testApiRequestWithQueryStringOnUri {
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    [query addUrl:[NSURL URLWithString:@"https://secure.sf-api.com/sf/v3/Items(folder)?qsParam=1"]];
    [query addQueryString:@"testKey" withValue:@"testValue"];
    SFAApiRequest *apiRequest = [SFAApiRequest apiRequestFromQuery:(SFAQueryBase *)query];
    XCTAssertNil(apiRequest.body, @"Body should be nil");
    NSString *expectedUri = @"https://secure.sf-api.com/sf/v3/Items(folder)?qsParam=1&testKey=testValue";
    XCTAssertTrue([[[apiRequest composedUrl] absoluteString] isEqualToString:expectedUri], @"Invalid URL");
}

#pragma mark - Helper Function

- (NSString *)queryId {
    return [self queryIdWithLength:34];
}

- (NSString *)queryIdWithLength:(int)length {
    if (length > 36) {
        length = 36;
    }
    NSString *idString = [[NSUUID UUID] UUIDString];
    return [idString substringToIndex:length];
}

@end
