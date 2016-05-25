#import "SFAAsyncStreamedFileUploader.h"
#import "SFAAsyncUploaderBaseProtected.h"

@implementation SFAAsyncStreamedFileUploader

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config andExpirationDays:(int)expirationDays {
    self = [super initWithSFAClient:client uploadSpecificationRequest:uploadSpecificationRequest filePath:filePath fileUploaderConfig:config andExpirationDays:expirationDays];
    if (self) {
        if (self.config) {
            self.config.numberOfThreads = 1;
        }
    }
    return self;
}

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath {
    return [self initWithSFAClient:client uploadSpecificationRequest:uploadSpecificationRequest filePath:filePath fileUploaderConfig:nil andExpirationDays:-1];
}

#if TARGET_OS_IPHONE
- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset fileUploaderConfig:(SFAFileUploaderConfig *)config andExpirationDays:(int)expirationDays {
    self = [super initWithSFAClient:client uploadSpecificationRequest:uploadSpecificationRequest asset:asset fileUploaderConfig:config andExpirationDays:expirationDays];
    if (self) {
        if (self.config) {
            self.config.numberOfThreads = 1;
        }
    }
    return self;
}

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset {
    return [self initWithSFAClient:client uploadSpecificationRequest:uploadSpecificationRequest asset:asset fileUploaderConfig:nil andExpirationDays:-1];
}

#endif

@end
