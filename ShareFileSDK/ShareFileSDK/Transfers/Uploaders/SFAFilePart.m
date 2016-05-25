#import "SFAFilePart.h"

@implementation SFAFilePart

- (NSURL *)composedUploadUrl {
    NSString *composedStr = [NSString stringWithFormat:@"%@&%@=%llu&%@=%llu&%@=%@", self.uploadUrl, SFAIndex, self.index, SFAByteOffset, self.offset, SFAHash, self.filePartHash];
    return [NSURL URLWithString:composedStr];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"index: %lld; offset: %lld; isLastPart: %@", self.index, self.offset, self.lastPart ? @"yes" : @"no"];
}

@end
