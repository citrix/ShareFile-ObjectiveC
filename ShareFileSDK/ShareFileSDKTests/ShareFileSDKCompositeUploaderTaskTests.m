#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
#import <OCMock/OCMock.h>
// Hidden APIs
#import "SFACompositeUploaderTask.h"
#import "SFACompositeUploaderTaskInternal.h"
#import "SFACompositeUploaderTaskPrivate.h"
#import "SFABaseTaskProtected.h"
//

@interface ShareFileSDKCompositeUploaderTaskTests : ShareFileSDKTests

@property (nonatomic) BOOL notificationPosted;
@property (nonatomic) BOOL callbackCalled;
@property (nonatomic) BOOL properNotificationPost;
@property (strong, nonatomic) SFACompositeUploaderTask *task;
@property (strong, nonatomic) XCTestExpectation *expectation;
@property (strong, nonatomic) NSObject *retVal;
@property (strong, nonatomic) NSDictionary *dict;

@end

@implementation ShareFileSDKCompositeUploaderTaskTests

- (void)tearDown {
    [super tearDown];
    self.notificationPosted = NO;
    self.callbackCalled = NO;
    self.properNotificationPost = NO;
    self.task = nil;
    self.expectation = nil;
    self.retVal = nil;
    self.dict = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)testTaskInit {
    id mockSpecificationTask = OCMClassMock([SFAHttpTask class]);
    id mockFinishTask = OCMClassMock([SFAHttpTask class]);
    id mockDelegate = OCMProtocolMock(@protocol(SFACompositeTaskDelegate));
    NSDictionary *mockDict = @{};
    SFACompositeUploaderTask *task = [[SFACompositeUploaderTask alloc] initWithUploadSpecificationTask:mockSpecificationTask concurrentExecution:11 uploaderTasks:@[mockSpecificationTask, mockSpecificationTask] finishTask:mockFinishTask delegate:mockDelegate transferMetadata:mockDict callbackQueue:nil client:self.client uploadMethod:SFAUploadMethodStandard];
    XCTAssertEqual(task.uploadspecificationTask, mockSpecificationTask, @"spec task should be same as passed to init.");
    XCTAssertTrue(task.concurrentExecutionCount == 11, @"max concurrent count should be same as passed to init.");
    XCTAssertTrue(task.uploaderTasks.count == 2 && [task.uploaderTasks[0] isEqual:mockSpecificationTask] && [task.uploaderTasks[1] isEqual:mockSpecificationTask], @"uploader tasks should be same as passed to init.");
    XCTAssertEqual(task.finishUploadTask, mockFinishTask, @"finish task should be same as passed to init.");
    XCTAssertEqual(task.delegate, mockDelegate, @"delegate should be same as passed to init.");
    XCTAssertEqual(task.transferMetaData, mockDict, @"meta data should be same as passed to init.");
    XCTAssertEqual(task.queue, [NSOperationQueue mainQueue], @"queue should be main as it is default.");
    XCTAssertTrue(task.uploadMethod == SFAUploadMethodStandard, @"*1 upload method should be same as passed to init.");
    NSOperationQueue *queue = [NSOperationQueue new];
    task = [[SFACompositeUploaderTask alloc] initWithUploadSpecificationTask:mockSpecificationTask concurrentExecution:11 uploaderTasks:@[mockSpecificationTask, mockSpecificationTask] finishTask:mockSpecificationTask delegate:mockDelegate transferMetadata:mockDict callbackQueue:queue client:self.client uploadMethod:SFAUploadMethodThreaded];
    XCTAssertEqual(task.queue, queue, @"queue should be same as passed to init.");
    XCTAssertTrue(task.uploadMethod == SFAUploadMethodThreaded, @"*1 upload method should be same as passed to init.");
}

- (void)testCancelCallbackAndNotification {
    id mockSpecificationTask = OCMClassMock([SFAHttpTask class]);
    id mockDelegate = OCMProtocolMock(@protocol(SFACompositeTaskDelegate));
    NSOperationQueue *queue = [NSOperationQueue new];
    __block BOOL calledOnQueue = NO;
    self.task = [[SFACompositeUploaderTask alloc] initWithUploadSpecificationTask:mockSpecificationTask concurrentExecution:4 uploaderTasks:@[] finishTask:nil delegate:mockDelegate transferMetadata:nil callbackQueue:queue client:self.client uploadMethod:SFAUploadMethodThreaded];
    __weak ShareFileSDKCompositeUploaderTaskTests *weakSelf = self;
    self.task.cancelCallback = ^() {
        weakSelf.callbackCalled = YES;
        calledOnQueue = [[NSOperationQueue currentQueue] isEqual:queue];
        if (weakSelf.notificationPosted) {
            [weakSelf.expectation fulfill];
        }
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelNotification:) name:kSFATaskCancelNotification object:self.task];
    SFACompositeUploaderTask *mockTask = OCMPartialMock(self.task);
    OCMStub([mockTask startForcefully]);
    // Expectation
    self.expectation = [self expectationWithDescription:@"Testing Async call of Cancel Callback!"];
    [mockTask start];
    [mockTask cancel];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertTrue(self.callbackCalled, @"Cancel Callback not called");
    XCTAssertTrue(calledOnQueue, @"Cancel Callback not called on provided queue.");
    XCTAssertTrue(self.notificationPosted, @"Cancel Notification not posted.");
    XCTAssertTrue(self.properNotificationPost, @"Cancel Notification not posted with proper data.");
}

