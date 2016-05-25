#import "SFItemInfo.h"

@interface SFItemInfo (sfapi)

/**
 *  Check if basic permissions (upload/download/delete etc) have been filled for this object.
 *
 *  @return YES if any of the standard permissions are filled.
 */
- (BOOL)areBasicPermissionsFilled;

@end
