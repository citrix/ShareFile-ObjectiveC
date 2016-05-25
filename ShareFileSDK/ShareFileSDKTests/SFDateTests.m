@import Foundation;
#import <XCTest/XCTest.h>
#import "NSDate+sfapi.h"

typedef void (^DateTest)(id obj, NSUInteger idx, BOOL *stop);

@interface SFDateTests : XCTestCase

@property (strong) NSArray *box;
@property (strong) NSArray *dropBox;
@property (strong) NSArray *legacy;
@property (strong) NSArray *V3;

@end

@implementation SFDateTests

- (void)setUp {
    [super setUp];
    
    
    self.dropBox = @[@"2015-05-05T15:07:28", @"0001-01-01T00:00:00", @"2014-08-22T13:12:43", @"2015-02-23T19:02:45"];
    //As returned by BOX connector
    self.box = @[@"2015-02-25T14:12:54-05:00",
                 @"2015-02-25T14:14:26-05:00",
                 @"2015-02-27T11:38:14-05:00",
                 @"2015-03-20T20:28:04-04:00",
                 @"2014-08-22T10:17:37-04:00"
    ];
    
    
    self.legacy = @[@"20150225191438", @"20150223195404", @"00010101040000", @"20150511172747", @"99991231235959"];
    
    self.V3 = @[@"2013-10-17T03:54:35.24Z", @"9999-12-31T23:59:59.9999999Z", @"2013-10-17T03:55:04.517Z"];
}

- (DateTest)testBlock {
    return ^(id obj, NSUInteger idx, BOOL *stop) {
               NSDate *parsed = [NSDate dateWithString:obj];
               
               NSLog(@"Parsed: %@ from %@", parsed, obj);
               
               NSAssert(parsed != nil, @"The date should be parsed: %@", obj);
    };
}

- (void)testDateParsing {
    [self.dropBox enumerateObjectsUsingBlock:[self testBlock]];
    [self.box enumerateObjectsUsingBlock:[self testBlock]];
    [self.legacy enumerateObjectsUsingBlock:[self testBlock]];
    [self.V3 enumerateObjectsUsingBlock:[self testBlock]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

@end
