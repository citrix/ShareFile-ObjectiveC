#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
#import <OCMock/OCMock.h>
// Hidden APIs
#import "SFAHttpTask.h"
#import "SFAHttpTaskProtected.h"
#import "SFABaseTask.h"
#import "SFABaseTaskProtected.h"
//

@interface ShareFileSDKHttpTaskTests : ShareFileSDKTests

@property (nonatomic) BOOL notificationPosted;
@property (nonatomic) BOOL callbackCalled;
@property (nonatomic) BOOL properNotificationPost;
@property (strong, nonatomic) SFAHttpTask *task;
@property (strong, nonatomic) XCTestExpectation *expectation;
@property (strong, nonatomic) NSObject *retVal;
@property (strong, nonatomic) NSDictionary *dict;

@end

@implementation ShareFileSDKHttpTaskTests

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
    id mockQuery = OCMClassMock([SFApiQuery class]);
    id mockDelegate = OCMProtocolMock(@protocol(SFAHttpTaskDelegate));
    XCTAssertThrows([[SFAHttpTask alloc] initWithQuery:mockQuery delegate:mockDelegate contextObject:nil callbackQueue:nil client:nil], @"Should throw as client is nil.");
    XCTAssertThrows([[SFAHttpTask alloc] initWithQuery:nil delegate:mockDelegate contextObject:nil callbackQueue:nil client:self.client], @"Should throw as query is nil.");
    XCTAssertThrows([[SFAHttpTask alloc] initWithQuery:mockQuery delegate:nil contextObject:nil callbackQueue:nil client:self.client], @"Should throw as delegate is nil.");
    NSDictionary *mockObject = @{};
    SFAHttpTask *task = [[SFAHttpTask alloc] initWithQuery:mockQuery delegate:mockDelegate contextObject:mockObject callbackQueue:nil client:self.client];
    XCTAssertEqual(task.query, mockQuery, @"query should be same as passed to init.");
    XCTAssertEqual(task.delegate, mockDelegate, @"delegate should be same as passed to init.");
    XCTAssertEqual(task.contextObject, mockObject, @"contextObject should be same as passed to init.");
    XCTAssertEqual(task.queue, [NSOperationQueue mainQueue], @"queue should be main as it is default.");
    XCTAssertEqual(task.client, self.client, @"client should be same as passed to init.");
    NSOperationQueue *queue = [NSOperationQueue new];
    task = [[SFAHttpTask alloc] initWithQuery:mockQuery delegate:mockDelegate contextObject:nil callbackQueue:queue client:self.client];
    XCTAssertEqual(task.query, mockQuery, @"*1 query should be same as passed to init.");
    XCTAssertEqual(task.queue, queue, @"queue should be same as passed to init.");
}

