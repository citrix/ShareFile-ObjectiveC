#import "SFAAsyncMultiChunkFileUploader.h"
#import "SFAAsyncUploaderBaseProtected.h"
#import "SFAUploaderBaseProtected.h"
#import "SFAFilePart.h"
#import "SFACryptoUtils.h"
#import "NSHTTPURLResponse+sfapi.h"
#import "SFAApiResponse.h"
#import "SFAHttpTaskProtected.h"
#import "NSString+sfapi.h"
#import "SFACompositeUploaderTaskInternal.h"
#import "SFAUtils.h"
#import "SFModelConstants.h"

@interface SFAAsyncMultiChunkFileUploader () <SFACompositeTaskDelegate>

@end

@implementation SFAAsyncMultiChunkFileUploader

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest filePath:(NSString *)filePath fileUploaderConfig:(SFAFileUploaderConfig *)config andExpirationDays:(int)expirationDays {
    self = [super initWithSFAClient:client uploadSpecificationRequest:uploadSpecificationRequest filePath:filePath fileUploaderConfig:config andExpirationDays:expirationDays];
    if (self) {
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
    }
    return self;
}

- (instancetype)initWithSFAClient:(SFAClient *)client uploadSpecificationRequest:(SFAUploadSpecificationRequest *)uploadSpecificationRequest asset:(ALAsset *)asset {
    return [self initWithSFAClient:client uploadSpecificationRequest:uploadSpecificationRequest asset:asset fileUploaderConfig:nil andExpirationDays:-1];
}

#endif

#pragma mark - Protected Methods

- (id <SFATransferTask> )uploadAsyncWithTransferData:(NSDictionary *)transferMetadata callbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback progressCallback:(SFATransferTaskProgressCallback)progressCallback {
    if (!self.hasStartedTask) {
        self.hasStartedTask = YES;
        SFApiQuery *query = [self createUpload:self.uploadSpecificationRequest];
        id <SFATransferTask> uploadSpecTask = [self.client taskWithQuery:query callbackQueue:nil completionCallback:nil cancelCallback:nil];
        SFAHttpTask *finishUploadTask = nil;
        SFAUploadMethod uploadMethod = SFAUploadMethodStreamed;
        if (self.uploadSpecificationRequest.method == SFAUploadMethodThreaded) {
            finishUploadTask = [[SFAHttpTask alloc] initWithDelegate:self contextObject:nil callbackQueue:nil client:self.client];
            uploadMethod = SFAUploadMethodThreaded;
        }
        SFACompositeUploaderTask *task = [[SFACompositeUploaderTask alloc] initWithUploadSpecificationTask:(SFAHttpTask *)uploadSpecTask concurrentExecution:self.config.numberOfThreads uploaderTasks:nil finishTask:finishUploadTask delegate:self transferMetadata:transferMetadata callbackQueue:callbackQueue client:self.client uploadMethod:uploadMethod];
#if TARGET_OS_IPHONE
        ALAssetRepresentation *rep = self.asset.defaultRepresentation;
        if (self.asset) {
            [task initializeProgressWithTotalBytes:rep.size];
        }
        else {
#endif
        [task initializeProgressWithTotalBytes:[self.fileHandler fileSize].longLongValue];
#if TARGET_OS_IPHONE
    }
#endif
        task.completionCallback = completionCallback;
        task.cancelCallback = cancelCallback;
        task.progressCallback = progressCallback;
        [self.client executeTask:task];
        return task;
    }
    else {
        NSAssert(NO, @"Can not re-use this instance of uploader as it has already started an upload task.");
    }
    return nil;
}

// This is called from needsResponseHandling delegate to get Uploader specific response handling.
- (id)uploadResponseAsync:(SFAHttpRequestResponseDataContainer *)dataContainer {
    if ([dataContainer.response isSuccessCode]) {
        NSError *jsonError;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:dataContainer.data options:kNilOptions error:&jsonError];
        if (!jsonError) {
            NSNumber *error = jsonDictionary[SFAErrorString];
            id value = jsonDictionary[SFAValue];
            if ([error intValue] != 0) {
                SFAApiResponse *apiResponse = [[SFAApiResponse alloc] init];
                apiResponse.errorCode = [jsonDictionary[SFAErrorCode] intValue];
                apiResponse.errorMessage = jsonDictionary[SFAErrorMessage];
                apiResponse.value = value;
                apiResponse.error = YES;
                return apiResponse;
            }
            else {
                if ([value isKindOfClass:[NSString class]]) {
                    // File Part Successfully uploaded
                    SFAApiResponse *apiResponse = [[SFAApiResponse alloc] init];
                    apiResponse.value = value;
                    apiResponse.error = NO;
                    return apiResponse;
                }
                else {
                    // Uploadresponse Parsing
                    SFAUploadResponse *uploadResponse = [SFAUploadResponse new];
                    [uploadResponse setPropertiesWithJSONDictionary:jsonDictionary];
                    return uploadResponse;
                }
            }
        }
        else {
            return [SFAError errorWithMessage:[jsonError description] type:SFAErrorTypeInvalidResponseError];
        }
    }
    return nil;
}

