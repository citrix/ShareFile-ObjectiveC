#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, SFAEventHandlerResponseAction) {
    /**
     *  Enum for response action ignore.
     */
    SFAEventHandlerResponseActionIgnore = 0,
    /**
     *  Enum for response action fail with error.
     */
    SFAEventHandlerResponseActionFailWithError = 1,
    /**
     *  Enum for response action retry.
     */
    SFAEventHandlerResponseActionRetry = 2,
    /**
     *  Enum for response action redirect.
     */
    SFAEventHandlerResponseActionRedirect = 3
};
