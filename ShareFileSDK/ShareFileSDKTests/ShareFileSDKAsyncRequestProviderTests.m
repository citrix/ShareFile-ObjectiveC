#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
// Hidden APIs
#import "SFAAsyncRequestProviderProtected.h"
#import "NSObject+sfapi.h"
#import "SFAHttpTaskProtected.h"
//

@interface ShareFileSDKAsyncRequestProviderTests : ShareFileSDKTests

@end

@implementation ShareFileSDKAsyncRequestProviderTests

- (void)testOnDomainChangeRaised {
    __block BOOL changeDomainRaised = NO;
    SFAChangeDomainCallback handler = ^SFAEventHandlerResponse * (NSURLRequest *request, SFIRedirection *redirect)
    {
        changeDomainRaised = YES;
        return [SFAEventHandlerResponse eventHandlerResponseWithRedirection:redirect];
    };
    [self.client addChangeDomainHandler:handler];
    XCTAssertTrue([self.client.changeDomainHandlers containsObject:handler], @"Expected handler to be in handlers");
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];                             // Mock what a task would send to Request Provider
    query.responseClass = [SFIItem class];                                                            // We are expecting some thing else.
    SFAAsyncRequestProvider *prov = [[SFAAsyncRequestProvider alloc] initWithSFAClient:self.client]; // Request Provider
    SFAHttpRequestResponseDataContainer *container = [self containerForRedirection];                 // Mock Response
    id contextObject = [NSMutableDictionary dictionary];                                             // Mock what a task would send to Request Provider
    [prov task:nil needsResponseHandlingForQuery:query httpRequestResponseDataContainer:container usingContextObject:&(contextObject)];
    XCTAssertTrue(changeDomainRaised, @"Change domain handler not called");
}

- (void)testAsyncOperationScheduledError {
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];                             // Mock what a task would send to Request Provider
    SFAAsyncRequestProvider *prov = [[SFAAsyncRequestProvider alloc] initWithSFAClient:self.client]; // Request Provider
    SFAHttpRequestResponseDataContainer *container = [self containerForAsyncOperationScheduled];     // Mock Response
    id contextObject = @{};                                                                          // Mock what a task would send to Request Provider
    SFAHttpHandleResponseReturnData *returnedData = [prov task:nil needsResponseHandlingForQuery:query httpRequestResponseDataContainer:container usingContextObject:&(contextObject)];
    if ([returnedData.returnValue isKindOfClass:[SFAAsyncOperationScheduledError class]]) {
        SFAAsyncOperationScheduledError *err = (SFAAsyncOperationScheduledError *)returnedData.returnValue;
        XCTAssertTrue(err.errorType == SFAErrorTypeAsyncOperationScheduledError, @"Expected Error Type to be %ld", SFAErrorTypeAsyncOperationScheduledError);
        XCTAssertTrue([err.scheduledAsyncOperation.BatchID isEqualToString:@"123123"], @"Unexpected BatchID value in AsyncOperation Model");
        XCTAssertTrue([err.scheduledAsyncOperation.BatchSourceID isEqualToString:@"789789"], @"Unexpected BatchSourceID value in AsyncOperation Model");
        XCTAssertTrue(err.scheduledAsyncOperation.BatchProgress.intValue == 0, @"Unexpected BatchProgress value in AsyncOperation Model");
        XCTAssertTrue([err.scheduledAsyncOperation.BatchState isEqualToString:@"Scheduled"], @"Unexpected BatchState value in AsyncOperation Model");
        XCTAssertTrue(err.code == 202, @"Expected 202 Code.");
    }
    else {
        XCTFail(@"Expected AsyncOperationScheduled Error to be returned.");
    }
}

