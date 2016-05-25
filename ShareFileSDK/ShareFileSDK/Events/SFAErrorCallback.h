#import <Foundation/Foundation.h>
#import "SFAEventHandlerResponse.h"
#import "SFAHttpRequestResponseDataContainer.h"

/**
 *  SFAErrorCallback callback is fired when error in request event is reported to SFAClient. This callback is a way of SDK to delegate decision making to API user.
 *
 * `container`: SFAHttpRequestResponseDataContainer containing request and its response that finished with error.
 *
 * `retryCount`: Number representing number of retries for the request.
 *
 * Returns object of SFAEventHandlerResponse.
 */
typedef SFAEventHandlerResponse * (^SFAErrorCallback)(SFAHttpRequestResponseDataContainer *container, int retryCount);
