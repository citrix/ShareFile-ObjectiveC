@implementation SFARangeRequest

@end

@implementation SFADownloaderConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        self.rangeRequest = nil;
    }
    return self;
}

+ (instancetype)defaultDownloadConfig {
    return [[[self class] alloc] init];
}

@end
