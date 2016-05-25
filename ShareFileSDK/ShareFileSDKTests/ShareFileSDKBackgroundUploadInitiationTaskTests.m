#import <Foundation/Foundation.h>
#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
#import <OCMock/OCMock.h>

//Hidden Api
#import "ShareFileSDKTestsProtected.h"
#import "SFAHttpTaskProtected.h"
#import "SFABaseTaskProtected.h"
#import "SFUploadSpecification.h"
#import "SFAAsyncStandardFileUploader.h"
#import "SFABackgroundUploadInitiationTaskInternal.h"

@interface ShareFileSDKBackgroundUploadInitiationTaskTests : XCTestCase

@property (strong, nonatomic) XCTestExpectation *expectation;

@end

@implementation ShareFileSDKBackgroundUploadInitiationTaskTests


- (void)tearDown {
    [super tearDown];
    self.expectation = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)testTaskResponseHandling {
    id mockDelegate = OCMProtocolMock(@protocol(SFAHttpTaskDelegate));
    id mockClient = OCMClassMock([SFAClient class]);
    id mockBackgroundTaskDelegate = OCMClassMock([SFAAsyncStandardFileUploader class]);
    
    SFUploadSpecification *uploadSpecification = [[SFUploadSpecification alloc] init];
    uploadSpecification.IsResume = [NSNumber numberWithBool:YES];
    uploadSpecification.ResumeOffset = [NSNumber numberWithUnsignedLongLong:10];
    uploadSpecification.ResumeIndex = [NSNumber numberWithUnsignedLongLong:1];
    uploadSpecification.ResumeFileHash = @"13ad68f3850bc971d64c9e85581b9b5d"; // Hash of first 10 bytes calculated offline.
    
    __block BOOL completionCallbackCalled = NO;
    __block SFABackgroundUploadInitiationResponse *response = nil;
    __weak ShareFileSDKBackgroundUploadInitiationTaskTests *weakSelf = self;
    SFATaskCompletionCallback compCB = ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
        completionCallbackCalled = YES;
        if ([returnValue isKindOfClass:[SFABackgroundUploadInitiationResponse class]] && !error) {
            response = (SFABackgroundUploadInitiationResponse *)returnValue;
        }
        [weakSelf.expectation fulfill];
    };
    SFATaskCancelCallback cancelCB = ^{};
    SFABackgroundUploadInitiationTask *uploadTask = [[SFABackgroundUploadInitiationTask alloc] initWithDelegate:mockDelegate contextObject:nil callbackQueue:nil client:mockClient];
    uploadTask.backgroundUploadInitiationTaskDelegate = mockBackgroundTaskDelegate;
    uploadTask.completionCallback = compCB;
    uploadTask.cancelCallback = cancelCB;
    
    SFABackgroundUploadInitiationTask *mockTask = OCMPartialMock(uploadTask);
    OCMStub([mockTask startForcefully]);
    // Expectation
    self.expectation = [self expectationWithDescription:@"Testing Async call of Completion Callback!"];
    [mockTask start];
    [mockTask taskCompleted:uploadSpecification];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    //Test
    XCTAssertNotNil(uploadTask, @"Background Uploader task not created properly.");
    XCTAssertTrue(completionCallbackCalled, @"Completion callback not called");
    XCTAssertTrue([response.uploadSpecification isEqual:uploadSpecification], @"Completion callback not called with desired upload specification value");
}

@end
