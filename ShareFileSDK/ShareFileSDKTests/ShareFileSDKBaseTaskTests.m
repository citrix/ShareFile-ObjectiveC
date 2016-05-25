#import <Foundation/Foundation.h>

#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
// Hidden APIs
#import "SFABaseTask.h"
#import "SFABaseTaskProtected.h"
//

@interface ShareFileSDKBaseTaskTests : ShareFileSDKTests

@property (nonatomic) int observerCalledCount;
@property (nonatomic) BOOL executingObserveCalled;
@property (nonatomic) int executingRecentValue;
@property (nonatomic) BOOL finishedObserveCalled;
@property (nonatomic) int finishedRecentValue;
@property (nonatomic) BOOL cancelledObserveCalled;
@property (nonatomic) int cancelledRecentValue;
@property (nonatomic, strong) SFABaseTask *task;

@end

@implementation ShareFileSDKBaseTaskTests

- (void)setUp {
    self.task = [SFABaseTask new];
    [self.task addObserver:self forKeyPath:@"isExecuting" options:NSKeyValueObservingOptionNew context:NULL];
    [self.task addObserver:self forKeyPath:@"isCancelled" options:NSKeyValueObservingOptionNew context:NULL];
    [self.task addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:NULL];
    [self resetTestStateVariables];
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
    self.task = nil;
}

- (void)testTaskStateChangesCancelBeforeStart {
    //
    XCTAssertFalse(self.task.isExecuting, @"*1 Invalid State");
    XCTAssertFalse(self.executingObserveCalled, @"*2 Invalid State.");
    XCTAssertTrue(self.executingRecentValue == -1, @"*3 Invalid State.");
    //
    XCTAssertFalse(self.task.isCancelled, @"*4 Invalid State.");
    XCTAssertFalse(self.cancelledObserveCalled, @"*5 Invalid State.");
    XCTAssertTrue(self.cancelledRecentValue == -1, @"*6 Invalid State.");
    //
    XCTAssertFalse(self.task.isFinished, @"*7 Invalid State.");
    XCTAssertFalse(self.finishedObserveCalled, @"*8 Invalid State.");
    XCTAssertTrue(self.finishedRecentValue == -1, @"*9 Invalid State.");
    //
    XCTAssertTrue(self.observerCalledCount == 0, @"*10 Invalid State.");
    // Task Cancel
    [self.task cancel];
    // Test
    XCTAssertTrue(self.task.isCancelled, @"*11 Invalid State.");
    XCTAssertTrue(self.cancelledObserveCalled, @"*13 Invalid State.");
    XCTAssertTrue(self.cancelledRecentValue == 1, @"*14 Invalid State.");
    XCTAssertTrue(self.observerCalledCount == 1, @"*15 Invalid State.");
    // Start Task
    [self.task start];
    //
    XCTAssertFalse(self.task.isExecuting, @"*16 Invalid State.");
    XCTAssertFalse(self.executingObserveCalled, @"*17 Invalid State.");
    XCTAssertTrue(self.executingRecentValue == -1, @"*18 Invalid State.");
    //
    XCTAssertTrue(self.task.isCancelled, @"*19 Invalid State.");
    XCTAssertTrue(self.cancelledObserveCalled, @"*20 Invalid State.");
    XCTAssertTrue(self.cancelledRecentValue == 1, @"*21 Invalid State.");
    //
    XCTAssertTrue(self.task.isFinished, @"*22 Invalid State.");
    XCTAssertTrue(self.finishedObserveCalled, @"*23 Invalid State.");
    XCTAssertTrue(self.finishedRecentValue == 1, @"*24 Invalid State.");
    //
    XCTAssertTrue(self.observerCalledCount == 2, @"*25 Invalid State.");
}

