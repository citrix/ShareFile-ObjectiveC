#import <Foundation/Foundation.h>
#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
#import <OCMock/OCMock.h>
// Hidden Api's
#import "SFAAsyncThreadedFileUploader.h"
#import "SFAUploaderBase.h"
#import "SFAUploaderBaseProtected.h"
#import "SFAAsyncUploaderBaseProtected.h"
#import "SFACompositeUploaderTask.h"
#import "SFACompositeUploaderTaskInternal.h"
#import "SFACompositeUploaderTaskPrivate.h"
#import "SFAHttpTaskProtected.h"
#import "SFAConstants.h"
#import "NSObject+sfapi.h"
#import "SFAApiResponse.h"
#import "SFAFilePart.h"
#import "SFACryptoUtils.h"
//

@interface ShareFileSDKAsyncThreadedFileUploaderTests : ShareFileSDKTests

@end

@implementation ShareFileSDKAsyncThreadedFileUploaderTests

- (void)testInit {
    // 1st Init
    SFAUploadSpecificationRequest *req = [[SFAUploadSpecificationRequest alloc] init];
    SFAFileUploaderConfig *config = [[SFAFileUploaderConfig alloc] init];
    NSString *filepath = @"/somefile";
    SFAAsyncThreadedFileUploader *uploader = [[SFAAsyncThreadedFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:filepath];
    XCTAssertEqual(self.client, uploader.client, @"*1 Uploader not init with passed client.");
    XCTAssertEqual(req, uploader.uploadSpecificationRequest, @"*1 Uploader not init with passed spec req.");
    XCTAssertTrue([filepath isEqualToString:uploader.fileHandler.filePath], @"*1 Uploader not init with passed file path.");
    XCTAssertTrue(uploader.expirationDays == -1, @"*1 Uploader not init with passed expiration days.");
    XCTAssertTrue(uploader.config != nil, @"*1 Uploader not init with passed config.");
    // 2nd Init
    uploader = [[SFAAsyncThreadedFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:filepath fileUploaderConfig:config andExpirationDays:11];
    XCTAssertEqual(self.client, uploader.client, @"*2 Uploader not init with passed client.");
    XCTAssertEqual(req, uploader.uploadSpecificationRequest, @"*2 Uploader not init with passed spec req.");
    XCTAssertTrue([filepath isEqualToString:uploader.fileHandler.filePath], @"*2 Uploader not init with passed file path.");
    XCTAssertTrue(uploader.expirationDays == 11, @"*2 Uploader not init with passed expiration days.");
    XCTAssertEqual(config, uploader.config, @"*2 Uploader not init with passed config.");
}

- (void)testUploadStart {
    SFAUploadSpecificationRequest *req = [SFAUploadSpecificationRequest new];
    req.destinationURI = [NSURL URLWithString:@"http://tests/someparentfolder"];
    SFAAsyncThreadedFileUploader *uploader = [[SFAAsyncThreadedFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:@""];
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
    XCTAssertTrue(compositeUploaderTask.uploadMethod == SFAUploadMethodThreaded, @"upload method should be threaded");
    XCTAssertNotNil(compositeUploaderTask.uploadspecificationTask, @"upload spec task should not be nil.");
    XCTAssertNotNil(compositeUploaderTask.finishUploadTask, @"finish task should be non-nil.");
    XCTAssertTrue(compositeUploaderTask.concurrentExecutionCount == uploader.config.numberOfThreads, @"concurrent execution count should be same as passed in config.");
    //
}

- (void)testFinishedSpecTaskDelegate {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestFile" ofType:@"txt"];
    // Paste block above here for offline data read.
    // Then go to http://www.fileformat.info/tool/hash.htm?hex=efbbbf55706c6f616465 to find md5 hash.
    SFAUploadSpecificationRequest *req = [SFAUploadSpecificationRequest new];
    req.destinationURI = [NSURL URLWithString:@"http://tests/someparentfolder"];
    SFAAsyncThreadedFileUploader *uploader = [[SFAAsyncThreadedFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:path];
    SFIUploadSpecification *uploadSpec = [[SFIUploadSpecification alloc] init];
    uploadSpec.IsResume = [NSNumber numberWithBool:YES];
    uploadSpec.ResumeOffset = [NSNumber numberWithUnsignedLongLong:10];
    uploadSpec.ResumeIndex = [NSNumber numberWithUnsignedLongLong:1];
    uploadSpec.ResumeFileHash = @"b9618d25d35b99e270b860f2c1bf10aa"; // Hash after first 10 bytes calculated offline.
    uploadSpec.ChunkUri = [NSURL URLWithString:@"http://sub.domain.com?q=1"];
    NSNumber *prevIndex = uploadSpec.ResumeIndex;
    XCTAssertFalse(uploader.prepared, @"*1 uploader should not be prepared.");
    SFACompositeUploaderTask *compositeTask = [SFACompositeUploaderTask new];
    [((id < SFACompositeTaskDelegate >)uploader)compositeTask:compositeTask finishedSpecificationTaskWithUploadSpec:uploadSpec];
    XCTAssertTrue(uploader.prepared, @"*1 uploader should be prepared.");
    XCTAssertTrue(uploader.uploadSpecification.ResumeIndex.unsignedLongLongValue - 1 == prevIndex.unsignedLongLongValue, @"uploader should have increased the index by 1.");
    // Part
    NSArray *uploaderTasks = compositeTask.uploaderTasks;
    XCTAssertTrue(uploaderTasks.count == 1, @"*1 Expected 1 uploader task");
    XCTAssertTrue([uploaderTasks[0] isKindOfClass:[SFAUploaderTask class]], @"*1 Expected uploader task");
    SFAUploaderTask *uploaderTask = (SFAUploaderTask *)uploaderTasks[0];
    XCTAssertNotNil(uploaderTask.contextObject[SFAFilePartString], @"*1 Expected file part to be present");
    SFAFilePart *part = uploaderTask.contextObject[SFAFilePartString];
    XCTAssertTrue(part.isLastPart, @"*1 File Part should have been last");
    XCTAssertTrue(part.length == uploader.config.partSize, @"*1 Unexpected file part length.");
    XCTAssertTrue(part.offset == 10, @"*1 Unexpected file part offset.");
    XCTAssertTrue(part.index == 2, @"*1 Unexpected file part index.");
    XCTAssertTrue(part.uploadUrl == uploadSpec.ChunkUri.absoluteString, @"*1 Unexpected upload url.");
    compositeTask.uploaderTasks = nil;
    //
    // Test again with different params
    uploader = [[SFAAsyncThreadedFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:path];
    uploadSpec.ResumeFileHash = @"aaa"; // Hash should not match
    XCTAssertFalse(uploader.prepared, @"*2 uploader should not be prepared.");
    [((id < SFACompositeTaskDelegate >)uploader)compositeTask:compositeTask finishedSpecificationTaskWithUploadSpec:uploadSpec];
    XCTAssertTrue(uploader.prepared, @"*2 uploader should be prepared.");
    XCTAssertTrue(uploader.uploadSpecification.ResumeIndex.unsignedLongLongValue == 0, @"*1 Expected Index to be 0.");
    XCTAssertTrue(uploader.uploadSpecification.ResumeOffset.unsignedLongLongValue == 0, @"*1 Expected Offset to be 0.");
    // Part
    uploaderTasks = compositeTask.uploaderTasks;
    XCTAssertTrue(uploaderTasks.count == 1, @"*2 Expected 1 uploader task");
    XCTAssertTrue([uploaderTasks[0] isKindOfClass:[SFAUploaderTask class]], @"*2 Expected uploader task");
    uploaderTask = (SFAUploaderTask *)uploaderTasks[0];
    XCTAssertNotNil(uploaderTask.contextObject[SFAFilePartString], @"*2 Expected file part to be present");
    part = uploaderTask.contextObject[SFAFilePartString];
    XCTAssertTrue(part.isLastPart, @"*2 File Part should have been last");
    XCTAssertTrue(part.length == uploader.config.partSize, @"*2 Unexpected file part length.");
    XCTAssertTrue(part.offset == 0, @"*2 Unexpected file part offset.");
    XCTAssertTrue(part.index == 0, @"*2 Unexpected file part index.");
    XCTAssertTrue(part.uploadUrl == uploadSpec.ChunkUri.absoluteString, @"*2 Unexpected upload url.");
    compositeTask.uploaderTasks = nil;
    //
}

- (void)testRequestBuilding {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestFile" ofType:@"txt"];
    SFAFileInfo *fileInfo = [[SFAFileInfo alloc] initWithFilePath:path];
    SFAUploadSpecificationRequest *req = [SFAUploadSpecificationRequest new];
    req.title = @"A Title";
    req.details = @"A Detail";
    SFAAsyncThreadedFileUploader *uploader = [[SFAAsyncThreadedFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:path];
    SFAFilePart *part = [SFAFilePart new];
    part.length = uploader.config.partSize;
    part.offset = 10;
    part.index = 2;
    part.uploadUrl = @"http://sub.domain.com?q=1";
    NSMutableDictionary *contextObject = [NSMutableDictionary new];
    contextObject[SFAFilePartString] = part;
    NSURLRequest *request = [uploader task:nil needsRequestForQuery:nil usingContextObject:&contextObject];
    NSString *url = [NSString stringWithFormat:@"%@&index=2&byteOffset=10&hash=fd934581ae048724c4cab39b142ce18c", part.uploadUrl];
    XCTAssertTrue([request.URL.absoluteString isEqualToString:url], @"*1 Unexpected request url");
    XCTAssertTrue([request.HTTPMethod isEqualToString:SFAPost], @"*1 Expected method to be post");
    XCTAssertTrue(request.HTTPBody.length == (fileInfo.fileSize.unsignedIntegerValue - 10), @"*1 Unexpected body length.");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAccept] isEqualToString:SFAApplicationJson], @"*1 Unexpected header value for accept.");
    NSString *len = [NSString stringWithFormat:@"%lu", request.HTTPBody.length];
    XCTAssertTrue([request.allHTTPHeaderFields[SFAContentLength] isEqualToString:len], @"*1 Unexpected header value for content-length.");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAContentType] isEqualToString:@"application/octet-stream"], @"*1 Unexpected header value for content-type.");
    XCTAssertTrue([request.allHTTPHeaderFields[@"Expect"] isEqualToString:@"100-continue"], @"*1 Unexpected header value for Expect.");
    XCTAssertTrue([part.filePartHash isEqualToString:@"fd934581ae048724c4cab39b142ce18c"], @"*1 Unexpected value for file hash.");
    XCTAssertTrue([[SFACryptoUtils md5StringWithData:request.HTTPBody] isEqualToString:@"fd934581ae048724c4cab39b142ce18c"], @"*1 Unexpected data hash.");
    // Test Again
    part.offset = 0;
    part.length = 10;
    part.index = 0;
    request = [uploader task:nil needsRequestForQuery:nil usingContextObject:&contextObject];
    url = [NSString stringWithFormat:@"%@&index=0&byteOffset=0&hash=b9618d25d35b99e270b860f2c1bf10aa", part.uploadUrl];
    XCTAssertTrue([request.URL.absoluteString isEqualToString:url], @"*2 Unexpected request url");
    XCTAssertTrue([request.HTTPMethod isEqualToString:SFAPost], @"*2 Expected method to be post");
    XCTAssertTrue(request.HTTPBody.length == 10, @"*2 Unexpected body length.");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAccept] isEqualToString:SFAApplicationJson], @"*2 Unexpected header value for accept.");
    len = [NSString stringWithFormat:@"%lu", request.HTTPBody.length];
    XCTAssertTrue([request.allHTTPHeaderFields[SFAContentLength] isEqualToString:len], @"*2 Unexpected header value for content-length.");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAContentType] isEqualToString:@"application/octet-stream"], @"*2 Unexpected header value for content-type.");
    XCTAssertTrue([request.allHTTPHeaderFields[@"Expect"] isEqualToString:@"100-continue"], @"*2 Unexpected header value for Expect.");
    XCTAssertTrue([part.filePartHash isEqualToString:@"b9618d25d35b99e270b860f2c1bf10aa"], @"*2 Unexpected value for file hash.");
    XCTAssertTrue([[SFACryptoUtils md5StringWithData:request.HTTPBody] isEqualToString:@"b9618d25d35b99e270b860f2c1bf10aa"], @"*2 Unexpected data hash.");
    
    // Test Finish Call
    uploader.uploadSpecification = [SFIUploadSpecification new];
    uploader.uploadSpecification.FinishUri = [NSURL URLWithString:@"http://www.xyz.abc?k=1"];
    [contextObject removeAllObjects];
    request = [uploader task:nil needsRequestForQuery:nil usingContextObject:&contextObject];
    url = [NSString stringWithFormat:@"%@&respformat=json&filehash=7490f606e5bc65995e248d5d058a49e9&details=A%%20Detail&title=A%%20Title&fileSize=56", uploader.uploadSpecification.FinishUri.absoluteString];
    XCTAssertTrue([request.URL.absoluteString isEqualToString:url], @"*3 Unexpected request url");
    XCTAssertTrue([request.HTTPMethod isEqualToString:SFAGet], @"*3 Expected method to be get");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAccept] isEqualToString:SFAApplicationJson], @"*3 Unexpected header value for accept.");
}

