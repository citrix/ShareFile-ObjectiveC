#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
// Hidden APIs
#import "NSObject+sfapi.h"
#import "SFApiQueryProtected.h"
//

@interface ShareFileSDKQueryTests : ShareFileSDKTests

@end

@implementation ShareFileSDKQueryTests

- (void)testQueryInit {
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    XCTAssertEqual(self.client, query.client, @"Did not init with passed parameters");
}

- (void)testQuerySetupTest {
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    query.httpMethod = @"POST";
    query.from = @"entity";
    [query setAction:@"action"];
    [query addIds:@"id1"];
    [query addIds:@"id2"];
    [query addActionIds:@"act1" withKey:@"kact1"];
    [query addActionIds:@"act2"];
    [query addSubAction:@"subaction1" withValue:@"subact1"];
    [query addSubAction:@"subaction2" key:@"ksubact2" withValue:@"subact2"];
    [query addSubAction:@"subaction3"];
    [query addQueryString:@"k1" withValue:@"q1"];
    [query addQueryString:@"k2" withValue:@"q2"];
    NSDictionary *dict = @{ @"test" : @"test" };
    query.body = dict;
    [query selectProperty:@"test11"];
    [query expandProperty:@"test12"];
    [query selectProperties:@[@"test21"]];
    [query expandProperties:@[@"test22"]];
    [query skip:10];
    [query top:20];
    [query addHeaderWithKey:@"headerKey" value:@"headerValue"];
    id <SFAFilter> filter = [[SFAEndsWithFilter alloc] initWithPropertyName:@"test31" value:@"abc" isEqual:YES];
    [query filterBy:filter];
    // Test
    XCTAssertTrue([query.httpMethod isEqualToString:@"POST"], @"Expected method to be POST.");
    XCTAssertTrue([query.from isEqualToString:@"entity"], @"Unexpected value returned for from.");
    XCTAssertTrue(query.ids.count == 2, @"Unexpected value returned for ids.count.");
    BOOL foundValue1 = NO;
    BOOL foundValue2 = NO;
    id <NSFastEnumeration> enumerable = [query.ids collectionAsFastEnumrable];
    for (SFAODataParameter *param in enumerable) {
        if ([param.value isEqualToString:@"id1"]) {
            foundValue1 = YES;
        }
        if ([param.value isEqualToString:@"id2"]) {
            foundValue2 = YES;
        }
    }
    XCTAssertTrue(foundValue1 && foundValue2, @"Expected all added ids to be found.");
    XCTAssertTrue([query.action.actionName isEqualToString:@"action"], @"Unexpected value returned for action.actionName.");
    XCTAssertTrue(query.action.parameters.count == 2, @"Unexpected value returned for action.parameters.count.");
    foundValue1 = NO;
    foundValue2 = NO;
    enumerable = [query.action.parameters collectionAsFastEnumrable];
    for (SFAODataParameter *param in enumerable) {
        if ([param.value isEqualToString:@"act1"] && [param.key isEqualToString:@"kact1"]) {
            foundValue1 = YES;
        }
        if ([param.value isEqualToString:@"act2"]) {
            foundValue2 = YES;
        }
    }
    XCTAssertTrue(foundValue1 && foundValue2, @"Expected all added actions to be found.");
    // subaction1
    foundValue1 = NO;
    SFAODataAction *subaction = query.subActions[0];
    XCTAssertTrue([subaction.actionName isEqualToString:@"subaction1"], @"* Unexpected value returned for subaction.actionNames.");
    enumerable = [subaction.parameters collectionAsFastEnumrable];
    for (SFAODataParameter *param in enumerable) {
        if ([param.value isEqualToString:@"subact1"]) {
            foundValue1 = YES;
        }
        break;
    }
    XCTAssertTrue(foundValue1, @"* Unexpected value returned for subaction value.");
    // subaction2
    foundValue1 = NO;
    subaction = query.subActions[1];
    XCTAssertTrue([subaction.actionName isEqualToString:@"subaction2"], @"** Unexpected value returned for subaction.actionNames.");
    enumerable = [subaction.parameters collectionAsFastEnumrable];
    for (SFAODataParameter *param in enumerable) {
        if ([param.value isEqualToString:@"subact2"] && [param.key isEqualToString:@"ksubact2"]) {
            foundValue1 = YES;
        }
        break;
    }
    XCTAssertTrue(foundValue1, @"** Unexpected key value returned for subaction.");
    // subaction3
    subaction = query.subActions[2];
    XCTAssertTrue([subaction.actionName isEqualToString:@"subaction3"], @"*** Unexpected value returned for subaction.actionNames.");
    XCTAssertTrue(subaction.parameters.count == 0, @"*** Unexpected value returned for subaction.parameters.count");
    // query sring
    foundValue1 = NO;
    foundValue2 = NO;
    XCTAssertTrue(query.queryString.count == 2, @"Unexpected count returned for query.queryString.count.");
    enumerable = [query.queryString collectionAsFastEnumrable];
    for (SFAODataParameter *param in enumerable) {
        if ([param.key isEqualToString:@"k1"] && [param.value isEqualToString:@"q1"]) {
            foundValue1 = YES;
        }
        if ([param.key isEqualToString:@"k2"] && [param.value isEqualToString:@"q2"]) {
            foundValue2 = YES;
        }
    }
    XCTAssertTrue(foundValue1 && foundValue2, @"Unexpected key value pairs returned for queryString.");
    // body
    XCTAssertEqual(query.body, dict, @"Unexpected value returned for body.");
    // select expand
    BOOL fail = NO;
    XCTAssertTrue(query.selectProperties.count == 2, @"Unexpected count of selectProperties returned.");
    XCTAssertTrue(query.expandProperties.count == 2, @"Unexpected coutn of expandProperties returned.");
    for (int i = 1; i <= 2; i++) {
        if (![query.selectProperties[i - 1] isEqualToString:[NSString stringWithFormat:@"test%d1", i]] || ![query.expandProperties[i - 1] isEqualToString:[NSString stringWithFormat:@"test%d2", i]]) {
            fail = YES;
            break;
        }
    }
    XCTAssertFalse(fail, @"Unexpected select/expand property found returned.");
    // skip top
    XCTAssertTrue(query.skip == 10, @"Unexpected value returned for skip.");
    XCTAssertTrue(query.top == 20, @"Unexpected value returned for top.");
    // header
    XCTAssertTrue(query.headers.count == 1, @"Unexpected header count returned.");
    for (NSString *key in query.headers) {
        XCTAssertTrue([key isEqualToString:@"headerKey"], @"Unexpected value returned for header key.");
        XCTAssertTrue([query.headers[key] isEqualToString:@"headerValue"], @"Unexpected value returned for header value.");
    }
}

@end
