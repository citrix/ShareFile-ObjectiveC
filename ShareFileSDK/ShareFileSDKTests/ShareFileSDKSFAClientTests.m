#import <Foundation/Foundation.h>
#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
#import <OCMock/OCMock.h>
// Hidden APIs
#import "SFAUploaderBaseProtected.h"
#import "SFAAsyncUploaderBaseProtected.h"
#import "SFAAsyncStandardFileUploader.h"
#import "SFAAsyncThreadedFileUploader.h"
#import "SFAAsyncFileDownloaderProtected.h"
//

@interface ShareFileSDKSFAClientTests : ShareFileSDKTests

@end

@implementation ShareFileSDKSFAClientTests

- (void)testErrorHandlers {
    id mockContainer = OCMClassMock([SFAHttpRequestResponseDataContainer class]);
    int retry = 111;
    __block BOOL errorHandler1Raised = NO;
    SFAErrorCallback handler1 = ^SFAEventHandlerResponse * (SFAHttpRequestResponseDataContainer *container, int retryCount)
    {
        if ([mockContainer isEqual:container] && retryCount == retry) {
            errorHandler1Raised = YES;
        }
        return [SFAEventHandlerResponse ignoreEventResponseHandler];
    };
    __block BOOL errorHandler2Raised = NO;
    SFAErrorCallback handler2 = ^SFAEventHandlerResponse * (SFAHttpRequestResponseDataContainer *container, int retryCount)
    {
        if ([mockContainer isEqual:container] && retryCount == retry) {
            errorHandler2Raised = YES;
        }
        return [SFAEventHandlerResponse ignoreEventResponseHandler];
    };
    
    [self.client addErrorHandler:handler1];
    [self.client addErrorHandler:handler2];
    SFAEventHandlerResponse *resp = [self.client onErrorWithDataContainer:mockContainer retryCount:retry];
    XCTAssertTrue(errorHandler1Raised, @"Error handler1 not called.");
    XCTAssertTrue(errorHandler1Raised, @"Error handler2 not called.");
    XCTAssertTrue(resp.action == SFAEventHandlerResponseActionFailWithError, @"Expected Action to be Fail With Error");
    [self.client removeErrorHandler:handler1];
    [self.client removeErrorHandler:handler2];
    errorHandler1Raised = NO;
    errorHandler2Raised = NO;
    __block BOOL errorHandler3Raised = NO;
    SFAErrorCallback handler3 = ^SFAEventHandlerResponse * (SFAHttpRequestResponseDataContainer *container, int retryCount)
    {
        if ([mockContainer isEqual:container] && retryCount == retry) {
            errorHandler3Raised = YES;
        }
        return [SFAEventHandlerResponse eventHandlerResponseWithAction:SFAEventHandlerResponseActionRetry];
    };
    __block BOOL errorHandler4Raised = NO;
    SFAErrorCallback handler4 = ^SFAEventHandlerResponse * (SFAHttpRequestResponseDataContainer *container, int retryCount)
    {
        errorHandler4Raised = YES;
        return [SFAEventHandlerResponse ignoreEventResponseHandler];
    };
    [self.client addErrorHandler:handler3];
    [self.client addErrorHandler:handler4];
    resp = [self.client onErrorWithDataContainer:mockContainer retryCount:retry];
    XCTAssertFalse(errorHandler1Raised, @"Error handler1 should not be called.");
    XCTAssertFalse(errorHandler2Raised, @"Error handler2 should not be called.");
    XCTAssertFalse(errorHandler4Raised, @"Error handler4 should not be called.");
    XCTAssertTrue(errorHandler3Raised, @"Error handler3 not called.");
    XCTAssertTrue(resp.action == SFAEventHandlerResponseActionRetry, @"*2 Expected Action to be Retry");
}

- (void)testChangeDomainHandlers {
    id mockRequest = OCMClassMock([NSURLRequest class]);
    id mockRedirection = OCMClassMock([SFIRedirection class]);
    id mockRedirection2 = OCMClassMock([SFIRedirection class]);
    __block BOOL changeDomain1Raised = NO;
    SFAChangeDomainCallback handler1 = ^SFAEventHandlerResponse * (NSURLRequest *request, SFIRedirection *redirect)
    {
        if ([mockRequest isEqual:request] && [mockRedirection isEqual:redirect]) {
            changeDomain1Raised = YES;
        }
        return [SFAEventHandlerResponse ignoreEventResponseHandler];
    };
    __block BOOL changeDomain2Raised = NO;
    SFAChangeDomainCallback handler2 = ^SFAEventHandlerResponse * (NSURLRequest *request, SFIRedirection *redirect)
    {
        if ([mockRequest isEqual:request] && [mockRedirection isEqual:redirect]) {
            changeDomain2Raised = YES;
        }
        return [SFAEventHandlerResponse ignoreEventResponseHandler];
    };
    
    [self.client addChangeDomainHandler:handler1];
    [self.client addChangeDomainHandler:handler2];
    SFAEventHandlerResponse *resp = [self.client onChangeDomainWithRequest:mockRequest redirection:mockRedirection];
    XCTAssertTrue(changeDomain1Raised, @"Change domain handler1 not called.");
    XCTAssertTrue(changeDomain2Raised, @"Change domain handler2 not called.");
    XCTAssertTrue(resp.action == SFAEventHandlerResponseActionRedirect, @"*1 Expected Action to be Re-direct");
    XCTAssertTrue([resp.redirection isEqual:mockRedirection], @"Expected redirect to be same as passed");
    [self.client removeChangeDomainHandler:handler1];
    [self.client removeChangeDomainHandler:handler2];
    changeDomain1Raised = NO;
    changeDomain2Raised = NO;
    __block BOOL changeDomain3Raised = NO;
    SFAChangeDomainCallback handler3 = ^SFAEventHandlerResponse * (NSURLRequest *request, SFIRedirection *redirect)
    {
        if ([mockRequest isEqual:request] && [mockRedirection isEqual:redirect]) {
            changeDomain3Raised = YES;
        }
        return [SFAEventHandlerResponse eventHandlerResponseWithRedirection:mockRedirection2];
    };
    __block BOOL changeDomain4Raised = NO;
    SFAChangeDomainCallback handler4 = ^SFAEventHandlerResponse * (NSURLRequest *request, SFIRedirection *redirect)
    {
        changeDomain4Raised = YES;
        return [SFAEventHandlerResponse ignoreEventResponseHandler];
    };
    [self.client addChangeDomainHandler:handler3];
    [self.client addChangeDomainHandler:handler4];
    resp = [self.client onChangeDomainWithRequest:mockRequest redirection:mockRedirection];
    XCTAssertFalse(changeDomain1Raised, @"Change domain handler1 should not be called.");
    XCTAssertFalse(changeDomain2Raised, @"Change domain handler2 should not be called.");
    XCTAssertFalse(changeDomain4Raised, @"Change domain handler4 should not be called.");
    XCTAssertTrue(changeDomain3Raised, @"Change domain handler3 should be called.");
    XCTAssertTrue(resp.action == SFAEventHandlerResponseActionRedirect, @"*2 Expected Action to be Re-direct");
    XCTAssertTrue([resp.redirection isEqual:mockRedirection2], @"Expected redirect to be mockRedirection2");
}

