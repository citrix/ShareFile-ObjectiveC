@implementation SFABackgroundSessionConfiguration

- (instancetype)init {
    if (self = [super init]) {
        self.identifier = @"SharefileBackgroundSession";
        self.sharedContainerIdentifier = @"SharefileSharedContainer";
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    SFABackgroundSessionConfiguration *copy = [self.class alloc];
    copy.identifier = [self.identifier copy];
    copy.sharedContainerIdentifier = [self.sharedContainerIdentifier copy];
    return copy;
}

@end
