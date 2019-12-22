#import <Foundation/Foundation.h>
#import "SFAAsyncUploaderBase.h"
#import "SFAFileUploaderConfig.h"
#import "SFAUploadSpecificationRequest.h"
#import "SFATask.h"
#import "SFAUploadResponse.h"
#import "SFAUploaderTask.h"
#import "SFAFileInfo.h"
#import "SFACompositeUploaderTask.h"

#if TARGET_OS_IPHONE
#import <AssetsLibrary/AssetsLibrary.h>
#endif

@interface SFAAsyncUploaderBase () <SFAHttpTaskDelegate>

@property (nonatomic, strong) SFAFileUploaderConfig *config;
@property (nonatomic) BOOL hasStartedTask;

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)fileUpConfig andExpirationDays:(int)expirationDays;

#if TARGET_OS_IPHONE
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset fileUploaderConfig:(SFAFileUploaderConfig *)fileUpConfig andExpirationDays:(int)expirationDays;
#pragma clang diagnostic pop
#endif

- (SFApiQuery *)createUpload:(SFAUploadSpecificationRequest *)uploadSpecificationRequest;
- (void)checkResumeAsync;
- (NSString *)calculateHashOfNextNBytes:(NSNumber *)count;
- (id)uploadResponseAsync:(SFAHttpRequestResponseDataContainer *)dataContainer;
- (id <SFAQuery> )queryForURLSession:(NSURLSession *)session task:(NSURLSessionTask *)task;

@end
