#import "SFABackgroundUploadInitiationTask.h"

@protocol SFABackgroundUploadInitiationTaskDelegate <NSObject>

// Array of 2. 1st is session, 2nd is uploadTask.
- (NSArray *)backgroundUploadInitiationTask:(SFABackgroundUploadInitiationTask *)task didReceiveUploadSepcification:(SFUploadSpecification *)val;

@end

@interface SFABackgroundUploadInitiationTask ()

@property (nonatomic, strong) id <SFABackgroundUploadInitiationTaskDelegate> backgroundUploadInitiationTaskDelegate;
@property (nonatomic, weak) id <SFAURLSessionTaskDelegate> urlSessionTaskDelegate;

@end