- (void)testUploaderInitializationThroughClient {
    // Standard
    SFAUploadSpecificationRequest *specReq = [[SFAUploadSpecificationRequest alloc] init];
    specReq.method = SFAUploadMethodStandard;
    SFAFileUploaderConfig *config = [SFAFileUploaderConfig new];
    SFAUploaderBase *uploader = nil;
    int expirationDays = -1;
#if ShareFile
    expirationDays = arc4random();
    uploader = [self.client asyncFileUploaderWithUploadSpecificationRequest:specReq filePath:@"somepath" fileUploaderConfig:config expirationDays:expirationDays];
#else
    uploader = [self.client asyncFileUploaderWithUploadSpecificationRequest:specReq filePath:@"somepath" fileUploaderConfig:config];
#endif
    // Test
    XCTAssertTrue([uploader isKindOfClass:[SFAAsyncStandardFileUploader class]], @"Standard uploader expected.");
    XCTAssertEqual(self.client, uploader.client, @"* Client should be same as the one from which uploader is created.");
    XCTAssertTrue([uploader.fileHandler.filePath isEqualToString:@"somepath"], @"* Path should be same as passed asset.");
    XCTAssertEqual(specReq, uploader.uploadSpecificationRequest, @"* Spec Request should be same as passed.");
    XCTAssertEqual(config, ((SFAAsyncUploaderBase *)uploader).config, @"** Config should be same as passed.");
    XCTAssertTrue(expirationDays == uploader.expirationDays, @"* Expiration Days should be -1");
    // Threaded
    specReq.method = SFAUploadMethodThreaded;
#if ShareFile
    uploader = [self.client asyncFileUploaderWithUploadSpecificationRequest:specReq filePath:@"somepath" fileUploaderConfig:config expirationDays:expirationDays];
#else
    uploader = [self.client asyncFileUploaderWithUploadSpecificationRequest:specReq filePath:@"somepath" fileUploaderConfig:config];
#endif
    XCTAssertTrue([uploader isKindOfClass:[SFAAsyncThreadedFileUploader class]], @"Threaded uploader expected.");
    XCTAssertEqual(self.client, uploader.client, @"** Client should be same as the one from which uploader is created.");
    XCTAssertTrue([uploader.fileHandler.filePath isEqualToString:@"somepath"], @"** Path should be same as passed asset.");
    XCTAssertEqual(specReq, uploader.uploadSpecificationRequest, @"** Spec Request should be same as passed.");
    XCTAssertEqual(config, ((SFAAsyncUploaderBase *)uploader).config, @"** Config should be same as passed.");
    XCTAssertTrue(expirationDays == uploader.expirationDays, @"**  Expiration Days should be -1");
}

- (void)testDownloaderInitialization {
    id mockItem = OCMClassMock([SFIItem class]);
    id mockDownloaderConfig = OCMClassMock([SFADownloaderConfig class]);
    SFAAsyncFileDownloader *downloader = [self.client asyncFileDownloaderForItem:mockItem withDownloaderConfig:mockDownloaderConfig];
    XCTAssertEqual(self.client, downloader.sfaClient, @"Client should be same as the one from which downloader is created.");
    XCTAssertEqual(downloader.item, mockItem, @"* Downloader not init with passed parameter.");
    XCTAssertEqual(downloader.config, mockDownloaderConfig, @"** Downloader not init with passed parameter.");
}

- (void)testTaskWithQuery {
    SFATaskCompletionCallback compCB = ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {};
    SFATaskCancelCallback canCB = ^() {};
    id mockQuery = OCMProtocolMock(@protocol(SFAQuery));
    NSOperationQueue *queue = [NSOperationQueue new];
    id <SFATask> task = [self.client taskWithQuery:mockQuery callbackQueue:queue completionCallback:compCB cancelCallback:canCB];
    XCTAssertNotNil(task, @"Task should be defined");
    XCTAssertEqual(task.completionCallback, compCB, @"Completion callback should be same as passed");
    XCTAssertEqual(task.cancelCallback, canCB, @"Cancel callback should be same as passed");
}

@end
