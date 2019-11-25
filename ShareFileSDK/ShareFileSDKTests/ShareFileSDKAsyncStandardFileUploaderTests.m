#import <Foundation/Foundation.h>
#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
#import <OCMock/OCMock.h>
// Hidden Api's
#import "SFAAsyncStandardFileUploader.h"
#import "SFAAsyncUploaderBaseProtected.h"
#import "SFAUploaderBase.h"
#import "SFAUploaderBaseProtected.h"
#import "SFACompositeUploaderTask.h"
#import "SFACompositeUploaderTaskPrivate.h"
#import "SFAConstants.h"
#import "NSObject+sfapi.h"
#import "SFAAsyncStandardFileUploaderPrivate.h"
#import "SFAuthenticationContext.h"
#import "SFABackgroundUploadInitiationTask.h"
#import "SFABackgroundUploadInitiationTaskInternal.h"
#import "SFAHttpTaskProtected.h"
//

@interface ShareFileSDKAsyncStandardFileUploaderTests : ShareFileSDKTests

@end

@implementation ShareFileSDKAsyncStandardFileUploaderTests

- (void)testInit {
    // 1st Init
    SFAUploadSpecificationRequest *req = [[SFAUploadSpecificationRequest alloc] init];
    SFAFileUploaderConfig *config = [[SFAFileUploaderConfig alloc] init];
    NSString *filepath = @"/somefile";
    SFAAsyncStandardFileUploader *uploader = [[SFAAsyncStandardFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:filepath];
    XCTAssertEqual(self.client, uploader.client, @"*1 Uploader not init with passed client.");
    XCTAssertEqual(req, uploader.uploadSpecificationRequest, @"*1 Uploader not init with passed spec req.");
    XCTAssertTrue([filepath isEqualToString:uploader.fileHandler.filePath], @"*1 Uploader not init with passed file path.");
    XCTAssertTrue(uploader.expirationDays == -1, @"*1 Uploader not init with passed expiration days.");
    XCTAssertTrue(uploader.config != nil, @"*1 Uploader not init with passed config.");
    // 2nd Init
    uploader = [[SFAAsyncStandardFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:filepath fileUploaderConfig:config andExpirationDays:11];
    XCTAssertEqual(self.client, uploader.client, @"*2 Uploader not init with passed client.");
    XCTAssertEqual(req, uploader.uploadSpecificationRequest, @"*2 Uploader not init with passed spec req.");
    XCTAssertTrue([filepath isEqualToString:uploader.fileHandler.filePath], @"*2 Uploader not init with passed file path.");
    XCTAssertTrue(uploader.expirationDays == 11, @"*2 Uploader not init with passed expiration days.");
    XCTAssertEqual(config, uploader.config, @"*2 Uploader not init with passed config.");
}

- (void)testUploadStart {
    SFAUploadSpecificationRequest *req = [SFAUploadSpecificationRequest new];
    req.destinationURI = [NSURL URLWithString:@"http://tests/someparentfolder"];
    SFAAsyncStandardFileUploader *uploader = [[SFAAsyncStandardFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:@""];
    NSDictionary *metadata = @{};
    NSOperationQueue *callbackQueue = [NSOperationQueue new];
    SFATaskCompletionCallback compCB = ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {};
    SFATaskCancelCallback cancelCB = ^{};
    SFATransferTaskProgressCallback progCB = ^(SFATransferProgress *transferProgress) {};
    id <SFATransferTask> transferTask = [uploader uploadAsyncWithTransferData:metadata callbackQueue:callbackQueue completionCallback:compCB cancelCallback:cancelCB progressCallback:progCB];
    // Test
    XCTAssertTrue([transferTask isKindOfClass:[SFACompositeUploaderTask class]], @"returned task of unexpected kind");
    SFACompositeUploaderTask *compositeUploaderTask = (SFACompositeUploaderTask *)transferTask;
    XCTAssertEqual(compositeUploaderTask.transferMetaData, metadata, @"metadata not set properly.");
    XCTAssertEqual(compositeUploaderTask.queue, callbackQueue, @"callback queue not set properly.");
    XCTAssertEqual(compositeUploaderTask.completionCallback, compCB, @"completion cb not set properlly");
    XCTAssertEqual(compositeUploaderTask.cancelCallback, cancelCB, @"cancel cb not set properlly");
    XCTAssertEqual(compositeUploaderTask.progressCallback, progCB, @"progress cb not set properlly");
    XCTAssertTrue(compositeUploaderTask.uploadMethod == SFAUploadMethodStandard, @"upload method should be standard");
    XCTAssertNotNil(compositeUploaderTask.uploadspecificationTask, @"upload spec task should not be nil.");
    XCTAssertNil(compositeUploaderTask.finishUploadTask, @"finish task should be nil.");
    XCTAssertTrue(compositeUploaderTask.concurrentExecutionCount == 1, @"concurrent execution count should be one.");
    //
}

- (void)testFinishedSpecTaskDelegate {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestFile" ofType:@"txt"];
    SFAUploadSpecificationRequest *req = [SFAUploadSpecificationRequest new];
    req.destinationURI = [NSURL URLWithString:@"http://tests/someparentfolder"];
    SFAAsyncStandardFileUploader *uploader = [[SFAAsyncStandardFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:path];
    SFUploadSpecification *uploadSpec = [[SFUploadSpecification alloc] init];
    uploadSpec.IsResume = [NSNumber numberWithBool:YES];
    uploadSpec.ResumeOffset = [NSNumber numberWithUnsignedLongLong:10];
    uploadSpec.ResumeIndex = [NSNumber numberWithUnsignedLongLong:1];
	uploadSpec.ResumeFileHash = @"b9618d25d35b99e270b860f2c1bf10aa"; // Hash of first 10 bytes calculated offline.
	NSNumber *prevIndex = uploadSpec.ResumeIndex;
    XCTAssertFalse(uploader.prepared, @"*1 uploader should not be prepared.");
    [((id < SFACompositeTaskDelegate >)uploader)compositeTask:nil finishedSpecificationTaskWithUploadSpec:uploadSpec];
    XCTAssertTrue(uploader.prepared, @"*1 uploader should be prepared.");
    XCTAssertTrue(uploader.uploadSpecification.ResumeIndex.unsignedLongLongValue - 1 == prevIndex.unsignedLongLongValue, @"uploader should have increased the index by 1.");
    
    // Test again with different params
    uploader = [[SFAAsyncStandardFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:@""];
    uploadSpec.ResumeFileHash = @"aaa"; // Hash should not match
    XCTAssertFalse(uploader.prepared, @"*2 uploader should not be prepared.");
    [((id < SFACompositeTaskDelegate >)uploader)compositeTask:nil finishedSpecificationTaskWithUploadSpec:uploadSpec];
    XCTAssertTrue(uploader.prepared, @"*2 uploader should be prepared.");
    XCTAssertTrue(uploader.uploadSpecification.ResumeIndex.unsignedLongLongValue == 0, @"*1 Expected Index to be 0.");
    XCTAssertTrue(uploader.uploadSpecification.ResumeOffset.unsignedLongLongValue == 0, @"*1 Expected Offset to be 0.");
}

- (void)testInitProgressAndRequestBulding {
    self.client.authHandler = OCMPartialMock((NSObject *)self.client.authHandler);
    [OCMStub([self.client.authHandler prepareRequest:OCMOCK_ANY authContext:OCMOCK_ANY interactiveHandler:OCMOCK_ANY]) andReturn:[SFAuthenticationContext new]];
    // self.client.authHandler = nil;
    SFAUploadSpecificationRequest *req = [SFAUploadSpecificationRequest new];
    req.destinationURI = [NSURL URLWithString:@"http://tests/someparentfolder"];
    NSString *filepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestFile" ofType:@"txt"];
    SFAFileInfo *fileInfo = [[SFAFileInfo alloc] initWithFilePath:filepath];
    NSNumber *fileSize = fileInfo.fileSize;
    SFAAsyncStandardFileUploader *uploader = [[SFAAsyncStandardFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:filepath];
    [uploader initializeBodyLengthForTask:nil];
    unsigned long long expectedSize = fileSize.unsignedLongLongValue + 118 + 47;
    XCTAssertTrue(uploader.bodyLength == (expectedSize), @"wrong body length for file");
    // Request Building Part
    NSMutableDictionary *contextObject = [NSMutableDictionary new];
    NSURLRequest *request = [uploader task:nil needsRequestForQuery:nil usingContextObject:&contextObject];
    XCTAssertTrue([request.HTTPMethod isEqualToString:SFAPost], @"Method should be post");
    XCTAssertNotNil(request.HTTPBodyStream, @"Stream should be non-nil");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAContentType] rangeOfString:SFAMultiPartFormData].location != NSNotFound, @"Content Type header should be found.");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAContentLength] intValue] == expectedSize, @"Content Length header should be found.");
//
#if TARGET_OS_IPHONE
    id mockAsset = OCMClassMock([ALAsset class]);
    id mockRep = OCMClassMock([ALAssetRepresentation class]);
    OCMStub([mockAsset defaultRepresentation]).andReturn(mockRep);
    OCMStub([(ALAssetRepresentation *) mockRep size]).andReturn((long long)10);
    OCMStub([mockRep filename]).andReturn(@"TestFile.txt");
#if ShareFile
    uploader = [[SFAAsyncStandardFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req asset:mockAsset andExpirationDays:-1];
#else
    uploader = [[SFAAsyncStandardFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req asset:mockAsset];
#endif
    [uploader initializeBodyLengthForTask:nil];
    expectedSize = 10 + 118 + 47;
    XCTAssertTrue(uploader.bodyLength == expectedSize, @"wrong body length for asset");
    // Request Building Part
    contextObject = [NSMutableDictionary new];
    request = [uploader task:nil needsRequestForQuery:nil usingContextObject:&contextObject];
    XCTAssertTrue([request.HTTPMethod isEqualToString:SFAPost], @"Method should be post");
    XCTAssertNotNil(request.HTTPBodyStream, @"Stream should be non-nil");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAContentType] rangeOfString:SFAMultiPartFormData].location != NSNotFound, @"Content Type header should be found.");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAContentLength] intValue] == expectedSize, @"Content Length header should be found.");
    