- (void)testOnWebAuthenticationError {
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];                             // Mock what a task would send to Request Provider
    SFAAsyncRequestProvider *prov = [[SFAAsyncRequestProvider alloc] initWithSFAClient:self.client]; // Request Provider
    SFAHttpRequestResponseDataContainer *container = [self containerForUnauthorized];                // Mock Response
    id contextObject = @{};                                                                          // Mock what a task would send to Request Provider
    SFAHttpHandleResponseReturnData *returnedData = [prov task:nil needsResponseHandlingForQuery:query httpRequestResponseDataContainer:container usingContextObject:&(contextObject)];
    if ([returnedData.returnValue isKindOfClass:[SFAWebAuthenticationError class]]) {
        SFAWebAuthenticationError *err = (SFAWebAuthenticationError *)returnedData.returnValue;
        XCTAssertTrue(err.errorType == SFAErrorTypeWebAuthenticationError, @"Expected Error Type to be %ld", SFAErrorTypeWebAuthenticationError);
        XCTAssertTrue([err.wwwAuthenticateHeader isEqualToString:@"Bearer"], @"Expected WWW-Authenticate Header to be Bearer");
        XCTAssertTrue(err.code == 401, @"Expected 401 Code.");
    }
    else {
        XCTFail(@"Expected WebAuthentication Error to be returned.");
    }
}

- (void)testItemNotFound {
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];                             // Mock what a task would send to Request Provider
    SFAAsyncRequestProvider *prov = [[SFAAsyncRequestProvider alloc] initWithSFAClient:self.client]; // Request Provider
    SFAHttpRequestResponseDataContainer *container = [self containerForNotFound];                    // Mock Response
    id contextObject = @{};                                                                          // Mock what a task would send to Request Provider
    SFAHttpHandleResponseReturnData *returnedData = [prov task:nil needsResponseHandlingForQuery:query httpRequestResponseDataContainer:container usingContextObject:&(contextObject)];
    if ([returnedData.returnValue isKindOfClass:[SFAODataRequestError class]]) {
        SFAODataRequestError *err = (SFAODataRequestError *)returnedData.returnValue;
        XCTAssertTrue(err.errorType == SFAErrorTypeODataRequestError, @"Expected Error Type to be %ld", SFAErrorTypeODataRequestError);
        XCTAssertTrue([err.language isEqualToString:@"en-US"], @"Expected language to be en-US");
        XCTAssertTrue(err.code == 404, @"Expected 404 Code.");
    }
    else {
        XCTFail(@"Expected ODataRequestError Error to be returned.");
    }
}

- (void)testODataFeedParsing {
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];                             // Mock what a task would send to Request Provider
    query.responseClass = [SFIContact class];
    query.isODataFeed = YES;
    SFAAsyncRequestProvider *prov = [[SFAAsyncRequestProvider alloc] initWithSFAClient:self.client]; // Request Provider
    SFAHttpRequestResponseDataContainer *container = [self containerForODataFeed];                   // Mock Response
    id contextObject = @{};                                                                          // Mock what a task would send to Request Provider
    SFAHttpHandleResponseReturnData *returnedData = [prov task:nil needsResponseHandlingForQuery:query httpRequestResponseDataContainer:container usingContextObject:&(contextObject)];
    if ([returnedData.returnValue isKindOfClass:[SFIODataFeed class]]) {
        SFIODataFeed *feed = (SFIODataFeed *)returnedData.returnValue;
        XCTAssertTrue(feed.count.intValue == 2, @"* Expected Count to be 2");
        XCTAssertTrue(feed.value.count == 2, @"** Expected Count to be 2");
        for (NSObject *obj in feed.value) {
            XCTAssertTrue([obj isKindOfClass:[SFIContact class]], @"Expected value objects to be SFIContact");
        }
        NSDictionary *dictFromFeed = [feed JSONDictionaryRepresentation];
        NSDictionary *dictFromString = [self dictionaryForODataFeedResponse];
        XCTAssertTrue([self compareObjectsInDictionary:dictFromString toDictionary:dictFromFeed], @"Expected Key Values in both dictionaries to be same.");
    }
    else {
        XCTFail(@"Expected ODataFeed to be returned.");
    }
}

- (void)testAsyncRequestProviderInit {
    SFAAsyncRequestProvider *reqProv = [[SFAAsyncRequestProvider alloc] initWithSFAClient:self.client];
    XCTAssertEqual(self.client, reqProv.sfaClient, @"Init with client did not set the client");
    XCTAssertTrue([reqProv isKindOfClass:[SFAAsyncRequestProvider class]], @"Init did not return expected type.");
}

