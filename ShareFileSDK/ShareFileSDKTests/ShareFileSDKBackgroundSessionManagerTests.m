#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
#import <OCMock/OCMock.h>

//
#import "SFABackgroundSessionManager.h"
#import "SFABackgroundSessionManagerInternal.h"
//

@interface ShareFileSDKBackgroundSessionManagerTests : ShareFileSDKTests

@end

@implementation ShareFileSDKBackgroundSessionManagerTests


- (void)testBackgroundSessionManagerInit {
    id mockClient = OCMClassMock([SFAClient class]);
    SFABackgroundSessionManager *session = [[SFABackgroundSessionManager alloc] initWithClient:mockClient];
    XCTAssertNotNil(session, @"Session manager not created properly");
    XCTAssertFalse([session hasBackgroundSession], @"Background session not created at this point");
    [session setupBackgroundSession];
    XCTAssertNotNil([session backgroundSession], @"Background session should not be nil");
    XCTAssertNotNil([session completionHandlers], @"Completion handlers container should not be nil");
    XCTAssertNotNil([session allTaskSpecificDelegates], @"Task specific delegate container should not be nil");
    
    id completionHandler = (void (^)())completionHandler;
    [session setupBackgroundSessionWithCompletionHandler:completionHandler];
    XCTAssertTrue([session hasBackgroundSession], @"Background session should be created at this point");
    
    NSDictionary *handlers = [session completionHandlers];
    NSURLSession *bgSession = [session backgroundSession];
    XCTAssertEqual(completionHandler, [handlers objectForKey:bgSession.configuration.identifier], @"Completion handler not set properly");
}

- (void)testAddingRemovingSessionTaskDeleagtes {
    id mockClient = OCMClassMock([SFAClient class]);
    SFABackgroundSessionManager *session = [[SFABackgroundSessionManager alloc] initWithClient:mockClient];
    [session setupBackgroundSession];
    NSUInteger identifier = 1;
    id mockSessionTaskDelegate = OCMProtocolMock(@protocol(SFAURLSessionTaskDelegate));
    XCTAssertNil([session delegateForCurrentBackgroundSessionAndTaskWithIdentifier:identifier], @"*1 URL session task should be nil");
    [session addDelegate:mockSessionTaskDelegate forCurrentBackgroundSessionAndTaskWithIdentifier:identifier];
    XCTAssertEqual(mockSessionTaskDelegate, [session delegateForCurrentBackgroundSessionAndTaskWithIdentifier:identifier], @"URL session task delegate not set properly");
    
    [session removeDelegateForCurrentBackgroundSessionAndTaskWithIdentifier:identifier];
    XCTAssertNil([session delegateForCurrentBackgroundSessionAndTaskWithIdentifier:identifier], @"*1 URL session task not removed properly");
    
    [session addDelegate:mockSessionTaskDelegate forCurrentBackgroundSessionAndTaskWithIdentifier:identifier];
    [session removeAllTaskSpecificDelegatesForCurrentBackgroundSession];
    NSMutableDictionary *allTaskSpecificDelegates = session.allTaskSpecificDelegates;
    NSURLSession *bgSession = [session backgroundSession];
    NSString *sessionKey = bgSession.configuration.identifier;
    XCTAssertNil([allTaskSpecificDelegates objectForKey:sessionKey], @"*1 Task specific delegates should be nil");
    
    // Updating BackgroundSession
    [session setBackgroundSession:nil]; // invalidate previous task.
    
    NSString *configIdentifier = @"ShareFileTestIdentifier";
    session.configurationForNewBackgroundSession.identifier = configIdentifier;
    session.configurationForNewBackgroundSession.sharedContainerIdentifier = configIdentifier;
    
    NSURLSession *newBackgroundSession = [session backgroundSession];
    XCTAssertNotNil(newBackgroundSession, @"New Background session should not be nil");
    XCTAssertEqual(newBackgroundSession.configuration.identifier, configIdentifier, @"New backgroud session created with different identifier");
    XCTAssertEqual(newBackgroundSession.configuration.sharedContainerIdentifier, configIdentifier, @"New backgroud session created with different sharedContainerIdentifier");
    
    NSUInteger newIdentifier = 2;
    id newMockSessionTaskDelegate = OCMProtocolMock(@protocol(SFAURLSessionTaskDelegate));
    XCTAssertNil([session delegateForSession:newBackgroundSession andTaskWithIdentifier:newIdentifier], @"*2 URL session task should be nil");
    [session addDelegate:newMockSessionTaskDelegate forSession:newBackgroundSession andTaskWithIdentifier:newIdentifier];
    XCTAssertEqual(newMockSessionTaskDelegate, [session delegateForSession:newBackgroundSession andTaskWithIdentifier:newIdentifier], @"*2 URL session task delegate not set properly");
    
    [session removeDelegateForSession:newBackgroundSession andTaskWithIdentifier:newIdentifier];
    XCTAssertNil([session delegateForSession:newBackgroundSession andTaskWithIdentifier:newIdentifier], @"*2 URL session task not removed properly");
    
    [session addDelegate:mockSessionTaskDelegate forSession:newBackgroundSession andTaskWithIdentifier:newIdentifier];
    [session removeAllTaskSpecificDelegatesForSession:newBackgroundSession];
    allTaskSpecificDelegates = session.allTaskSpecificDelegates;
    sessionKey = newBackgroundSession.configuration.identifier;
    XCTAssertNil([allTaskSpecificDelegates objectForKey:sessionKey], @"*2 Task specific delegates should be nil");
}