- (void)testALAssetRequestBuilding {
#if TARGET_OS_IPHONE
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"TestFile" ofType:@"txt"];
    NSData *fileData = [NSData dataWithContentsOfFile:path];
    SFAFileInfo *fileInfo = [[SFAFileInfo alloc] initWithFilePath:path];
    SFAUploadSpecificationRequest *req = [SFAUploadSpecificationRequest new];
    req.title = @"A Title";
    req.details = @"A Detail";
    id mockAsset = OCMClassMock([ALAsset class]);
    
    SFAAsyncThreadedFileUploader *uploader = [[SFAAsyncThreadedFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req asset:mockAsset];
    
    SFAFilePart *part = [SFAFilePart new];
    part.length = uploader.config.partSize;
    part.offset = 10;
    part.index = 2;
    part.uploadUrl = @"http://sub.domain.com?q=1";
    
    id mockRep = OCMClassMock([ALAssetRepresentation class]);
    OCMStub([mockAsset defaultRepresentation]).andReturn(mockRep);
    OCMStub([(ALAssetRepresentation *) mockRep size]).andReturn((long long)45);
    OCMStub([mockRep filename]).andReturn(@"TestFile.txt");
    void (^blockCB)(NSInvocation *invocation);
    blockCB = ^(NSInvocation *invocation) {
        char *buffer;
        [invocation getArgument:&buffer atIndex:2];
        NSRange range = (NSRange) {.location = part.offset, .length = MIN((unsigned long)fileInfo.fileSize.unsignedIntegerValue - part.offset, part.length) };
        [fileData getBytes:buffer range:range];
        NSUInteger retVal = range.length;
        [invocation setReturnValue:&retVal];
    };
    
    [OCMStub([mockRep getBytes:[OCMArg anyPointer] fromOffset:part.offset length:part.length error:NULL]) andDo:blockCB];
    NSMutableDictionary *contextObject = [NSMutableDictionary new];
    contextObject[SFAFilePartString] = part;
    NSURLRequest *request = [uploader task:nil needsRequestForQuery:nil usingContextObject:&contextObject];
    NSString *url = [NSString stringWithFormat:@"%@&index=2&byteOffset=10&hash=fd934581ae048724c4cab39b142ce18c", part.uploadUrl];
    XCTAssertTrue([request.URL.absoluteString isEqualToString:url], @"*1 Unexpected request url");
    XCTAssertTrue([request.HTTPMethod isEqualToString:SFAPost], @"*1 Expected method to be post");
    XCTAssertTrue(request.HTTPBody.length == (fileInfo.fileSize.unsignedIntegerValue - 10), @"*1 Unexpected body length.");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAccept] isEqualToString:SFAApplicationJson], @"*1 Unexpected header value for accept.");
    NSString *len = [NSString stringWithFormat:@"%lu", request.HTTPBody.length];
    XCTAssertTrue([request.allHTTPHeaderFields[SFAContentLength] isEqualToString:len], @"*1 Unexpected header value for content-length.");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAContentType] isEqualToString:@"application/octet-stream"], @"*1 Unexpected header value for content-type.");
    XCTAssertTrue([request.allHTTPHeaderFields[@"Expect"] isEqualToString:@"100-continue"], @"*1 Unexpected header value for Expect.");
    XCTAssertTrue([part.filePartHash isEqualToString:@"fd934581ae048724c4cab39b142ce18c"], @"*1 Unexpected value for file hash.");
    XCTAssertTrue([[SFACryptoUtils md5StringWithData:request.HTTPBody] isEqualToString:@"fd934581ae048724c4cab39b142ce18c"], @"*1 Unexpected data hash.");
    // Test Again
    part.offset = 0;
    part.length = 10;
    part.index = 0;
    [OCMStub([mockRep getBytes:[OCMArg anyPointer] fromOffset:part.offset length:part.length error:NULL]) andDo:blockCB];
    request = [uploader task:nil needsRequestForQuery:nil usingContextObject:&contextObject];
    url = [NSString stringWithFormat:@"%@&index=0&byteOffset=0&hash=b9618d25d35b99e270b860f2c1bf10aa", part.uploadUrl];
    XCTAssertTrue([request.URL.absoluteString isEqualToString:url], @"*2 Unexpected request url");
    XCTAssertTrue([request.HTTPMethod isEqualToString:SFAPost], @"*2 Expected method to be post");
    XCTAssertTrue(request.HTTPBody.length == 10, @"*2 Unexpected body length.");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAccept] isEqualToString:SFAApplicationJson], @"*2 Unexpected header value for accept.");
    len = [NSString stringWithFormat:@"%lu", request.HTTPBody.length];
    XCTAssertTrue([request.allHTTPHeaderFields[SFAContentLength] isEqualToString:len], @"*2 Unexpected header value for content-length.");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAContentType] isEqualToString:@"application/octet-stream"], @"*2 Unexpected header value for content-type.");
    XCTAssertTrue([request.allHTTPHeaderFields[@"Expect"] isEqualToString:@"100-continue"], @"*2 Unexpected header value for Expect.");
    XCTAssertTrue([part.filePartHash isEqualToString:@"b9618d25d35b99e270b860f2c1bf10aa"], @"*2 Unexpected value for file hash.");
    XCTAssertTrue([[SFACryptoUtils md5StringWithData:request.HTTPBody] isEqualToString:@"b9618d25d35b99e270b860f2c1bf10aa"], @"*2 Unexpected data hash.");
    // Test Finish Call
    part.offset = 0;
    part.length = fileInfo.fileSize.unsignedIntegerValue;
    [OCMStub([mockRep getBytes:[OCMArg anyPointer] fromOffset:0 length:SFAMaxBufferLength error:[OCMArg anyObjectRef]]) andDo:blockCB];
    uploader.uploadSpecification = [SFIUploadSpecification new];
    uploader.uploadSpecification.FinishUri = [NSURL URLWithString:@"http://www.xyz.abc?k=1"];
    [contextObject removeAllObjects];
    request = [uploader task:nil needsRequestForQuery:nil usingContextObject:&contextObject];
    url = [NSString stringWithFormat:@"%@&forceunique=1&respformat=json&filehash=7490f606e5bc65995e248d5d058a49e9&details=A%%20Detail&title=A%%20Title&fileSize=45", uploader.uploadSpecification.FinishUri.absoluteString];
    XCTAssertTrue([request.URL.absoluteString isEqualToString:url], @"*3 Unexpected request url");
    XCTAssertTrue([request.HTTPMethod isEqualToString:SFAGet], @"*3 Expected method to be get");
    XCTAssertTrue([request.allHTTPHeaderFields[SFAccept] isEqualToString:SFAApplicationJson], @"*3 Unexpected header value for accept.");
    
