#import <Foundation/Foundation.h>
#import "SFAEventHandlerResponse.h"

/**
 *  SFAChangeDomainCallback callback is fired when domain change event is reported to SFAClient. This callback is a way of SDK to delegate decision making to API user.
 *
 * `request`: NSURLRequest for which change domain event occured.
 *
 * `redirect`: SFIRedirection object representing the redirection.
 *
 * Returns object of SFAEventHandlerResponse.
 */
typedef SFAEventHandlerResponse * (^SFAChangeDomainCallback)(NSURLRequest *request, SFIRedirection *redirect);