- (void)testNotifyDelegateUpdateForURLSession {
    id mockClient = OCMClassMock([SFAClient class]);
    SFABackgroundSessionManager *session = [[SFABackgroundSessionManager alloc] initWithClient:mockClient];
    [session setupBackgroundSession];
    NSUInteger identifier = 1;
    id mockTaskSpecificDelegate = OCMProtocolMock(@protocol(SFAURLSessionTaskDelegate));
    id mockTask = OCMClassMock([NSURLSessionTask class]);
    OCMStub([mockTask taskIdentifier]).andReturn(identifier);
    id mockTaskDelegate = OCMProtocolMock(@protocol(SFAURLSessionTaskHttpDelegate));
    
    OCMExpect([mockTaskSpecificDelegate URLSession:[OCMArg isNotNil] task:[OCMArg isNotNil] hasHttpDelegate:[OCMArg isNotNil]]);
    [session addDelegate:mockTaskSpecificDelegate forCurrentBackgroundSessionAndTaskWithIdentifier:identifier];
    [session notifiyDelegateUpdateForURLSession:[session backgroundSession] task:mockTask delegate:mockTaskDelegate];
    OCMVerifyAll(mockTaskSpecificDelegate);
    
    id universalTaskDelegate = OCMProtocolMock(@protocol(SFAURLSessionTaskDelegate));
    session.universalTaskDelegate = universalTaskDelegate;
    OCMExpect([universalTaskDelegate URLSession:[OCMArg isNotNil] task:[OCMArg isNotNil] hasHttpDelegate:[OCMArg isNotNil]]);
    [session notifiyDelegateUpdateForURLSession:[session backgroundSession] task:mockTask delegate:mockTaskDelegate];
    OCMVerifyAll(universalTaskDelegate); // Universal Task delegate should be called in case task specific delegate did not handled this event.
    
    [session removeAllTaskSpecificDelegatesForCurrentBackgroundSession];
    OCMExpect([universalTaskDelegate URLSession:[OCMArg isNotNil] task:[OCMArg isNotNil] hasHttpDelegate:[OCMArg isNotNil]]);
    [session notifiyDelegateUpdateForURLSession:[session backgroundSession] task:mockTask delegate:mockTaskDelegate];
    OCMVerifyAll(universalTaskDelegate); // Universal Task delegate should be called in case there is no task specific delegate.
}