#endif
}

- (void)testResponseHandling {
    self.client.authHandler = nil; // We are not teting auth handler
    SFAUploadSpecificationRequest *req = [SFAUploadSpecificationRequest new];
    SFAAsyncThreadedFileUploader *uploader = [[SFAAsyncThreadedFileUploader alloc] initWithSFAClient:self.client uploadSpecificationRequest:req filePath:@""];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    // JSON error
    SFAHttpHandleResponseReturnData *data = [uploader task:nil needsResponseHandlingForQuery:nil httpRequestResponseDataContainer:[self jsonErrorContainer] usingContextObject:&dict];
    XCTAssertTrue(data.responseAction == SFAHttpHandleResponseActionComplete, @"*1 Expected action to be complete");
    XCTAssertTrue([data.returnValue isKindOfClass:[SFAError class]], @"*1 Expected return value to be SFAError");
    XCTAssertTrue(((SFAError *)data.returnValue).errorType == SFAErrorTypeInvalidResponseError, @"*1 Unexpected error type");
    
    // Error Response
    data = [uploader task:nil needsResponseHandlingForQuery:nil httpRequestResponseDataContainer:[self errorContainer] usingContextObject:&dict];
    XCTAssertTrue(data.responseAction == SFAHttpHandleResponseActionComplete, @"*2 Expected action to be complete");
    XCTAssertTrue([data.returnValue isKindOfClass:[SFAApiResponse class]], @"Expected return value to be SFAApiResponse");
    XCTAssertTrue([((SFAApiResponse *)data.returnValue).errorMessage isEqualToString:@"Error Message"], @"*2 Unexpected message value");
    XCTAssertTrue(((SFAApiResponse *)data.returnValue).errorCode == 10, @"ErrorCode should be = 10");
    XCTAssertTrue(((SFAApiResponse *)data.returnValue).error, @"Error should be YES");
    
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
