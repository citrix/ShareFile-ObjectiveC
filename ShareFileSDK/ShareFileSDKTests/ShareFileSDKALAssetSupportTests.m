#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"

#if TARGET_OS_IPHONE

#import <OCMock/OCMock.h>

#endif

// Hidden APIs
#import "SFAAsyncStandardFileUploader.h"
#import "SFAAsyncStreamedFileUploader.h"
#import "SFAAsyncThreadedFileUploader.h"
#import "SFAUploaderBaseProtected.h"
//

@interface ShareFileSDKALAssetSupportTests : ShareFileSDKTests

@end

@implementation ShareFileSDKALAssetSupportTests

- (void)testFileExtension {
    // Asset Mock
    ALAsset *asset = [ALAsset new];
    id assetMock = OCMPartialMock(asset);
    // Test
    XCTAssertNil([assetMock fileExtension], @"Extension should be nil as defaultRepresentation is nil.");
    // Asset Rep Mock
    id assetRepresentationMock = OCMClassMock([ALAssetRepresentation class]);
    OCMStub([assetMock defaultRepresentation]).andReturn(assetRepresentationMock);
    // Test
    XCTAssertNil([assetMock fileExtension], @"Extension should be nil as url is nil.");
    // Mock URL
    NSURL *mockURL = [NSURL URLWithString:@"assets-library://asset/asset.M4V?id=1000000000&ext=M4V"];
    OCMStub([assetRepresentationMock url]).andReturn(mockURL);
    // Test
    XCTAssertTrue([[assetMock fileExtension] isEqualToString:@"M4V"], @"Did not return correct file extension. Expected M4V to be returned");
    // URL with no ext
    asset = [ALAsset new];
    assetMock = OCMPartialMock(asset);
    assetRepresentationMock = OCMClassMock([ALAssetRepresentation class]);
    OCMStub([assetMock defaultRepresentation]).andReturn(assetRepresentationMock);
    mockURL = [NSURL URLWithString:@"assets-library://asset/asset.M4V?id=1000000000"];
    OCMStub([assetRepresentationMock url]).andReturn(mockURL);
    // Test
    XCTAssertNil([assetMock fileExtension], @"Extension should be nil as url does not have ext.");
    // URL with ext=
    asset = [ALAsset new];
    assetMock = OCMPartialMock(asset);
    assetRepresentationMock = OCMClassMock([ALAssetRepresentation class]);
    OCMStub([assetMock defaultRepresentation]).andReturn(assetRepresentationMock);
    mockURL = [NSURL URLWithString:@"assets-library://asset/asset.M4V?id=1000000000&ext="];
    OCMStub([assetRepresentationMock url]).andReturn(mockURL);
    // Test
    XCTAssertTrue([[assetMock fileExtension] isEqualToString:@""], @"Extension should be empty as url have ext=<nothing>.");
}

- (void)testUploadSpecRequestInitialization {
    // Asset Mock
    ALAsset *asset = [ALAsset new];
    id assetMock = OCMPartialMock(asset);
    id assetRepresentationMock = OCMClassMock([ALAssetRepresentation class]);
    OCMStub([assetMock defaultRepresentation]).andReturn(assetRepresentationMock);
    NSURL *mockURL = [NSURL URLWithString:@"assets-library://asset/asset.png?id=1000000000&ext=png"];
    OCMStub([assetRepresentationMock url]).andReturn(mockURL);
    OCMStub([(ALAssetRepresentation *) assetRepresentationMock size]).andReturn(100);
    OCMStub([assetMock valueForProperty:ALAssetPropertyType]).andReturn(ALAssetTypePhoto);
    OCMStub([assetMock valueForProperty:ALAssetPropertyDate]).andReturn([NSDate dateWithTimeIntervalSinceReferenceDate:0]);
    // Test
    NSURL *parentURL = [NSURL URLWithString:@"http://www.parentfolder.com"];
    NSString *desc = @"Sample Details";
    SFAUploadSpecificationRequest *req = [assetMock uploadSpecificationRequestWithFileName:nil parentFolderURL:parentURL description:desc shouldOverwrite:YES uploadMethod:SFAUploadMethodThreaded];
    XCTAssertTrue(req.fileName.length > 0, @"fileName should be present and non-zero length.");
    XCTAssertTrue([req.fileName rangeOfString:@"photo"].location != NSNotFound, @"fileName should have 'photo' in it.");
    XCTAssertTrue([req.title isEqualToString:req.fileName], @"* tile should be equal to fileName.");
    XCTAssertTrue([req.destinationURI.absoluteString isEqualToString:parentURL.absoluteString], @"* parent URL should be the same as passed.");
    XCTAssertTrue([req.details isEqualToString:desc], @"* details should be the same as passed.");
    XCTAssertTrue(req.overwrite, @"* overwrite should be the same as passed.");
    XCTAssertTrue(req.method == SFAUploadMethodThreaded, @"* method should be the same as passed.");
    //
    asset = [ALAsset new];
    assetMock = OCMPartialMock(asset);
    assetRepresentationMock = OCMClassMock([ALAssetRepresentation class]);
    OCMStub([assetMock defaultRepresentation]).andReturn(assetRepresentationMock);
    mockURL = [NSURL URLWithString:@"assets-library://asset/asset.png?id=1000000000&ext=png"];
    OCMStub([assetRepresentationMock url]).andReturn(mockURL);
    OCMStub([(ALAssetRepresentation *) assetRepresentationMock size]).andReturn(100);
    OCMStub([assetMock valueForProperty:ALAssetPropertyType]).andReturn(ALAssetTypePhoto);
    OCMStub([assetMock valueForProperty:ALAssetPropertyDate]).andReturn([NSDate dateWithTimeIntervalSinceReferenceDate:0]);
    // Test
    NSString *fileName = @"my.png";
    req = [assetMock uploadSpecificationRequestWithFileName:fileName parentFolderURL:parentURL description:desc shouldOverwrite:YES uploadMethod:SFAUploadMethodStandard];
    XCTAssertTrue([req.fileName isEqualToString:fileName], @"fileName should be the same as passed.");
    XCTAssertTrue([req.title isEqualToString:req.fileName], @"** tile should be equal to fileName.");
    XCTAssertTrue([req.destinationURI.absoluteString isEqualToString:parentURL.absoluteString], @"** parent URL should be the same as passed.");
    XCTAssertTrue([req.details isEqualToString:desc], @"** details should be the same as passed.");
    XCTAssertTrue(req.overwrite, @"** overwrite should be the same as passed.");
    XCTAssertTrue(req.method == SFAUploadMethodStandard, @"** method should be the same as passed.");
}

