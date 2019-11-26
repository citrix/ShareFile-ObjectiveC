#import <Foundation/Foundation.h>

@class SFAHttpHandleResponseReturnData;

typedef NS_ENUM (NSInteger, SFAHttpHandleResponseAction) {
    SFAHttpHandleResponseActionComplete = 0,
    SFAHttpHandleResponseActionReExecute = 1,
    SFAHttpHandleResponseActionAsyncCallback = 2
};

@interface SFAHttpHandleResponseReturnData : NSObject

@property (nonatomic, strong, readonly) id returnValue;
@property (nonatomic, readonly) SFAHttpHandleResponseAction responseAction;

- (instancetype)initWithReturnValue:(id)returnVal andHttpHandleResponseAction:(SFAHttpHandleResponseAction)action;

@end
