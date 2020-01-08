#import <Foundation/Foundation.h>
#import "SFAEventHandlerResponseAction.h"
/**
   The SFAEventHandlerResponse class is used by Event Handler to let caller know what action to take.
 */
@interface SFAEventHandlerResponse : NSObject
/**
 *  SFAEventHandlerResponseAction enum value representing the action to be taken.
 */
@property (nonatomic) SFAEventHandlerResponseAction action;
/**
 *  SFIRedirection object.
 */
@property (nonatomic, strong) SFIRedirection *redirection;
/**
 *  Initializes SFAEventHandlerResponse with provided parameters.
 *
 *  @param redir SFIRedirection object.
 *
 *  @return Returns initialized SFAEventHandlerResponse object or nil if an object could not be created for some reason.
 */
+ (SFAEventHandlerResponse *)eventHandlerResponseWithRedirection:(SFIRedirection *)redir;
/**
 *  Initializes SFAEventHandlerResponse with provided paramters.
 *
 *  @param action SFAEventHandlerResponseAction enum value representing the action to be taken.
 *
 *  @return Returns initialized SFAEventHandlerResponse object or nil if an object could not be created for some reason.
 */
+ (SFAEventHandlerResponse *)eventHandlerResponseWithAction:(SFAEventHandlerResponseAction)action;
/**
 *  Initializes SFAEventHandlerResponse with action SFAEventHandlerResponseActionFailWithError
 *
 *  @return Returns initialized SFAEventHandlerResponse object or nil if an object could not be created for some reason.
 */
+ (SFAEventHandlerResponse *)failWithErrorEventResponseHandler;
/**
 *  Initializes SFAEventHandlerResponse with action SFAEventHandlerResponseActionIgnore
 *
 *  @return Returns initialized SFAEventHandlerResponse object or nil if an object could not be created for some reason.
 */
+ (SFAEventHandlerResponse *)ignoreEventResponseHandler;

@end