- (void)testCompletionCallbackAndNotificationForSuccess {
    id mockSpecificationTask = OCMClassMock([SFAHttpTask class]);
    id mockDelegate = OCMProtocolMock(@protocol(SFACompositeTaskDelegate));
    NSOperationQueue *queue = [NSOperationQueue new];
    __block BOOL calledOnQueue = NO;
    __block BOOL properCallbackCall = NO;
    self.task = [[SFACompositeUploaderTask alloc] initWithUploadSpecificationTask:mockSpecificationTask concurrentExecution:4 uploaderTasks:@[] finishTask:nil delegate:mockDelegate transferMetadata:nil callbackQueue:queue client:self.client uploadMethod:SFAUploadMethodThreaded];
    self.retVal = [NSObject new];
    __weak ShareFileSDKCompositeUploaderTaskTests *weakSelf = self;
    self.task.completionCallback = ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
        weakSelf.callbackCalled = YES;
        calledOnQueue = [[NSOperationQueue currentQueue] isEqual:queue];
        if ([returnValue isEqual:weakSelf.retVal] && !error && !additionalInfo[kSFAHttpRequestResponseDataContainer]) {
            properCallbackCall = YES;
        }
        if (weakSelf.notificationPosted) {
            [weakSelf.expectation fulfill];
        }
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeNotificationForSuccess:) name:kSFATaskCompleteNotification object:self.task];
    SFACompositeUploaderTask *mockTask = OCMPartialMock(self.task);
    OCMStub([mockTask startForcefully]);
    // Expectation
    self.expectation = [self expectationWithDescription:@"Testing Async call of Completion Callback!"];
    [mockTask start];
    [mockTask taskCompleted:self.retVal];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertTrue(self.callbackCalled, @"Completion Callback not called");
    XCTAssertTrue(calledOnQueue, @"Completion Callback not called on provided queue.");
    XCTAssertTrue(properCallbackCall, @"Completion Callback not called with proper parameters.");
    XCTAssertTrue(self.notificationPosted, @"Completion Notification not posted.");
    XCTAssertTrue(self.properNotificationPost, @"Completion Notification not posted with proper data.");
}

- (void)testCompletionCallbackAndNotificationForFailure {
    id mockSpecificationTask = OCMClassMock([SFAHttpTask class]);
    id mockDelegate = OCMProtocolMock(@protocol(SFACompositeTaskDelegate));
    NSOperationQueue *queue = [NSOperationQueue new];
    __block BOOL calledOnQueue = NO;
    __block BOOL properCallbackCall = NO;
    self.task = [[SFACompositeUploaderTask alloc] initWithUploadSpecificationTask:mockSpecificationTask concurrentExecution:4 uploaderTasks:@[] finishTask:nil delegate:mockDelegate transferMetadata:nil callbackQueue:queue client:self.client uploadMethod:SFAUploadMethodThreaded];
    self.retVal = [SFAError new];
    __weak ShareFileSDKCompositeUploaderTaskTests *weakSelf = self;
    self.task.completionCallback = ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
        weakSelf.callbackCalled = YES;
        calledOnQueue = [[NSOperationQueue currentQueue] isEqual:queue];
        if ([error isEqual:weakSelf.retVal] && !returnValue && !additionalInfo[kSFAHttpRequestResponseDataContainer]) {
            properCallbackCall = YES;
        }
        if (weakSelf.notificationPosted) {
            [weakSelf.expectation fulfill];
        }
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeNotificationForFailure:) name:kSFATaskCompleteNotification object:self.task];
    SFACompositeUploaderTask *mockTask = OCMPartialMock(self.task);
    OCMStub([mockTask startForcefully]);
    // Expectation
    self.expectation = [self expectationWithDescription:@"Testing Async call of Completion Callback!"];
    [mockTask start];
    [mockTask taskCompleted:self.retVal];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertTrue(self.callbackCalled, @"Completion Callback not called");
    XCTAssertTrue(calledOnQueue, @"Completion Callback not called on provided queue.");
    XCTAssertTrue(properCallbackCall, @"Completion Callback not called with proper parameters.");
    XCTAssertTrue(self.notificationPosted, @"Completion Notification not posted.");
    XCTAssertTrue(self.properNotificationPost, @"Completion Notification not posted with proper data.");
}

