#import <Foundation/Foundation.h>
#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
// Hidden APIs
#import "SFAJSONToODataMapper.h"
#import "SFApiQuery.h"
//

@interface ShareFileSDKPrincipal : SFPrincipal

@property (strong, nonatomic) NSString *mySpecialPrincipalProperty;

@end

@implementation ShareFileSDKPrincipal

@end

@interface ShareFileSDKFile : SFFile

@property (strong, nonatomic) NSString *mySpecialFileProperty;

@end

@implementation ShareFileSDKFile

@end

@interface ShareFileSDKModelClassMapperTests : ShareFileSDKTests

@end

@implementation ShareFileSDKModelClassMapperTests

- (void)tearDown {
    [super tearDown];
    [SFAModelClassMapper removeAllMappings];
}

- (void)testMappingWithMapper {
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFPrincipal class]] == [SFPrincipal class], @"*1 No mapping should have been found");
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFFile class]] == [SFFile class], @"*2 No mapping should have been found");
    // Add two mappings
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFPrincipal class] withNewModelClass:[ShareFileSDKPrincipal class]];
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFFile class] withNewModelClass:[ShareFileSDKFile class]];
    // Test both mappings
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFPrincipal class]] == [ShareFileSDKPrincipal class], @"*3 Appropiate mapping should have been found");
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFFile class]] == [ShareFileSDKFile class], @"*4 Appropiate mapping should have been found");
    // Remove mapping 1-by-1
    [SFAModelClassMapper removeMappingForDefaultModelClass:[SFPrincipal class]];
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFPrincipal class]] == [SFPrincipal class], @"*5 No mapping should have been found");
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFFile class]] == [ShareFileSDKFile class], @"*6 Appropiate mapping should have been found");
    [SFAModelClassMapper removeMappingForDefaultModelClass:[SFFile class]];
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFFile class]] == [SFFile class], @"*7 No mapping should have been found");
    // Add two mappings again
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFPrincipal class] withNewModelClass:[ShareFileSDKPrincipal class]];
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFFile class] withNewModelClass:[ShareFileSDKFile class]];
    // Test both mappings
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFPrincipal class]] == [ShareFileSDKPrincipal class], @"*8 Appropiate mapping should have been found");
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFFile class]] == [ShareFileSDKFile class], @"*9 Appropiate mapping should have been found");
    // Remove all mapping
    [SFAModelClassMapper removeAllMappings];
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFPrincipal class]] == [SFPrincipal class], @"*10 No mapping should have been found");
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFFile class]] == [SFFile class], @"*11 No mapping should have been found");
}

- (void)testMappingWithODataJSONMapper {
    // Make object from Type
    NSDictionary *dict = @{ @"odata.type" : @"ShareFile.Api.Models.SFPrincipal" };
    //
    id obj = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
    // Test
    XCTAssertTrue([obj class] == [SFPrincipal class], @"*1 Should have returned SFPrincipal object");
    // Add mapping
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFPrincipal class] withNewModelClass:[ShareFileSDKPrincipal class]];
    //
    obj = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
    // Test again
    XCTAssertTrue([obj class] == [ShareFileSDKPrincipal class], @"*2 Should have returned ShareFileSDKPrincipal object");
    // Remove mapping
    [SFAModelClassMapper removeMappingForDefaultModelClass:[SFPrincipal class]];
    //
    obj = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
    // Test again
    XCTAssertTrue([obj class] == [SFPrincipal class], @"*3 Should have returned SFPrincipal object");
    // Test with metadata
    dict = @{ @"odata.metadata" : @"https://staging.sharefilenext.com/sf/v3/$metadata#Items/ShareFile.Api.Models.File@Element" };
    //
    obj = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
    // Test
    XCTAssertTrue([obj class] == [SFFile class], @"*4 Should have returned SFFile object");
    // Add mapping
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFFile class] withNewModelClass:[ShareFileSDKFile class]];
    //
    obj = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
    // Test again
    XCTAssertTrue([obj class] == [ShareFileSDKFile class], @"*5 Should have returned ShareFileSDKFile object");
    // Remove mapping
    [SFAModelClassMapper removeMappingForDefaultModelClass:[SFFile class]];
    //
    obj = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
    // Test again
    XCTAssertTrue([obj class] == [SFFile class], @"*6 Should have returned SFFile object");
}

- (void)testSFApiQueryResponseClass {
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    XCTAssertNil(query.responseClass, @"*1 Response class should be nil");
    // Add SFPrincipal Class
    query.responseClass = [SFPrincipal class];
    XCTAssertTrue(query.responseClass == [SFPrincipal class], @"*2 Response class should be default.");
    // Add mapping
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFPrincipal class] withNewModelClass:[ShareFileSDKPrincipal class]];
    // Test
    XCTAssertTrue(query.responseClass == [ShareFileSDKPrincipal class], @"*3 Response class should be overriden.");
    // Remove mapping
    [SFAModelClassMapper removeMappingForDefaultModelClass:[SFPrincipal class]];
    // Test again
    XCTAssertTrue(query.responseClass == [SFPrincipal class], @"*4 Response class should be default.");
}

@end
