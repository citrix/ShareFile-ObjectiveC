#import <Foundation/Foundation.h>
#import "SFAEventHandlerResponse.h"

@interface SFAResponse : NSObject

@property (nonatomic, strong) SFAEventHandlerResponse *action;
@property (nonatomic, strong) id value;

+ (instancetype)createAction:(SFAEventHandlerResponse *)action;
+ (SFAResponse *)createSuccess:(id)value;
+ (SFAResponse *)success;

@end
