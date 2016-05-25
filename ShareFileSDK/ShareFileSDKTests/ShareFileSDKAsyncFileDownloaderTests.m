#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
#import <OCMock/OCMock.h>
#import <objc/runtime.h>

// Hidden APIs
#import "SFAAsyncFileDownloaderInternal.h"
#import "SFAAsyncFileDownloaderProtected.h"
//

@interface ShareFileSDKAsyncFileDownloaderTests : ShareFileSDKTests

@end

@implementation ShareFileSDKAsyncFileDownloaderTests

- (void)testQueryCreation {
    SFItem *item = [SFItem new];
    item.url = [NSURL URLWithString:@"https://subdomain.domain/hash"];
    SFAAsyncFileDownloader *downloader = [[SFAAsyncFileDownloader alloc] initWithItem:item withSFAClient:self.client andDownloaderConfig:nil];
    SFApiQuery *query = [downloader createDownloadQuery];
    XCTAssertTrue(query.ids.count == 1, @"query should have 1 object in ids");
    id <NSFastEnumeration> enumerable = [query.ids collectionAsFastEnumrable];
    for (SFAODataParameter *param in enumerable) {
        XCTAssertTrue([param.value isEqualToString:item.url.absoluteString], @"query's ids should have value same as item.url.absoluteString.");
        break;
    }
    XCTAssertTrue([query.action.actionName isEqualToString:@"Download"], @"*1 query's action should be 'Download'.");
    XCTAssertTrue(query.action.parameters.count == 0, @"*1 query's action should have no parameters.");
    XCTAssertNil(query.headers[@"Range"], @"Range header should not be defined");
    //
    SFADownloaderConfig *config = [SFADownloaderConfig defaultDownloadConfig];
    config.rangeRequest = [SFARangeRequest new];
    config.rangeRequest.begin = [NSNumber numberWithUnsignedLongLong:10];
    downloader = [[SFAAsyncFileDownloader alloc] initWithItem:item withSFAClient:self.client andDownloaderConfig:config];
    query = [downloader createDownloadQuery];
    XCTAssertTrue([query.action.actionName isEqualToString:@"Download"], @"*2 query's action should be 'downloads'.");
    XCTAssertTrue(query.action.parameters.count == 0, @"*2 query's action should have no parameters.");
    XCTAssertTrue([query.headers[@"Range"] isEqualToString:@"bytes=10"], @"Range header should not be defined bytes=10");
    //
    config.rangeRequest.end = [NSNumber numberWithUnsignedLongLong:90];
    downloader = [[SFAAsyncFileDownloader alloc] initWithItem:item withSFAClient:self.client andDownloaderConfig:config];
    query = [downloader createDownloadQuery];
    XCTAssertTrue([query.action.actionName isEqualToString:@"Download"], @"*3 query's action should be 'downloads'.");
    XCTAssertTrue(query.action.parameters.count == 0, @"*3 query's action should have no parameters.");
    XCTAssertTrue([query.headers[@"Range"] isEqualToString:@"bytes=10-90"], @"Range header should not be defined bytes=10-90");
}

- (void)testBackgroundTaskInitializer {
    SFItem *item = [SFItem new];
    item.url = [NSURL URLWithString:@"https://subdomain.domain/hash"];
    NSString *expectedUrl = [NSString stringWithFormat:@"%@/Download", item.url];
    SFAAsyncFileDownloader *downloader = [[SFAAsyncFileDownloader alloc] initWithItem:item withSFAClient:self.client andDownloaderConfig:nil];
    id mockTaskDelegate = OCMProtocolMock(@protocol(SFAURLSessionTaskDelegate));
    NSURLSessionDownloadTask *downloadTask = [downloader downloadBackgroundAsyncWithTaskDelegate:mockTaskDelegate];
    [downloadTask cancel];
    id <SFAURLSessionTaskHttpDelegate> httpDelegate = objc_getAssociatedObject(downloadTask, [kSFAURLSessionTaskRuntimeAssociationHttpDelegate UTF8String]);
    NSMutableDictionary *contextObject = objc_getAssociatedObject(downloadTask, [kSFAURLSessionTaskRuntimeAssociationContextObject UTF8String]);
    
    // Tests
    XCTAssertNotNil(downloader, @"Async download not created properly.");
    XCTAssertTrue([downloadTask.originalRequest.URL.description isEqualToString:expectedUrl], @"Request url is not equal to expected url.");
    XCTAssertNotNil(downloadTask, @"Downloader task not created properly.");
    XCTAssertNotNil(httpDelegate, @"Session task delegate should not be nil.");
    XCTAssertEqual(downloader, httpDelegate, @"Session task delegate not set properly.");
    XCTAssertNotNil(contextObject, @"Contect object should not be nil.");
}

@end
