@interface SFAUploadSpecificationRequest ()

@property (nonatomic) NSString *responseFormat;

@end

@implementation SFAUploadSpecificationRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        self.responseFormat = SFAJson;
        self.fileSize = 0;
        self.tool = SFAApiV3;
        self.method = SFAUploadMethodThreaded;
        self.threadCount = 1;
        self.raw = YES;
    }
    return self;
}

- (NSString *)title {
    return [_title length] == 0 ? self.fileName : _title;
}

- (NSString *)stringfromBool:(BOOL)boolVal {
    return boolVal ? @"true" : @"false";
}

@end