- (void)testTaskWithQuery {
    SFAAsyncRequestProvider *reqProv = [[SFAAsyncRequestProvider alloc] initWithSFAClient:self.client];
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    SFATaskCompletionCallback compCallback = ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) { NSLog(@"Test"); };
    SFATaskCancelCallback cancCallback = ^{ NSLog(@"Test"); };
    id <SFATransferTask> task = [reqProv taskWithQuery:query callbackQueue:nil completionCallback:compCallback cancelCallback:cancCallback];
    XCTAssertTrue([task isKindOfClass:[SFAHttpTask class]], @"taskWithQuery did not return task of expected kind.");
    SFAHttpTask *httpTask = (SFAHttpTask *)task;
    XCTAssertEqual(httpTask.query, query, @"taskWithQuery did not initialize with passed qery");
    XCTAssertEqual(httpTask.completionCallback, compCallback, @"taskWithQuery did not initialize with passed completionCallback");
    XCTAssertEqual(httpTask.cancelCallback, cancCallback, @"taskWithQuery did not initialize with passed cancelCallback");
    XCTAssertEqual(httpTask.queue, [NSOperationQueue mainQueue], @"taskWithQuery did not initialize with default value");
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    httpTask = (SFAHttpTask *)[reqProv taskWithQuery:query callbackQueue:queue completionCallback:compCallback cancelCallback:cancCallback];
    XCTAssertEqual(httpTask.queue, queue, @"taskWithQuery did not initialize with passed queue");
}

- (void)testRequestBuilding {
    SFAAsyncRequestProvider *reqProv = [[SFAAsyncRequestProvider alloc] initWithSFAClient:self.client];
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    query.httpMethod = @"POST";
    query.from = @"entity";
    [query setAction:@"action"];
    [query addIds:@"id1"];
    [query addIds:@"id2"];
    [query addActionIds:@"act1" withKey:@"kact1"];
    [query addActionIds:@"act2"];
    [query addSubAction:@"subaction1" key:nil withValue:@"subact1"];
    [query addSubAction:@"subaction2" key:@"ksubact2" withValue:@"subact2"];
    [query addQueryString:@"k1" withValue:@"q1"];
    [query addQueryString:@"k2" withValue:@"q2"];
    query.body = @{ @"test" : @"test" };
    [query selectProperty:@"test11"];
    [query expandProperty:@"test12"];
    [query selectProperties:@[@"test21"]];
    [query expandProperties:@[@"test22"]];
    [query skip:10];
    [query top:20];
    [query addHeaderWithKey:@"headerKey" value:@"headerValue"];
    [query filterBy:[[SFAEndsWithFilter alloc] initWithPropertyName:@"test31" value:@"abc" isEqual:YES]];
    id <SFATransferTask> task = [reqProv taskWithQuery:query callbackQueue:nil completionCallback:nil cancelCallback:nil];
    NSMutableDictionary *contextObject = [NSMutableDictionary dictionary];
    NSURLRequest *request = [reqProv task:(SFAHttpTask *)task needsRequestForQuery:query usingContextObject:&contextObject];
    // Test
    NSString *urlStringWithoutQueryString = [NSString stringWithFormat:@"%@%@(%@)/%@(%@)/%@(%@)/%@(%@)", self.client.baseUrl, query.from, [self joinByCommaSeparatingCollection:query.ids], query.action.actionName, [self joinByCommaSeparatingCollection:query.action.parameters], ((SFAODataAction *)query.subActions[0]).actionName, [self joinByCommaSeparatingCollection:((SFAODataAction *)query.subActions[0]).parameters], ((SFAODataAction *)query.subActions[1]).actionName, [self joinByCommaSeparatingCollection:((SFAODataAction *)query.subActions[1]).parameters]];
    
    NSString *actualUrlWithoutQueryString = nil;
    NSDictionary *actualQueryStringDict = nil;
    NSRange range = [request.URL.absoluteString rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        actualUrlWithoutQueryString = [request.URL.absoluteString substringToIndex:range.location];
        actualQueryStringDict = [[request.URL.absoluteString substringFromIndex:range.location + 1] queryStringDictionary];
        XCTAssertTrue([actualUrlWithoutQueryString isEqualToString:urlStringWithoutQueryString], @"Invalid URL");
        XCTAssertTrue([request.HTTPMethod isEqualToString:query.httpMethod], @"Invalid Method");
        XCTAssertTrue([request.allHTTPHeaderFields[@"headerKey"] isEqualToString:@"headerValue"], @"Header not found.");
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:kNilOptions error:NULL];
        XCTAssertTrue([self compareObjectsInDictionary:dict toDictionary:query.headers], @"Expected Header dictionary to have same key values.");
        id <NSFastEnumeration> enumerable = [query.queryString collectionAsFastEnumrable];
        for (SFAODataParameter *param in enumerable) {
            XCTAssertTrue([actualQueryStringDict[param.key] isEqualToString:param.value], @"Invalid Query String Value for key's in param.");
        }
        
        NSString *value = [NSString stringWithFormat:@"%d", query.skip];
        XCTAssertTrue([actualQueryStringDict[[@"$skip" escapeString]] isEqualToString:value], @"Invalid Query String Value for key $skip");
        value = [NSString stringWithFormat:@"%d", query.top];
        XCTAssertTrue([actualQueryStringDict[[@"$top" escapeString]] isEqualToString:value], @"Invalid Query String Value for key $top");
        XCTAssertTrue([actualQueryStringDict[[@"$expand" escapeString]] isEqualToString:[[query.expandProperties componentsJoinedByString:@","] escapeString]], @"Invalid Query String Value for key $expand");
        XCTAssertTrue([actualQueryStringDict[[@"$select" escapeString]] isEqualToString:[[query.selectProperties componentsJoinedByString:@","] escapeString]], @"Invalid Query String Value for key $select");
        XCTAssertTrue([actualQueryStringDict[[@"$filter" escapeString]] isEqualToString:[[query.filter description] escapeString]], @"Invalid Query String Value for key $filter");
    }
    else {
        XCTFail(@"Invalid Request URL, not query string found.");
    }
}