- (void)testNotifyNewTaskForURLSession {
    id mockClient = OCMClassMock([SFAClient class]);
    SFABackgroundSessionManager *session = [[SFABackgroundSessionManager alloc] initWithClient:mockClient];
    [session setupBackgroundSession];
    NSUInteger identifier = 1;
    id mockTaskSpecificDelegate = OCMProtocolMock(@protocol(SFAURLSessionTaskDelegate));
    id mockTask = OCMClassMock([NSURLSessionTask class]);
    id newMockTask = OCMClassMock([NSURLSessionTask class]);
    OCMStub([mockTask taskIdentifier]).andReturn(identifier);
    
    OCMExpect([mockTaskSpecificDelegate URLSession:[OCMArg isNotNil] task:[OCMArg isNotNil] willRetryWithNewTask:[OCMArg isNotNil]]);
    [session addDelegate:mockTaskSpecificDelegate forCurrentBackgroundSessionAndTaskWithIdentifier:identifier];
    [session notifiyNewTaskForURLSession:[session backgroundSession] task:mockTask newTask:newMockTask];
    OCMVerifyAll(mockTaskSpecificDelegate);
    
    id universalTaskDelegate = OCMProtocolMock(@protocol(SFAURLSessionTaskDelegate));
    session.universalTaskDelegate = universalTaskDelegate;
    OCMExpect([mockTaskSpecificDelegate URLSession:[OCMArg isNotNil] task:[OCMArg isNotNil] willRetryWithNewTask:[OCMArg isNotNil]]);
    [session notifiyNewTaskForURLSession:[session backgroundSession] task:mockTask newTask:newMockTask];
    OCMVerifyAll(universalTaskDelegate); // Universal Task delegate should be called in case task specific delegate did not handled this event.
    
    [session removeAllTaskSpecificDelegatesForCurrentBackgroundSession];
    OCMExpect([mockTaskSpecificDelegate URLSession:[OCMArg isNotNil] task:[OCMArg isNotNil] willRetryWithNewTask:[OCMArg isNotNil]]);
    [session notifiyNewTaskForURLSession:[session backgroundSession] task:mockTask newTask:newMockTask];
    OCMVerifyAll(universalTaskDelegate); // Universal Task delegate should be called in case there is no task specific delegate.
}

- (void)testNotifyContextUpdateForURLSession {
    id mockClient = OCMClassMock([SFAClient class]);
    SFABackgroundSessionManager *session = [[SFABackgroundSessionManager alloc] initWithClient:mockClient];
    [session setupBackgroundSession];
    NSUInteger identifier = 1;
    id mockTaskSpecificDelegate = OCMProtocolMock(@protocol(SFAURLSessionTaskDelegate));
    id mockTask = OCMClassMock([NSURLSessionTask class]);
    id newContextObject = [NSDictionary new];
    OCMStub([mockTask taskIdentifier]).andReturn(identifier);
    
    OCMExpect([mockTaskSpecificDelegate URLSession:[OCMArg isNotNil] task:[OCMArg isNotNil] willUseContextObject:[OCMArg isNotNil]]);
    [session addDelegate:mockTaskSpecificDelegate forCurrentBackgroundSessionAndTaskWithIdentifier:identifier];
    [session notifyContextUpdateForSession:[session backgroundSession] task:mockTask contextObject:newContextObject];
    OCMVerifyAll(mockTaskSpecificDelegate);
    
    id universalTaskDelegate = OCMProtocolMock(@protocol(SFAURLSessionTaskDelegate));
    session.universalTaskDelegate = universalTaskDelegate;
    OCMExpect([mockTaskSpecificDelegate URLSession:[OCMArg isNotNil] task:[OCMArg isNotNil] willUseContextObject:[OCMArg isNotNil]]);
    [session notifyContextUpdateForSession:[session backgroundSession] task:mockTask contextObject:newContextObject];
    OCMVerifyAll(universalTaskDelegate); // Universal Task delegate should be called in case task specific delegate did not handled this event.
    
    [session removeAllTaskSpecificDelegatesForCurrentBackgroundSession];
    OCMExpect([mockTaskSpecificDelegate URLSession:[OCMArg isNotNil] task:[OCMArg isNotNil] willUseContextObject:[OCMArg isNotNil]]);
    [session notifyContextUpdateForSession:[session backgroundSession] task:mockTask contextObject:newContextObject];
    OCMVerifyAll(universalTaskDelegate); // Universal Task delegate should be called in case there is no task specific delegate.
}

@end