#endif
}

- (void)testResponseHandling {
    self.client.authHandler = nil; // We are not teting auth handler
    SFAUploadSpecificationRequest *req = [SFAUploadSpecificationRequest new];
    SFAAsyncStandardFileUploader *uploader = [[SFAAsyncStandardFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:@""];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    // JSON error
    SFAHttpHandleResponseReturnData *data = [uploader task:nil needsResponseHandlingForQuery:nil httpRequestResponseDataContainer:[self jsonErrorContainer] usingContextObject:&dict];
    XCTAssertTrue(data.responseAction == SFAHttpHandleResponseActionComplete, @"*1 Expected action to be complete");
    XCTAssertTrue([data.returnValue isKindOfClass:[SFAError class]], @"*1 Expected return value to be SFAError");
    XCTAssertTrue(((SFAError *)data.returnValue).errorType == SFAErrorTypeInvalidResponseError, @"*1 Unexpected error type");
    
    // Error Response
    data = [uploader task:nil needsResponseHandlingForQuery:nil httpRequestResponseDataContainer:[self errorContainer] usingContextObject:&dict];
    XCTAssertTrue(data.responseAction == SFAHttpHandleResponseActionComplete, @"*2 Expected action to be complete");
    XCTAssertTrue([data.returnValue isKindOfClass:[SFAError class]], @"*2 Expected return value to be SFAError");
    XCTAssertTrue([((SFAError *)data.returnValue).message isEqualToString:@"Error Message"], @"*2 Unexpected message value");
    XCTAssertTrue(((SFAError *)data.returnValue).errorType == SFAErrorTypeUploadError, @"*2 Unexpected error type");
    XCTAssertTrue(((SFAError *)data.returnValue).code == 10, @"ErrorCode should be = 10");
    
    // Retry Count Exceed
    dict[SFARetryCount] = @4;
    data = [uploader task:nil needsResponseHandlingForQuery:nil httpRequestResponseDataContainer:[self httpFailureContainer] usingContextObject:&dict];
    XCTAssertTrue(data.responseAction == SFAHttpHandleResponseActionComplete, @"*3 Expected action to be complete");
    
    //
    dict[SFARetryCount] = @1;
    data = [uploader task:nil needsResponseHandlingForQuery:nil httpRequestResponseDataContainer:[self httpFailureContainer] usingContextObject:&dict];
    XCTAssertTrue(data.responseAction == SFAHttpHandleResponseActionReExecute, @"*4 Expected action to be re-execute");
    XCTAssertTrue(((NSNumber *)dict[SFARetryCount]).intValue == 2, @"*4 Retry Count should be 2");
    
    //
    SFAHttpRequestResponseDataContainer *container = [self containerForUploadResponse];
    data = [uploader task:nil needsResponseHandlingForQuery:nil httpRequestResponseDataContainer:container usingContextObject:&dict];
    XCTAssertTrue(data.responseAction == SFAHttpHandleResponseActionComplete, @"*4 Expected action to be complete");
    XCTAssertTrue([data.returnValue isKindOfClass:[SFAUploadResponse class]], @"*4 Expected return value to be of kind Upload Response");
    SFAUploadResponse *uploadResponse = (SFAUploadResponse *)data.returnValue;
    NSDictionary *jsonRep = [uploadResponse JSONDictionaryRepresentation];
    NSDictionary *originJSONRep = [self dictionaryForUploadResponse];
    XCTAssertTrue([self compareObjectsInDictionary:jsonRep toDictionary:originJSONRep], @"*4 Expected both JSON reps to be identical");
}

- (void)testBackgroundUploadStart {
    SFAUploadSpecificationRequest *req = [SFAUploadSpecificationRequest new];
    req.destinationURI = [NSURL URLWithString:@"http://tests/someparentfolder"];
    SFAAsyncStandardFileUploader *uploader = [[SFAAsyncStandardFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:@""];
    NSOperationQueue *callbackQueue = [NSOperationQueue new];
    SFATaskCompletionCallback compCB = ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {};
    SFATaskCancelCallback cancelCB = ^{};
    id mockDelegate = OCMProtocolMock(@protocol(SFAURLSessionTaskDelegate));
    id <SFATransferTask> transferTask = [uploader uploadBackgroundAsyncWithTaskDelegate:mockDelegate callbackQueue:callbackQueue completionCallback:compCB cancelCallback:cancelCB];
    
    // Test
    SFABackgroundUploadInitiationTask *bgUploaderTask = (SFABackgroundUploadInitiationTask *)transferTask;
    XCTAssertNotNil(bgUploaderTask, @"Background Uploader task not created properly.");
    XCTAssertTrue([transferTask isKindOfClass:[SFABackgroundUploadInitiationTask class]], @"returned task of unexpected kind");
    XCTAssertEqual(bgUploaderTask.queue, callbackQueue, @"callback queue not set properly.");
    XCTAssertEqual(bgUploaderTask.completionCallback, compCB, @"completion cb not set properlly");
    XCTAssertEqual(bgUploaderTask.cancelCallback, cancelCB, @"cancel cb not set properlly");
    XCTAssertTrue([bgUploaderTask.delegate conformsToProtocol:@protocol(SFAHttpTaskDelegate)], @"Async Request provider not set properly.");
    XCTAssertEqual(bgUploaderTask.urlSessionTaskDelegate, mockDelegate, @"URL session task delegate not set properly.");
    XCTAssertTrue([bgUploaderTask.backgroundUploadInitiationTaskDelegate conformsToProtocol:@protocol(SFABackgroundUploadInitiationTaskDelegate)], @"Background upload initiation task delegate not set properly.");
}

- (void)testBackgroundUploadTaskRequest {
    id mockClient = OCMClassMock([SFAClient class]);
    SFAUploadSpecificationRequest *req = [SFAUploadSpecificationRequest new];
    SFUploadSpecification *uploadSpec = [[SFUploadSpecification alloc] init];
    uploadSpec.ChunkUri = [NSURL URLWithString:@"http://sub.domain.com?q=1"];
    SFABackgroundSessionManager *session = [[SFABackgroundSessionManager alloc] initWithClient:mockClient];
    NSString *filepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestFile" ofType:@"txt"];
    SFAAsyncStandardFileUploader *uploader = [[SFAAsyncStandardFileUploader alloc] initWithSFAClient:mockClient uploadSpecificationRequest:req filePath:filepath];
    uploader.uploadSpecification = uploadSpec;
    
    NSURLSessionTask *task = [uploader URLSession:[session backgroundSession] taskNeedsNewTask:nil];
    NSString *expectedUrl = [NSString stringWithFormat:@"%@&fmt=json", uploadSpec.ChunkUri];
    XCTAssertNotNil(task, @"Background Uploader task not created properly.");
    XCTAssertTrue([task.originalRequest.URL.description isEqualToString:expectedUrl], @"Request url is not equal to expected url.");
}

- (NSDictionary *)dictionaryForUploadResponse {
    NSMutableArray *filesJSONArray = [NSMutableArray new];
    int count = 3;
    for (int i = 0; i < count; i++) {
        NSMutableDictionary *fileJSONDictionary = [NSMutableDictionary new];
        fileJSONDictionary[SFADisplayName] = [NSString stringWithFormat:@"SomeDisplayName-%d", i];
        fileJSONDictionary[SFAFileName] = [NSString stringWithFormat:@"SomeFileName-%d", i];
        fileJSONDictionary[SFAId] = [NSString stringWithFormat:@"ID-%d", i];
        fileJSONDictionary[SFAMd5] = [NSString stringWithFormat:@"HASH-%d", i];
        fileJSONDictionary[SFASize] = [NSNumber numberWithUnsignedLongLong:(10 + (i * 10))];
        fileJSONDictionary[SFAUploadId] = [NSString stringWithFormat:@"UploadId-%d", i];
        [filesJSONArray addObject:[fileJSONDictionary copy]];
    }
    return @{ SFAValue : [filesJSONArray copy] };
}

- (SFAHttpRequestResponseDataContainer *)jsonErrorContainer {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://secure.sf-api.com/sf/v3/upload"]];
    NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[request.URL copy] statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{ @"Content-Type" : @"application/json" }];
    NSData *data = [@"\"key\":\"value" dataUsingEncoding:NSUTF8StringEncoding];
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:request response:httpResponse data:data error:nil];
    return container;
}

