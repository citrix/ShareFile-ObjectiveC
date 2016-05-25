#import "SFAHttpResponseActionAsyncCallback.h"

@interface SFAHttpResponseActionAsyncCallback ()

@property (nonatomic, copy) void (^asyncBlock)(SFAHttpResponseAsyncCallbackBlock callbackBlock);

@end

@implementation SFAHttpResponseActionAsyncCallback

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (instancetype)initWithAsyncBlock:(void (^)(SFAHttpResponseAsyncCallbackBlock callbackBlock))asyncBlock {
    self = [super init];
    if (self) {
        _asyncBlock = asyncBlock;
    }
    return self;
}

- (void)asyncCallWithCompleteBlock:(SFAHttpResponseAsyncCallbackBlock)completeBlock {
    if (_asyncBlock) {
        _asyncBlock(completeBlock);
    }
}

@end
