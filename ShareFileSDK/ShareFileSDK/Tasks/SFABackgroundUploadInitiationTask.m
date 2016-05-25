#import "SFABackgroundUploadInitiationTask.h"
#import "SFABackgroundUploadInitiationTaskInternal.h"
#import "SFABaseTaskProtected.h"
#import "SFAHttpTaskProtected.h"
#import "SFABackgroundUploadInitiationResponse.h"

@implementation SFABackgroundUploadInitiationTask

- (void)didMarkFinishedWithValue:(id)retVal {
    // This method is only called after task is marked finished. Either as result of direct HTTP response or completion of redirection task.
    // Only one thread can get to this point and only once in the lifetime of Task.
    // NOTE: In our case the 'if' block is only executed by root level task because we do not set backgroundUploadInitiationTaskDelegate for
    // redirection tasks.
    // Alternate 1) would be to override the needsRedirectionTask and set backgroundUploadInitiationTaskDelegate and urlSessionTaskDelegate
    // of the new task(redirection task). Since user only interacts with root level task it is better for only root level task
    // to make and resume URL Session Upload Task, since then we do not need to worry about need of cancelling the URL Session Task if root task
    // was cancelled in-between.
    // Alternate 2) Make redirection tasks of type SFAHttpTask. But SFABackgroundUploadInitiationTask is same as SFAHttpTask without backgroundUploadInitiationTaskDelegate
    // Making redirection task of type:SFAHttpTask would have required copy/paste code. Which we avoided here.
    // Hence for redirection tasks backgroundUploadInitiationTaskDelegate will not be set and only root level task will be able to intiate URL Session Task.
    if (self.backgroundUploadInitiationTaskDelegate && !self.isCancelled && [retVal isKindOfClass:[SFUploadSpecification class]]) {
        NSArray *returnValues = [self.backgroundUploadInitiationTaskDelegate backgroundUploadInitiationTask:self didReceiveUploadSepcification:retVal];
        NSURLSession *session = nil;
        NSURLSessionUploadTask *uploaderTask = nil;
        if (returnValues) {
            session = returnValues[0];
            uploaderTask = returnValues[1];
        }
        // Start Uploader in background.
        [uploaderTask resume];
        SFABackgroundUploadInitiationResponse *response = [SFABackgroundUploadInitiationResponse new];
        response.uploadSpecification = retVal;
        response.uploadTask = uploaderTask;
        response.session = session;
        retVal = response;
    }
    [super didMarkFinishedWithValue:retVal];
}

@end