#pragma mark - Private
- (NSArray *)filePartTasksForParts:(NSArray *)fileParts {
    NSMutableArray *tasksArray = [NSMutableArray array];
    id <SFATransferTask> previousUploadTask = nil;
    unsigned long long filePartsIndex = 0;
    for (SFAFilePart *part in fileParts) {
        NSMutableDictionary *dict = [@{ SFAFilePartString : part, SFARetryCount : @0 } mutableCopy];
        id <SFATransferTask> uploadTask = [[SFAUploaderTask alloc] initWithDelegate:self contextObject:dict client:self.client];
        if ([self.uploadSpecification.Method isEqualToString:kSFUploadMethodStreamed]) {
            NSAssert(part.isLastPart ? (filePartsIndex == fileParts.count - 1) : YES, @"Last part is out of order and will cause failed upload!");
            NSAssert(part.index == ((SFAFilePart *)[fileParts firstObject]).index + filePartsIndex, @"Streamed part is out of order and will cause failed upload!");
            // For Streamed, we need to assure that each uploadTask executes in index order
            if (previousUploadTask) {
                [(NSOperation *)uploadTask addDependency:(NSOperation *)previousUploadTask];
            }
            previousUploadTask = uploadTask;
            filePartsIndex++;
        }
        [tasksArray addObject:uploadTask];
    }
    return [tasksArray copy];
}

- (NSArray *)buildFilePartsForTask:(SFACompositeUploaderTask *)task {
    unsigned long long fileLength;
#if TARGET_OS_IPHONE
    ALAssetRepresentation *rep = self.asset.defaultRepresentation;
    if (self.asset) {
        fileLength = (unsigned long long)rep.size;
    }
    else {
#endif
    fileLength = [self.fileHandler fileSize].unsignedLongLongValue;
#if TARGET_OS_IPHONE
}

#endif
    NSUInteger numberOfParts;
    NSUInteger effectivePartSize = self.config.partSize;
    if (!fileLength) {
        numberOfParts = 0;
        [task taskCompletedWithError:[SFAError errorWithMessage:SFAFileReadError type:SFAErrorTypeUploadError]];
    }
    else {
        numberOfParts = (NSUInteger)ceil((fileLength - [self.uploadSpecification.ResumeOffset unsignedLongValue]) / (effectivePartSize * 1.f));
    }
    if (numberOfParts > 1 && numberOfParts < self.config.numberOfThreads) {
        numberOfParts = self.config.numberOfThreads;
        effectivePartSize = (NSUInteger)ceil((fileLength - [self.uploadSpecification.ResumeOffset unsignedLongLongValue]) / (self.config.numberOfThreads * 1.f));
    }
    
    unsigned long long offset = self.uploadSpecification.ResumeOffset ?[self.uploadSpecification.ResumeOffset unsignedLongLongValue] : 0;
    unsigned long long index = self.uploadSpecification.ResumeIndex ?[self.uploadSpecification.ResumeIndex unsignedLongLongValue] : 0;
    
    NSMutableArray *fileParts = [[NSMutableArray alloc] initWithCapacity:(NSUInteger)numberOfParts];
    for (NSUInteger i = 0; i < numberOfParts; i++) {
        SFAFilePart *part = [[SFAFilePart alloc] init];
        part.index = index;
        part.length = effectivePartSize;
        part.offset = offset;
        part.uploadUrl = self.uploadSpecification.ChunkUri.absoluteString;
        part.lastPart = i + 1 == numberOfParts;
        fileParts[i] = part;
        index++;
        offset += effectivePartSize;
    }
    return [fileParts copy];
}

- (void)fillFilePart:(SFAFilePart *)filePart {
    uint8_t *buffer = malloc(filePart.length);
    NSUInteger bytesRead = 0;
    NSInteger readStatus = 0;
#if TARGET_OS_IPHONE
    ALAssetRepresentation *rep = self.asset.defaultRepresentation;
    if (self.asset) {
        bytesRead = [rep getBytes:buffer fromOffset:(long long)filePart.offset length:filePart.length error:NULL];
    }
    else {
#endif
    NSInputStream *inputStream = [self.fileHandler streamForRead];
    [inputStream open];
    [inputStream setProperty:[NSNumber numberWithUnsignedLongLong:filePart.offset] forKey:NSStreamFileCurrentOffsetKey];
    readStatus = [inputStream read:buffer maxLength:filePart.length];     // Cast NSInteger to NSUInteger
    bytesRead = readStatus >= 0 ? (NSUInteger)readStatus : 0;
    [inputStream close];
    inputStream = nil;
#if TARGET_OS_IPHONE
}

#endif
    if (bytesRead > 0) {
        NSData *data = [NSData dataWithBytes:buffer length:bytesRead];
        filePart.data = data;
        filePart.filePartHash = [SFACryptoUtils md5StringWithData:data];
    }
    free(buffer);
    buffer = nil;
}