#pragma mark - Helper Method(s)

- (SFAHttpRequestResponseDataContainer *)containerForRedirection {
    SFIRedirection *redirection = [SFIRedirection new];
    redirection.Uri = [NSURL URLWithString:@"https://newhost.sharefile.com/sf/v3/"];
    redirection.metadata = @"https://newhost.sharefile.com/sf/v3/$metadata#ShareFile.Api.Models.Redirection@Element";
    NSDictionary *responseDict = [redirection JSONDictionaryRepresentation];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://secure.sf-api.com/sf/v3/Items(random)"]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[request.URL copy] statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{ @"Content-Type" : @"application/json" }];
    NSData *data = [[NSJSONSerialization dataWithJSONObject:responseDict options:kNilOptions error:nil] mutableCopy];
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:request response:response data:data error:nil];
    return container;
}

- (SFAHttpRequestResponseDataContainer *)containerForAsyncOperationScheduled {
    SFIAsyncOperation *op = [SFIAsyncOperation new];
    op.BatchID = @"123123";
    op.BatchSourceID = @"789789";
    op.BatchProgress = [NSNumber numberWithInt:0];
    op.BatchState = @"Scheduled";
    NSDictionary *responseDict = [op JSONDictionaryRepresentation];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://secure.sf-api.com/sf/v3/Items(random)"]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[request.URL copy] statusCode:202 HTTPVersion:@"HTTP/1.1" headerFields:nil];
    NSData *data = [[NSJSONSerialization dataWithJSONObject:responseDict options:kNilOptions error:nil] mutableCopy];
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:request response:response data:data error:nil];
    return container;
}

- (SFAHttpRequestResponseDataContainer *)containerForUnauthorized {
    NSDictionary *responseDict = @{ @"code" : @401, @"message" : @{ @"Language" : @"en - US", @" Message " : @" Unauthorized " }};
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://secure.sf-api.com/sf/v3/Items(random)"]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[request.URL copy] statusCode:401 HTTPVersion:@"HTTP/1.1" headerFields:@{ @"Content-Type" : @"application/json", @"WWW-Authenticate" : @"Bearer" }];
    NSData *data = [[NSJSONSerialization dataWithJSONObject:responseDict options:kNilOptions error:nil] mutableCopy];
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:request response:response data:data error:nil];
    return container;
}

