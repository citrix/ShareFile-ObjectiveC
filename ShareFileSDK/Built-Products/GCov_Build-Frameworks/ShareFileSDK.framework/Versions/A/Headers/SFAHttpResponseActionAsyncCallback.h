#import <Foundation/Foundation.h>
#import "SFAHttpHandleResponseReturnData.h"

typedef void (^SFAHttpResponseAsyncCallbackBlock)(SFAHttpHandleResponseReturnData *asyncResponseReturnData);

/**
 *  SFAHttpResponseActionAsyncCallback is a response action that wraps a handling block for further work.
 *  The task that receives the action can call the handling block and supply its own callback block.
 */
@interface SFAHttpResponseActionAsyncCallback : NSObject

/**
 *  Initalize ReponseAction with a async work block
 *
 *  @param asyncBlock Work block to run when recipient of response object is ready to do async work
 *
 */
- (instancetype)initWithAsyncBlock:(void (^)(SFAHttpResponseAsyncCallbackBlock callbackBlock))asyncBlock;

/**
 *  Make async call, followed by the supplied completion block.
 *  The intent is to abstract away async work from tasks, allowing
 *  them to just consume the response to their callback block.
 *
 *  @param completeBlock <#completeBlock description#>
 */
- (void)asyncCallWithCompleteBlock:(SFAHttpResponseAsyncCallbackBlock)completeBlock;

@end
