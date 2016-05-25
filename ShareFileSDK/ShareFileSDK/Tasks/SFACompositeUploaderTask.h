#import <Foundation/Foundation.h>
#import "SFAHttpTask.h"
#import "SFABaseTask.h"

@class SFACompositeUploaderTask;

@protocol SFACompositeTaskDelegate

- (void)compositeTask:(SFACompositeUploaderTask *)task finishedSpecificationTaskWithUploadSpec:(SFUploadSpecification *)val;

@end

@interface SFACompositeUploaderTask : SFABaseTask <SFATransferTask>

- (instancetype)initWithUploadSpecificationTask:(SFAHttpTask *)uploadSpecificationTask concurrentExecution:(NSUInteger)concurrentExecution uploaderTasks:(NSArray *)uploaderTasks finishTask:(SFAHttpTask *)finishTask delegate:(id <SFACompositeTaskDelegate> )delegate transferMetadata:(NSDictionary *)transferMetadata callbackQueue:(NSOperationQueue *)queue client:(SFAClient *)client uploadMethod:(SFAUploadMethod)method;

@end