- (void)testProgressCallbackAndNotification {
    id mockSpecificationTask = OCMClassMock([SFAHttpTask class]);
    id mockDelegate = OCMProtocolMock(@protocol(SFACompositeTaskDelegate));
    NSOperationQueue *queue = [NSOperationQueue new];
    __block BOOL calledOnQueue = NO;
    __block BOOL properCallbackCall = NO;
    self.dict = @{};
    self.task = [[SFACompositeUploaderTask alloc] initWithUploadSpecificationTask:mockSpecificationTask concurrentExecution:4 uploaderTasks:@[] finishTask:nil delegate:mockDelegate transferMetadata:self.dict callbackQueue:queue client:self.client uploadMethod:SFAUploadMethodThreaded];
    [self.task initializeProgressWithTotalBytes:100];
    __weak ShareFileSDKCompositeUploaderTaskTests *weakSelf = self;
    self.task.progressCallback = ^(SFATransferProgress *transferProgress) {
        weakSelf.callbackCalled = YES;
        calledOnQueue = [[NSOperationQueue currentQueue] isEqual:queue];
        if (transferProgress.bytesTransferred == 10 && transferProgress.bytesRemaining == 90 && transferProgress.totalBytes == 100 && [transferProgress.transferMetadata isEqual:weakSelf.dict]) {
            properCallbackCall = YES;
        }
        if (weakSelf.notificationPosted) {
            [weakSelf.expectation fulfill];
        }
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressNotification:) name:kSFATransferTaskProgressNotification object:self.task];
    SFACompositeUploaderTask *mockTask = OCMPartialMock(self.task);
    OCMStub([mockTask startForcefully]);
    // Expectation
    self.expectation = [self expectationWithDescription:@"Testing Async call of Progress Callback!"];
    [mockTask start];
    [mockTask internalProgress:10];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    XCTAssertTrue(self.callbackCalled, @"Progress Callback not called");
    XCTAssertTrue(calledOnQueue, @"Progress Callback not called on provided queue.");
    XCTAssertTrue(properCallbackCall, @"Progress Callback not called with proper parameters.");
    XCTAssertTrue(self.notificationPosted, @"Progress Notification not posted.");
    XCTAssertTrue(self.properNotificationPost, @"Progress Notification not posted with proper data.");
}

#pragma mark - Helper Method(s)

- (void)cancelNotification:(NSNotification *)notification {
    self.notificationPosted = YES;
    if ([notification.name isEqualToString:kSFATaskCancelNotification]) {
        if ([notification.object isEqual:self.task]) {
            self.properNotificationPost = YES;
        }
    }
    if (self.callbackCalled) {
        [self.expectation fulfill];
    }
}

- (void)completeNotificationForSuccess:(NSNotification *)notification {
    self.notificationPosted = YES;
    if ([notification.name isEqualToString:kSFATaskCompleteNotification]) {
        if ([notification.object isEqual:self.task]) {
            if ([notification.userInfo[kSFATaskNotificationUserInfoReturnValue] isEqual:self.retVal] && !notification.userInfo[kSFATaskNotificationUserInfoError] && !notification.userInfo[kSFATaskNotificationUserInfoAdditionalInfo]) {
                self.properNotificationPost = YES;
            }
        }
    }
    if (self.callbackCalled) {
        [self.expectation fulfill];
    }
}

- (void)completeNotificationForFailure:(NSNotification *)notification {
    self.notificationPosted = YES;
    if ([notification.name isEqualToString:kSFATaskCompleteNotification]) {
        if ([notification.object isEqual:self.task]) {
            if ([notification.userInfo[kSFATaskNotificationUserInfoError] isEqual:self.retVal] && !notification.userInfo[kSFATaskNotificationUserInfoReturnValue] && !notification.userInfo[kSFATaskNotificationUserInfoAdditionalInfo]) {
                self.properNotificationPost = YES;
            }
        }
    }
    if (self.callbackCalled) {
        [self.expectation fulfill];
    }
}

- (void)progressNotification:(NSNotification *)notification {
    self.notificationPosted = YES;
    if ([notification.name isEqualToString:kSFATransferTaskProgressNotification]) {
        if ([notification.object isEqual:self.task]) {
            if ([notification.userInfo[kSFATransferTaskNotificationUserInfoProgress] isKindOfClass:[SFATransferProgress class]]) {
                SFATransferProgress *transferProgress = notification.userInfo[kSFATransferTaskNotificationUserInfoProgress];
                if (transferProgress.bytesTransferred == 10 && transferProgress.bytesRemaining == 90 && transferProgress.totalBytes == 100 && [transferProgress.transferMetadata isEqual:self.dict]) {
                    self.properNotificationPost = YES;
                }
            }
        }
    }
    if (self.callbackCalled) {
        [self.expectation fulfill];
    }
}

@end
