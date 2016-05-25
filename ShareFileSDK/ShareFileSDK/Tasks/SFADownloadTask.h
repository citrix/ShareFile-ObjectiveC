#import <Foundation/Foundation.h>
#import "SFATransferTask.h"
#import "SFAHttpTask.h"
#import "SFADownloadTaskExternal.h"

@interface SFADownloadTask : SFAHttpTask <SFADownloadTask>

- (instancetype)initWithQuery:(id <SFAQuery> )query fileHandle:(NSFileHandle *)handle transferMetaData:(NSDictionary *)transferMetaData transferSize:(unsigned long long)transferSize delegate:(id <SFAHttpTaskDelegate> )delegate contextObject:(id)contextObject callbackQueue:(NSOperationQueue *)queue client:(SFAClient *)client;

@end
