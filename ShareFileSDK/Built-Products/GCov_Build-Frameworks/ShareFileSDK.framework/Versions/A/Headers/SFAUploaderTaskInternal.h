#import <Foundation/Foundation.h>
#import "SFAUploaderTask.h"

typedef void (^SFAUploaderTaskProgressCallback)(SFATransferProgress *transferProgress);

@interface SFAUploaderTask ()

@property (nonatomic, copy) SFAUploaderTaskProgressCallback uploaderTaskProgressCallback;

@end
