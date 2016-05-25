#if TARGET_OS_IPHONE
#import <AssetsLibrary/AssetsLibrary.h>
#endif

@interface SFAAsyncStandardFileUploader : SFAAsyncUploaderBase

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config andExpirationDays:(int)expirationDays;
- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath;

#if TARGET_OS_IPHONE
- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset fileUploaderConfig:(SFAFileUploaderConfig *)config andExpirationDays:(int)expirationDays;
- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset;
#endif

+ (instancetype)uploaderForURLSessionTaskDefaultHTTPDelegateWithClient:(SFAClient *)client;

+ (instancetype)uploaderForURLSessionTaskDelegateWithClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config andExpirationDays:(int)expirationDays uploadSpecification:(SFUploadSpecification *)uploadSpecification;

@end
