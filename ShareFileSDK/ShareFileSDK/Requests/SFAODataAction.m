@implementation SFAODataAction

- (instancetype)init {
    self = [super init];
    if (self) {
        self.parameters = [[SFAODataParameterCollection alloc] init];
    }
    return self;
}

@end
