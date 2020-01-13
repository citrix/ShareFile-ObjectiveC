#import <Foundation/Foundation.h>
#import "SFAUploaderBase.h"
#import "SFAClient.h"
#import "SFAUploadSpecificationRequest.h"
#import "SFATransferProgress.h"
#import "SFAQuery.h"
#import "SFIUploadSpecification.h"
#import "SFAFileInfo.h"

#if TARGET_OS_IPHONE
#import <AssetsLibrary/AssetsLibrary.h>
#endif

@interface SFAUploaderBase ()

extern const NSUInteger SFAMaxBufferLength;

@property (nonatomic, strong) SFIUploadSpecification *uploadSpecification;
@property (nonatomic, strong) SFAUploadSpecificationRequest *uploadSpecificationRequest;
@property (nonatomic, weak) SFAClient *client;
@property (nonatomic) int expirationDays;
@property (nonatomic, getter = isPrepared) BOOL prepared;
@property (nonatomic, strong, readonly) id <SFAFileInfo> fileHandler;

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)upSpecReq filePath:(NSString *)filePath andExpirationDays:(int)expirationDays;
- (SFApiQuery *)uploadSpecificationQuery;
- (NSURL *)chunkUriForStandardUploads;

#if TARGET_OS_IPHONE
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property (nonatomic, strong, readonly) ALAsset *asset;

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)upSpecReq asset:(ALAsset *)asset andExpirationDays:(int)expirationDays;
#pragma clang diagnostic pop
#endif

@end
