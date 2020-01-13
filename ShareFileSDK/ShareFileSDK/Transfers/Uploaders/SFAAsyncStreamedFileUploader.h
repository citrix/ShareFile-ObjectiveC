#import "SFAAsyncMultiChunkFileUploader.h"

@interface SFAAsyncStreamedFileUploader : SFAAsyncMultiChunkFileUploader

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config andExpirationDays:(int)expirationDays;
- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath;

#if TARGET_OS_IPHONE
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset fileUploaderConfig:(SFAFileUploaderConfig *)config andExpirationDays:(int)expirationDays;
- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset;
#pragma clang diagnostic pop
#endif

@end