- (NSURL *)composedFinishUrl {
    NSMutableString *finishUrlStr = [NSMutableString stringWithString:self.uploadSpecification.FinishUri.absoluteString];
    return [self appendFinalParamsToUrlString:finishUrlStr isFinished:YES isStreamed:NO];
}

- (NSURL *)appendFinalParamsToUrlString:(NSMutableString *)finishUrlStr isFinished:(BOOL)finished isStreamed:(BOOL)streamed {
    if (finished) {
        unsigned long long size = 0;
    #if TARGET_OS_IPHONE
        ALAssetRepresentation *rep = self.asset.defaultRepresentation;
        if (self.asset) {
            size = (unsigned long long)rep.size;
            [finishUrlStr appendString:@"&forceunique=1"];
        }
        else {
    #endif
        size = [self.fileHandler fileSize].unsignedLongLongValue;
    #if TARGET_OS_IPHONE
    }
    #endif
        [finishUrlStr appendString:@"&respformat=json"];
        if (size) {
            [finishUrlStr appendFormat:@"&filehash=%@", [self calculateHashOfNextNBytes:[NSNumber numberWithUnsignedLong:SFAMaxBufferLength]]];
        }
        if ([self.uploadSpecificationRequest.details length] > 0) {
            [finishUrlStr appendFormat:@"&details=%@", [self.uploadSpecificationRequest.details escapeString]];
        }
        if ([self.uploadSpecificationRequest.title length] > 0) {
            [finishUrlStr appendFormat:@"&title=%@", [self.uploadSpecificationRequest.title escapeString]];
        }
        if ([finishUrlStr rangeOfString:@"fileSize"].location == NSNotFound) {
            [finishUrlStr appendFormat:@"&fileSize=%llu", size];
        }
        if (streamed) {
            [finishUrlStr appendString:@"&finish=1&isbatchlast=true"];
        }
    }
    
    if (streamed) {
        [finishUrlStr appendString:@"&fmt=json"];  // always want json for Streamed responses
    }
    return [NSURL URLWithString:finishUrlStr];
}

#pragma mark - CompositeTaskDelegate

- (NSURLRequest *)task:(SFAHttpTask *)task needsRequestForQuery:(id <SFAQuery> )query usingContextObject:(NSMutableDictionary **)contextObject {
    NSMutableURLRequest *request = nil;
    // Fetch data from context
    NSMutableDictionary *dict = (*contextObject) ? :[NSMutableDictionary dictionary];
    SFAuthenticationContext *authContext = [SFAUtils nilForNSNull:dict[SFAAuthContextKey]];
    
    SFAFilePart *part = [SFAUtils nilForNSNull:dict[SFAFilePartString]];
    if (part) {
        // File Part Upload Request
        [self fillFilePart:part];
        if (part.data.length <= 0) {
            [(SFACompositeUploaderTask *)task taskCompletedWithError:[SFAError errorWithMessage:SFAFileReadError type:SFAErrorTypeUploadError]];
        }
        else {
            request = [[NSMutableURLRequest alloc] initWithURL:[part composedUploadUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.httpTimeout];
            [request setHTTPMethod:SFAPost];
            [request setHTTPBody:part.data];
            [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)part.data.length] forHTTPHeaderField:SFAContentLength];
            // Added this header as png file wont get uploaded without this. There is no Content Type header in the request made by .Net SDK.
            [request setValue:@"application/octet-stream" forHTTPHeaderField:SFAContentType];
            // Allows an upload to continue where it left off in the event of an authentication error or other failure.
            [request setValue:@"100-continue" forHTTPHeaderField:@"Expect"];
            
            // Append parameters to URL for Streamed upload
            if ([self.uploadSpecification.Method isEqualToString:kSFUploadMethodStreamed]) {
                NSMutableString *finishUrlStr = [NSMutableString stringWithString:request.URL.absoluteString];
                request.URL = [self appendFinalParamsToUrlString:finishUrlStr isFinished:part.isLastPart isStreamed:YES];
            }
        }
    }
    else {
        // Finish Upload Request (Threaded Only)
        request = [[NSMutableURLRequest alloc] initWithURL:[self composedFinishUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.config.httpTimeout];
    }
    [request setValue:SFAApplicationJson forHTTPHeaderField:SFAccept];
    
    authContext = [self.client.authHandler prepareRequest:request authContext:authContext interactiveHandler:task.interactiveHandler];
    
    [dict setObject:[SFAUtils nullForNil:authContext] forKey:SFAAuthContextKey];
    
    *contextObject = dict;
    return [request copy];
}

- (void)compositeTask:(SFACompositeUploaderTask *)task finishedSpecificationTaskWithUploadSpec:(SFUploadSpecification *)val {
    if (!self.prepared) {
        self.uploadSpecification = val;
        [self checkResumeAsync];
        NSArray *fileParts = [self buildFilePartsForTask:task];
        task.uploaderTasks = [self filePartTasksForParts:fileParts];
        self.prepared = YES;
    }
}

@end
