const NSUInteger SFADefaultPartSize = 4 * 1024 * 1024;
const NSUInteger SFADefaultNumberOfThreads = 4;
const NSTimeInterval SFADefaultHttpTimeout = 60000;
const NSUInteger SFAMaxNumberOfThreads = 4; // Should be <= NSIntegerMax

@interface SFAFileUploaderConfig ()

@end

@implementation SFAFileUploaderConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.numberOfThreads = SFADefaultNumberOfThreads;
        self.partSize = SFADefaultPartSize;
        self.httpTimeout = SFADefaultHttpTimeout;
    }
    return self;
}

- (void)setPartSize:(NSUInteger)partSize {
    if (partSize > 0) {
        _partSize = partSize;
    }
    else {
        NSAssert(NO, @"min part size value can be 1");
    }
}

- (void)setNumberOfThreads:(NSUInteger)numberOfThreads {
    if (numberOfThreads > 0 && numberOfThreads <= SFAMaxNumberOfThreads) {
        _numberOfThreads = numberOfThreads;
    }
    else {
        NSAssert(NO, @"numberOfThreads range:[1,SFAMaxNumberOfThreads]");
    }
}

@end