- (SFAHttpRequestResponseDataContainer *)containerForNotFound {
    NSDictionary *responseDict = @{ @"code" : @404, @"message" : @{ @"lang" : @"en-US", @"value" : @"Items: NotFound" }};
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://secure.sf-api.com/sf/v3/Items(random)"]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[request.URL copy] statusCode:404 HTTPVersion:@"HTTP/1.1" headerFields:@{ @"Content-Type" : @"application/json" }];
    NSData *data = [[NSJSONSerialization dataWithJSONObject:responseDict options:kNilOptions error:nil] mutableCopy];
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:request response:response data:data error:nil];
    return container;
}

- (SFAHttpRequestResponseDataContainer *)containerForODataFeed {
    SFIODataFeed *feed = [SFIODataFeed new];
    feed.count = @2;
    feed.metadata = @"https://abc.sf-api.com/sf/v3/$metadata#Contacts";
    feed.url = [NSURL URLWithString:@"https://abc.sf-api.com/sf/v3/Contacts"];
    NSMutableArray *value = [NSMutableArray new];
    for (int i = 0; i < feed.count.intValue; i++) {
        SFIContact *contact = [SFIContact new];
        contact.Name = [NSString stringWithFormat:@"Doe, John%d", i + 1];
        NSString *Id = [NSString stringWithFormat:@"%d-%d", i, i];
        contact.Id = Id;
        contact.IsConfirmed = @1;
        contact.Email = [NSString stringWithFormat:@"john%d.doe@abc.com", i + 1];
        contact.metadata = @"https://abc.sf-api.com/sf/v3/$metadata#Contacts/ShareFile.Api.Models.Contact@Element";
        contact.type = @"ShareFile.Api.Models.Contact";
        contact.url = [NSURL URLWithString:[NSString stringWithFormat:@"https://abc.sf-api.com/sf/v3/Contacts(%@)", Id]];
        
        [value addObject:contact];
    }
    feed.value = value;
    NSDictionary *responseDict = [feed JSONDictionaryRepresentation];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://secure.sf-api.com/sf/v3/Items(random)"]];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[request.URL copy] statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{ @"Content-Type" : @"application/json" }];
    NSData *data = [[NSJSONSerialization dataWithJSONObject:responseDict options:kNilOptions error:nil] mutableCopy];
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:request response:response data:data error:nil];
    return container;
}

- (NSString *)jsonStringForODataFeedResponse {
    return @"{\"odata.metadata\":\"https://abc.sf-api.com/sf/v3/$metadata#Contacts\",\"odata.count\":2,\"value\":[{\"IsConfirmed\":true,\"Name\":\"Doe, John1\",\"Email\":\"john1.doe@abc.com\",\"odata.metadata\":\"https://abc.sf-api.com/sf/v3/$metadata#Contacts/ShareFile.Api.Models.Contact@Element\",\"odata.type\":\"ShareFile.Api.Models.Contact\",\"Id\":\"0-0\",\"url\":\"https://abc.sf-api.com/sf/v3/Contacts(0-0)\"},{\"IsConfirmed\":true,\"Name\":\"Doe, John2\",\"Email\":\"john2.doe@abc.com\",\"odata.metadata\":\"https://abc.sf-api.com/sf/v3/$metadata#Contacts/ShareFile.Api.Models.Contact@Element\",\"odata.type\":\"ShareFile.Api.Models.Contact\",\"Id\":\"1-1\",\"url\":\"https://abc.sf-api.com/sf/v3/Contacts(1-1)\"}],\"url\":\"https://abc.sf-api.com/sf/v3/Contacts\"}";
}

- (NSDictionary *)dictionaryForODataFeedResponse {
    NSString *jsonString = [self jsonStringForODataFeedResponse];
    return [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
}

@end
