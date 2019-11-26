#import <Foundation/Foundation.h>
#import "SFACompositeUploaderTask.h"

@interface SFACompositeUploaderTask ()

@property (nonatomic, strong) NSArray *uploaderTasks;

- (void)initializeProgressWithTotalBytes:(int64_t)totalBytes;
- (void)taskCompletedWithError:(SFAError *)error;

@end