- (void)testTaskStateChangesCancelAfterStart {
    //
    XCTAssertFalse(self.task.isExecuting, @"*1 Invalid State.");
    XCTAssertFalse(self.executingObserveCalled, @"*2 Invalid State.");
    XCTAssertTrue(self.executingRecentValue == -1, @"*3 Invalid State.");
    //
    XCTAssertFalse(self.task.isCancelled, @"*4 Invalid State.");
    XCTAssertFalse(self.cancelledObserveCalled, @"*5 Invalid State.");
    XCTAssertTrue(self.cancelledRecentValue == -1, @"*6 Invalid State.");
    //
    XCTAssertFalse(self.task.isFinished, @"*7 Invalid State.");
    XCTAssertFalse(self.finishedObserveCalled, @"*8 Invalid State.");
    XCTAssertTrue(self.finishedRecentValue == -1, @"*9 Invalid State.");
    //
    XCTAssertTrue(self.observerCalledCount == 0, @"*10 Invalid State.");
    // Start Task
    [self.task start];
    // Test
    XCTAssertTrue(self.task.isExecuting, @"*11 Invalid State.");
    XCTAssertTrue(self.executingObserveCalled, @"*12 Invalid State.");
    XCTAssertTrue(self.executingRecentValue == 1, @"*13 Invalid State.");
    XCTAssertTrue(self.observerCalledCount == 1, @"*14 Invalid State.");
    // Cancel Task
    [self.task cancel];
    //
    XCTAssertFalse(self.task.isExecuting, @"*15 Invalid State.");
    XCTAssertTrue(self.executingObserveCalled, @"*16 Invalid State.");
    XCTAssertTrue(self.executingRecentValue == 0, @"*17 Invalid State.");
    //
    XCTAssertTrue(self.task.isCancelled, @"*18 Invalid State.");
    XCTAssertTrue(self.cancelledObserveCalled, @"*19 Invalid State.");
    XCTAssertTrue(self.cancelledRecentValue == 1, @"*20 Invalid State.");
    //
    XCTAssertTrue(self.task.isFinished, @"*21 Invalid State.");
    XCTAssertTrue(self.finishedObserveCalled, @"*22 Invalid State.");
    XCTAssertTrue(self.finishedRecentValue == 1, @"*23 Invalid State.");
    //
    XCTAssertTrue(self.observerCalledCount == 4, @"*24 Invalid State.");
}

- (void)testTaskStateChangesNormalFlow {
    //
    XCTAssertFalse(self.task.isExecuting, @"*1 Invalid State.");
    XCTAssertFalse(self.executingObserveCalled, @"*2 Invalid State.");
    XCTAssertTrue(self.executingRecentValue == -1, @"*3 Invalid State.");
    //
    XCTAssertFalse(self.task.isCancelled, @"*4 Invalid State.");
    XCTAssertFalse(self.cancelledObserveCalled, @"*5 Invalid State.");
    XCTAssertTrue(self.cancelledRecentValue == -1, @"*6 Invalid State.");
    //
    XCTAssertFalse(self.task.isFinished, @"*7 Invalid State.");
    XCTAssertFalse(self.finishedObserveCalled, @"*8 Invalid State.");
    XCTAssertTrue(self.finishedRecentValue == -1, @"*9 Invalid State.");
    //
    XCTAssertTrue(self.observerCalledCount == 0, @"*10 Invalid State.");
    // Start Task
    [self.task start];
    // Test
    XCTAssertTrue(self.task.isExecuting, @"*11 Invalid State.");
    XCTAssertTrue(self.executingObserveCalled, @"*12 Invalid State.");
    XCTAssertTrue(self.executingRecentValue == 1, @"*13 Invalid State.");
    XCTAssertTrue(self.observerCalledCount == 1, @"*14 Invalid State.");
    // Finish Task
    [self.task taskCompleted:nil];
    //
    XCTAssertFalse(self.task.isExecuting, @"*15 Invalid State.");
    XCTAssertTrue(self.executingObserveCalled, @"*16 Invalid State.");
    XCTAssertTrue(self.executingRecentValue == 0, @"*17 Invalid State.");
    //
    XCTAssertFalse(self.task.isCancelled, @"*18 Invalid State.");
    XCTAssertFalse(self.cancelledObserveCalled, @"*19 Invalid State.");
    XCTAssertTrue(self.cancelledRecentValue == -1, @"*20 Invalid State.");
    //
    XCTAssertTrue(self.task.isFinished, @"*21 Invalid State.");
    XCTAssertTrue(self.finishedObserveCalled, @"*22 Invalid State.");
    XCTAssertTrue(self.finishedRecentValue == 1, @"*23 Invalid State.");
    //
    XCTAssertTrue(self.observerCalledCount == 3, @"*24 Invalid State.");
}

#pragma mark - Helper Method(s)

- (void)resetTestStateVariables {
    self.observerCalledCount = 0;
    self.executingObserveCalled = NO;
    self.executingRecentValue = -1;
    self.finishedObserveCalled = NO;
    self.finishedRecentValue = -1;
    self.cancelledObserveCalled = NO;
    self.cancelledRecentValue = -1;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    self.observerCalledCount++;
    if ([object isEqual:self.task]) {
        if ([keyPath isEqualToString:@"isExecuting"]) {
            self.executingObserveCalled = YES;
            self.executingRecentValue = ((NSNumber *)change[@"new"]).intValue;
        }
        else if ([keyPath isEqualToString:@"isCancelled"]) {
            self.cancelledObserveCalled = YES;
            self.cancelledRecentValue = ((NSNumber *)change[@"new"]).intValue;
        }
        else if ([keyPath isEqualToString:@"isFinished"]) {
            self.finishedObserveCalled = YES;
            self.finishedRecentValue = ((NSNumber *)change[@"new"]).intValue;
        }
    }
}

@end