- (void)testCancelCallbackAndNotification {
    id mockQuery = OCMClassMock([SFApiQuery class]);
    id mockDelegate = OCMProtocolMock(@protocol(SFAHttpTaskDelegate));
    NSOperationQueue *queue = [NSOperationQueue new];
    __block BOOL calledOnQueue = NO;
    self.task = [[SFAHttpTask alloc] initWithQuery:mockQuery delegate:mockDelegate contextObject:nil callbackQueue:queue client:self.client];
    __weak ShareFileSDKHttpTaskTests *weakSelf = self;
    self.task.cancelCallback = ^() {
        weakSelf.callbackCalled = YES;
        calledOnQueue = [[NSOperationQueue currentQueue] isEqual:queue];
        if (weakSelf.notificationPosted) {
            [weakSelf.expectation fulfill];
        }
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelNotification:) name:kSFATaskCancelNotification object:self.task];
    SFAHttpTask *mockTask = OCMPartialMock(self.task);
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
    id mockQuery = OCMClassMock([SFApiQuery class]);
    id mockDelegate = OCMProtocolMock(@protocol(SFAHttpTaskDelegate));
    NSOperationQueue *queue = [NSOperationQueue new];
    __block BOOL calledOnQueue = NO;
    __block BOOL properCallbackCall = NO;
    self.task = [[SFAHttpTask alloc] initWithQuery:mockQuery delegate:mockDelegate contextObject:nil callbackQueue:queue client:self.client];
    self.retVal = [NSObject new];
    __weak ShareFileSDKHttpTaskTests *weakSelf = self;
    self.task.completionCallback = ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
        weakSelf.callbackCalled = YES;
        calledOnQueue = [[NSOperationQueue currentQueue] isEqual:queue];
        if ([returnValue isEqual:weakSelf.retVal] && !error && [additionalInfo[kSFAHttpRequestResponseDataContainer] isKindOfClass:[SFAHttpRequestResponseDataContainer class]]) {
            properCallbackCall = YES;
        }
        if (weakSelf.notificationPosted) {
            [weakSelf.expectation fulfill];
        }
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeNotificationForSuccess:) name:kSFATaskCompleteNotification object:self.task];
    SFAHttpTask *mockTask = OCMPartialMock(self.task);
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
    id mockQuery = OCMClassMock([SFApiQuery class]);
    id mockDelegate = OCMProtocolMock(@protocol(SFAHttpTaskDelegate));
    NSOperationQueue *queue = [NSOperationQueue new];
    __block BOOL calledOnQueue = NO;
    __block BOOL properCallbackCall = NO;
    self.task = [[SFAHttpTask alloc] initWithQuery:mockQuery delegate:mockDelegate contextObject:nil callbackQueue:queue client:self.client];
    self.retVal = [SFAError new];
    __weak ShareFileSDKHttpTaskTests *weakSelf = self;
    self.task.completionCallback = ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
        weakSelf.callbackCalled = YES;
        calledOnQueue = [[NSOperationQueue currentQueue] isEqual:queue];
        if ([error isEqual:weakSelf.retVal] && !returnValue && [additionalInfo[kSFAHttpRequestResponseDataContainer] isKindOfClass:[SFAHttpRequestResponseDataContainer class]]) {
            properCallbackCall = YES;
        }
        if (weakSelf.notificationPosted) {
            [weakSelf.expectation fulfill];
        }
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completeNotificationForFailure:) name:kSFATaskCompleteNotification object:self.task];
    SFAHttpTask *mockTask = OCMPartialMock(self.task);
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
    id mockQuery = OCMClassMock([SFApiQuery class]);
    id mockDelegate = OCMProtocolMock(@protocol(SFAHttpTaskDelegate));
    NSOperationQueue *queue = [NSOperationQueue new];
    __block BOOL calledOnQueue = NO;
    __block BOOL properCallbackCall = NO;
    self.task = [[SFAHttpTask alloc] initWithQuery:mockQuery delegate:mockDelegate contextObject:nil callbackQueue:queue client:self.client];
    self.task.byteTransfered = 10;
    self.task.transferSize = 100;
    self.dict = @{};
    self.task.transferMetaData = self.dict;
    __weak ShareFileSDKHttpTaskTests *weakSelf = self;
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
    SFAHttpTask *mockTask = OCMPartialMock(self.task);
    OCMStub([mockTask startForcefully]);
    // Expectation
    self.expectation = [self expectationWithDescription:@"Testing Async call of Progress Callback!"];
    [mockTask start];
    [mockTask notifyProgress];
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
            if ([notification.userInfo[kSFATaskNotificationUserInfoReturnValue] isEqual:self.retVal] && !notification.userInfo[kSFATaskNotificationUserInfoError] && [(notification.userInfo[kSFATaskNotificationUserInfoAdditionalInfo])[kSFAHttpRequestResponseDataContainer] isKindOfClass:[SFAHttpRequestResponseDataContainer class]]) {
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
            if ([notification.userInfo[kSFATaskNotificationUserInfoError] isEqual:self.retVal] && !notification.userInfo[kSFATaskNotificationUserInfoReturnValue] && [(notification.userInfo[kSFATaskNotificationUserInfoAdditionalInfo])[kSFAHttpRequestResponseDataContainer] isKindOfClass:[SFAHttpRequestResponseDataContainer class]]) {
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
