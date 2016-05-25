@interface SFAFileInfo ()

@end

@implementation SFAFileInfo

@synthesize filePath = _filePath;

- (instancetype)initWithFilePath:(NSString *)path {
    self = [super init];
    if (self) {
        _filePath = path;
    }
    return self;
}

- (NSInputStream *)streamForRead {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSInputStream *inputStream = nil;
    if ([fileManager fileExistsAtPath:self.filePath]) {
        inputStream = [[NSInputStream alloc] initWithFileAtPath:self.filePath];
    }
    return inputStream;
}

- (NSOutputStream *)streamForWrite {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSOutputStream *stream = nil;
    if ([fileManager fileExistsAtPath:self.filePath]) {
        stream = [[NSOutputStream alloc] initToFileAtPath:self.filePath append:NO];
    }
    return stream;
}

- (NSFileHandle *)fileHandleForReading {
    return [NSFileHandle fileHandleForReadingAtPath:self.filePath];
}

- (NSFileHandle *)fileHandleForWritingCreateIfNeeded:(BOOL)createIfNeeded {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (createIfNeeded) {
        [fileManager createFileAtPath:self.filePath contents:nil attributes:nil];
    }
    
    return [NSFileHandle fileHandleForWritingAtPath:self.filePath];
}

- (NSDictionary *)fileAttributes {
    return [[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:NULL];
}

- (NSNumber *)fileSize {
    return [[self fileAttributes] objectForKey:NSFileSize];
}

@end
