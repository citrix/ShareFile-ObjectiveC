#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"

@interface ShareFileSDKItemsEntityCatTests : ShareFileSDKTests

@end

@implementation ShareFileSDKItemsEntityCatTests

- (void)testItemEntityAlias {
    // Arrange
    NSString *alias = @"randomId";
    NSURL *uri = [self.client.items urlWithAlias:alias];
    NSString *expectedUri = @"https://secure.sf-api.com/sf/v3/Items(randomId)";
    
    XCTAssertTrue([[uri absoluteString] isEqualToString:expectedUri], @"Invalid Item Entity Alias");
}

@end
