@implementation SFIODataEntityBase

- (instancetype)initWithClient:(id <SFAClient> )client {
    self = [super init];
    if (self) {
        self.client = client;
        NSString *name = NSStringFromClass([self class]);
        NSRange range = [name rangeOfString:@"Entity"];
        if (range.location != NSNotFound) {
            if (range.location > 0) {
                name = [name substringToIndex:range.location];
            }
            else {
                name = @"";
            }
        }
        range = [name rangeOfString:@"SFI"];
        if (range.location != NSNotFound) {
            if (range.location == 0) {
                name = [name substringFromIndex:range.length];
            }
            else {
                name = @"";
            }
        }
        self.entity = name;
    }
    return self;
}

- (instancetype)init {
    return [self initWithClient:nil];
}

@end
