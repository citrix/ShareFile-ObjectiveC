#import <Foundation/Foundation.h>
#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"
// Hidden APIs
#import "SFAJSONToODataMapper.h"
#import "SFApiQuery.h"
//

@interface ShareFileSDKPrincipal : SFIPrincipal

@property (strong, nonatomic) NSString *mySpecialPrincipalProperty;

@end

@implementation ShareFileSDKPrincipal

@end

@interface ShareFileSDKFile : SFIFile

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
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFIPrincipal class]] == [SFIPrincipal class], @"*1 No mapping should have been found");
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFIFile class]] == [SFIFile class], @"*2 No mapping should have been found");
    // Add two mappings
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFIPrincipal class] withNewModelClass:[ShareFileSDKPrincipal class]];
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFIFile class] withNewModelClass:[ShareFileSDKFile class]];
    // Test both mappings
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFIPrincipal class]] == [ShareFileSDKPrincipal class], @"*3 Appropiate mapping should have been found");
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFIFile class]] == [ShareFileSDKFile class], @"*4 Appropiate mapping should have been found");
    // Remove mapping 1-by-1
    [SFAModelClassMapper removeMappingForDefaultModelClass:[SFIPrincipal class]];
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFIPrincipal class]] == [SFIPrincipal class], @"*5 No mapping should have been found");
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFIFile class]] == [ShareFileSDKFile class], @"*6 Appropiate mapping should have been found");
    [SFAModelClassMapper removeMappingForDefaultModelClass:[SFIFile class]];
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFIFile class]] == [SFIFile class], @"*7 No mapping should have been found");
    // Add two mappings again
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFIPrincipal class] withNewModelClass:[ShareFileSDKPrincipal class]];
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFIFile class] withNewModelClass:[ShareFileSDKFile class]];
    // Test both mappings
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFIPrincipal class]] == [ShareFileSDKPrincipal class], @"*8 Appropiate mapping should have been found");
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFIFile class]] == [ShareFileSDKFile class], @"*9 Appropiate mapping should have been found");
    // Remove all mapping
    [SFAModelClassMapper removeAllMappings];
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFIPrincipal class]] == [SFIPrincipal class], @"*10 No mapping should have been found");
    XCTAssertTrue([SFAModelClassMapper mappedModelClassForDefaultModelClass:[SFIFile class]] == [SFIFile class], @"*11 No mapping should have been found");
}

- (void)testMappingWithODataJSONMapper {
    // Make object from Type
    NSDictionary *dict = @{ @"odata.type" : @"ShareFile.Api.Models.SFIPrincipal" };
    //
    id obj = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
    // Test
    XCTAssertTrue([obj class] == [SFIPrincipal class], @"*1 Should have returned SFIPrincipal object");
    // Add mapping
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFIPrincipal class] withNewModelClass:[ShareFileSDKPrincipal class]];
    //
    obj = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
    // Test again
    XCTAssertTrue([obj class] == [ShareFileSDKPrincipal class], @"*2 Should have returned ShareFileSDKPrincipal object");
    // Remove mapping
    [SFAModelClassMapper removeMappingForDefaultModelClass:[SFIPrincipal class]];
    //
    obj = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
    // Test again
    XCTAssertTrue([obj class] == [SFIPrincipal class], @"*3 Should have returned SFIPrincipal object");
    // Test with metadata
    dict = @{ @"odata.metadata" : @"https://staging.sharefilenext.com/sf/v3/$metadata#Items/ShareFile.Api.Models.File@Element" };
    //
    obj = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
    // Test
    XCTAssertTrue([obj class] == [SFIFile class], @"*4 Should have returned SFIFile object");
    // Add mapping
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFIFile class] withNewModelClass:[ShareFileSDKFile class]];
    //
    obj = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
    // Test again
    XCTAssertTrue([obj class] == [ShareFileSDKFile class], @"*5 Should have returned ShareFileSDKFile object");
    // Remove mapping
    [SFAModelClassMapper removeMappingForDefaultModelClass:[SFIFile class]];
    //
    obj = [SFAJSONToODataMapper ODataObjectWithJSONDictionaryRepresentation:dict];
    // Test again
    XCTAssertTrue([obj class] == [SFIFile class], @"*6 Should have returned SFIFile object");
}

- (void)testSFApiQueryResponseClass {
    SFApiQuery *query = [[SFApiQuery alloc] initWithClient:self.client];
    XCTAssertNil(query.responseClass, @"*1 Response class should be nil");
    // Add SFIPrincipal Class
    query.responseClass = [SFIPrincipal class];
    XCTAssertTrue(query.responseClass == [SFIPrincipal class], @"*2 Response class should be default.");
    // Add mapping
    [SFAModelClassMapper addMappingForDefaultModelClass:[SFIPrincipal class] withNewModelClass:[ShareFileSDKPrincipal class]];
    // Test
    XCTAssertTrue(query.responseClass == [ShareFileSDKPrincipal class], @"*3 Response class should be overriden.");
    // Remove mapping
    [SFAModelClassMapper removeMappingForDefaultModelClass:[SFIPrincipal class]];
    // Test again
    XCTAssertTrue(query.responseClass == [SFIPrincipal class], @"*4 Response class should be default.");
}

@end
