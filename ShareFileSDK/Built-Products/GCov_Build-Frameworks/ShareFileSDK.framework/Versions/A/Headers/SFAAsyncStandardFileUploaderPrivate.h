#import "SFAAsyncStandardFileUploader.h"
#import "SFACompositeUploaderTask.h"

@interface SFAAsyncStandardFileUploader () <NSStreamDelegate, SFACompositeTaskDelegate>

@property (nonatomic, strong, readwrite) NSData *bodyPrefixData;
@property (nonatomic, strong, readwrite) NSInputStream *fileStream;
@property (nonatomic, strong, readwrite) NSData *bodySuffixData;
@property (nonatomic, strong, readwrite) NSOutputStream *producerStream;
@property (nonatomic, strong, readwrite) NSInputStream *consumerStream;
@property (nonatomic, assign, readwrite) const uint8_t *buffer;
@property (nonatomic, assign, readwrite) uint8_t *bufferOnHeap;
@property (nonatomic, assign, readwrite) NSUInteger bufferOffset;
@property (nonatomic, assign, readwrite) NSUInteger bufferLimit;
@property (nonatomic) unsigned long long assetByteOffset;
@property (nonatomic) BOOL assetDataRead;
@property (nonatomic) unsigned long long bodyLength;
@property (nonatomic, strong) NSString *boundaryStr;
@property (nonatomic) BOOL defaultURLSessionTaskHTTPDelegate;

- (void)initializeBodyLengthForTask:(SFACompositeUploaderTask *)task;

@end