- (SFAHttpRequestResponseDataContainer *)errorContainer {
    NSDictionary *responseDict = @{ SFAErrorString : [NSNumber numberWithBool:YES], SFAErrorCode : [NSNumber numberWithInt:10], SFAErrorMessage : @"Error Message" };
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://secure.sf-api.com/sf/v3/upload"]];
    NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[request.URL copy] statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{ @"Content-Type" : @"application/json" }];
    NSData *data = [[NSJSONSerialization dataWithJSONObject:responseDict options:kNilOptions error:nil] mutableCopy];
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:request response:httpResponse data:data error:nil];
    return container;
}

- (SFAHttpRequestResponseDataContainer *)httpFailureContainer {
    NSDictionary *responseDict = @{};
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://secure.sf-api.com/sf/v3/upload"]];
    NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[request.URL copy] statusCode:404 HTTPVersion:@"HTTP/1.1" headerFields:@{ @"Content-Type" : @"application/json" }];
    NSData *data = [[NSJSONSerialization dataWithJSONObject:responseDict options:kNilOptions error:nil] mutableCopy];
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:request response:httpResponse data:data error:nil];
    return container;
}

- (SFAHttpRequestResponseDataContainer *)containerForUploadResponse {
    NSDictionary *responseDict = [self dictionaryForUploadResponse];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://secure.sf-api.com/sf/v3/upload"]];
    NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[request.URL copy] statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{ @"Content-Type" : @"application/json" }];
    NSData *data = [[NSJSONSerialization dataWithJSONObject:responseDict options:kNilOptions error:nil] mutableCopy];
    SFAHttpRequestResponseDataContainer *container = [[SFAHttpRequestResponseDataContainer alloc] initWithRequest:request response:httpResponse data:data error:nil];
    return container;
}

@end
