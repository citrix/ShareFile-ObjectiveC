@interface SFAHttpHandleResponseReturnData ()

@end

@implementation SFAHttpHandleResponseReturnData

- (instancetype)initWithReturnValue:(id)returnVal andHttpHandleResponseAction:(SFAHttpHandleResponseAction)action {
    self = [super init];
    if (self) {
        _returnValue = returnVal;
        _responseAction = action;
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

@end