- (void)testUploader {
#if TARGET_OS_IPHONE
    // Standard
    SFAUploadSpecificationRequest *specReq = [[SFAUploadSpecificationRequest alloc] init];
    specReq.method = SFAUploadMethodStandard;
    id mockAsset = OCMClassMock([ALAsset class]);
    SFAUploaderBase *uploader = nil;
    int expirationDays = -1;
#if ShareFile
    expirationDays = arc4random();
    uploader = [self.client asyncFileUploaderWithUploadSpecificationRequest:specReq asset:mockAsset fileUploaderConfig:nil expirationDays:expirationDays];
#else
    uploader = [self.client asyncFileUploaderWithUploadSpecificationRequest:specReq asset:mockAsset fileUploaderConfig:nil];
#endif
    // Test
    XCTAssertTrue([uploader isKindOfClass:[SFAAsyncStandardFileUploader class]], @"Standard uploader expected.");
    XCTAssertEqual(self.client, uploader.client, @"* Client should be same as the one from which uploader is created.");
    XCTAssertEqual(mockAsset, uploader.asset, @"* Asset should be same as passed asset.");
    XCTAssertEqual(specReq, uploader.uploadSpecificationRequest, @"* Spec Request should be same as passed.");
    XCTAssertTrue(expirationDays == uploader.expirationDays, @"* Expiration Days should be -1");
    // Streamed
    specReq.method = SFAUploadMethodStreamed;
#if ShareFile
    uploader = [self.client asyncFileUploaderWithUploadSpecificationRequest:specReq asset:mockAsset fileUploaderConfig:nil expirationDays:expirationDays];
#else
    uploader = [self.client asyncFileUploaderWithUploadSpecificationRequest:specReq asset:mockAsset fileUploaderConfig:nil];
#endif
    XCTAssertTrue([uploader isKindOfClass:[SFAAsyncStreamedFileUploader class]], @"Streamed uploader expected.");
    XCTAssertEqual(self.client, uploader.client, @"** Client should be same as the one from which uploader is created.");
    XCTAssertEqual(mockAsset, uploader.asset, @"** Asset should be same as passed asset.");
    XCTAssertEqual(specReq, uploader.uploadSpecificationRequest, @"** Spec Request should be same as passed.");
    XCTAssertTrue(expirationDays == uploader.expirationDays, @"**  Expiration Days should be -1");
    // Threaded
    specReq.method = SFAUploadMethodThreaded;
#if ShareFile
    uploader = [self.client asyncFileUploaderWithUploadSpecificationRequest:specReq asset:mockAsset fileUploaderConfig:nil expirationDays:expirationDays];
#else
    uploader = [self.client asyncFileUploaderWithUploadSpecificationRequest:specReq asset:mockAsset fileUploaderConfig:nil];
#endif
    XCTAssertTrue([uploader isKindOfClass:[SFAAsyncThreadedFileUploader class]], @"Threaded uploader expected.");
    XCTAssertEqual(self.client, uploader.client, @"** Client should be same as the one from which uploader is created.");
    XCTAssertEqual(mockAsset, uploader.asset, @"** Asset should be same as passed asset.");
    XCTAssertEqual(specReq, uploader.uploadSpecificationRequest, @"** Spec Request should be same as passed.");
    XCTAssertTrue(expirationDays == uploader.expirationDays, @"**  Expiration Days should be -1");
#endif
}

@end
