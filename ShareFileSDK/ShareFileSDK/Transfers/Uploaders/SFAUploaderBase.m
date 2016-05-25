#import "SFAUploaderBaseProtected.h"
#import "NSString+sfapi.h"
#import "SFModelConstants.h"

@implementation SFAUploaderBase

const NSUInteger SFAMaxBufferLength = 65536; // Should be <= NSIntegerMax

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)upSpecReq filePath:(NSString *)filePath andExpirationDays:(int)expirationDays {
    self = [super init];
    if (self) {
        NSAssert(client, @"Client Cannot be nil for:%@", NSStringFromClass([self class]));
        NSAssert(filePath, @"File Path Cannot be nil for:%@", NSStringFromClass([self class]));
        NSAssert(upSpecReq, @"UploadSpecification Request Cannot be nil for:%@", NSStringFromClass([self class]));
        [self setupWithClient:client uploadSpecificationRequest:upSpecReq filePath:filePath asset:nil andExpirationDays:expirationDays];
    }
    return self;
}

#if TARGET_OS_IPHONE
- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)upSpecReq asset:(ALAsset *)asset andExpirationDays:(int)expirationDays {
    self = [super init];
    if (self) {
        NSAssert(client, @"Client Cannot be nil for:%@", NSStringFromClass([self class]));
        NSAssert(asset, @"asset Cannot be nil for:%@", NSStringFromClass([self class]));
        NSAssert(upSpecReq, @"UploadSpecification Request Cannot be nil for:%@", NSStringFromClass([self class]));
        [self setupWithClient:client uploadSpecificationRequest:upSpecReq filePath:nil asset:asset andExpirationDays:expirationDays];
    }
    return self;
}

#endif

#if !(TARGET_OS_IPHONE)
@class ALAsset;
#endif
- (void)setupWithClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)upSpecReq filePath:(NSString *)filePath asset:(ALAsset *)asset andExpirationDays:(int)expirationDays {
    self.client = client;
    self.uploadSpecificationRequest = upSpecReq;
    
#if TARGET_OS_IPHONE
    if (filePath) {
        _fileHandler = [[SFAFileInfo alloc] initWithFilePath:filePath];
    }
    else {
        _asset = asset;
    }
    ALAssetRepresentation *rep = self.asset.defaultRepresentation;
    self.uploadSpecificationRequest.fileSize = filePath ?[[self.fileHandler fileSize] unsignedLongLongValue] : (unsigned long long)rep.size;
#else
    _fileHandler = [[SFAFileInfo alloc] initWithFilePath:filePath];
    self.uploadSpecificationRequest.fileSize = [[self.fileHandler fileSize] unsignedLongLongValue];
#endif

    self.uploadSpecificationRequest.threadCount = self.uploadSpecificationRequest.threadCount > 0 ? self.uploadSpecificationRequest.threadCount : 1;
    self.expirationDays = expirationDays;
}

- (SFApiQuery *)uploadSpecificationQuery {
    SFApiQuery *query = [self.client.items uploadWithUrl:self.uploadSpecificationRequest.destinationURI
                                                  method:[self convertToString:self.uploadSpecificationRequest.method]
                                                     raw:[NSNumber numberWithBool:self.uploadSpecificationRequest.raw]
                                                fileName:self.uploadSpecificationRequest.fileName
                                                fileSize:[NSNumber numberWithUnsignedLongLong:self.uploadSpecificationRequest.fileSize]
                                                 batchId:self.uploadSpecificationRequest.batchId
                                               batchLast:[NSNumber numberWithBool:self.uploadSpecificationRequest.batchLast]
                                               canResume:[NSNumber numberWithBool:self.uploadSpecificationRequest.canResume]
                                               startOver:[NSNumber numberWithBool:self.uploadSpecificationRequest.startOver]
                                                   unzip:[NSNumber numberWithBool:self.uploadSpecificationRequest.unzip]
                                                    tool:self.uploadSpecificationRequest.tool
                                               overwrite:[NSNumber numberWithBool:self.uploadSpecificationRequest.overwrite]
                                                   title:self.uploadSpecificationRequest.title
                                                 details:self.uploadSpecificationRequest.details
                                                  isSend:[NSNumber numberWithBool:self.uploadSpecificationRequest.send]
                                                sendGuid:self.uploadSpecificationRequest.sendGuid
                                                    opid:nil
                                             threadCount:[NSNumber numberWithInt:self.uploadSpecificationRequest.threadCount]
                                          responseFormat:self.uploadSpecificationRequest.responseFormat
                                                  notify:[NSNumber numberWithBool:self.uploadSpecificationRequest.notify]
                                    clientCreatedDateUTC:self.uploadSpecificationRequest.clientCreatedDateUtc
                                   clientModifiedDateUTC:self.uploadSpecificationRequest.clientModifiedDateUtc
                                       andExpirationDays:nil];
    return query;
}

- (NSString *)convertToString:(SFAUploadMethod)method {
    NSString *result = nil;
    
    switch (method) {
        case SFAUploadMethodStandard:
            result = kSFUploadMethodStandard;
            break;
            
        case SFAUploadMethodStreamed:
            result = kSFUploadMethodStreamed;
            break;
            
        case SFAUploadMethodThreaded:
            result = kSFUploadMethodThreaded;
            break;
            
        default:
            break;
    }
    
    return result;
}

- (NSURL *)chunkUriForStandardUploads {
    NSURL *uploadUrl = self.uploadSpecification.ChunkUri;
    if ([[[self.uploadSpecification.ChunkUri absoluteString] escapeString] rangeOfString:@"&fmt=json" options:NSCaseInsensitiveSearch].location == NSNotFound) {
        uploadUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self.uploadSpecification.ChunkUri absoluteString], @"&fmt=json"]];
    }
    return uploadUrl;
}

@end
