#import "SFItemInfo+sfapi.h"

@implementation SFItemInfo (sfapi)

- (BOOL)areBasicPermissionsFilled {
    if (self.CanSend ||
        self.CanView ||
        self.CanUpload ||
        self.CanAddNode ||
        self.CanDownload ||
        self.CanAddFolder ||
        self.CanDeleteChildItems ||
        self.CanDeleteCurrentItem) {
        return YES;
    }
    else {
        return NO;
    }
}

@end
