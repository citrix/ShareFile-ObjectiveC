@implementation SFATransferProgress

- (id)copyWithZone:(NSZone *)zone {
    SFATransferProgress *copy = [[self.class alloc] init];
    copy.bytesTransferred = self.bytesTransferred;
    copy.bytesRemaining = self.bytesRemaining;
    copy.totalBytes = self.totalBytes;
    copy.transferId = self.transferId;
    copy.complete = self.complete;
    copy.transferMetadata = [self.transferMetadata copy];
    return copy;
}

@end
