#import "SFABackgroundSessionManager.h"

@interface SFABackgroundSessionManager ()

@property (strong, nonatomic, readwrite) NSMutableDictionary *completionHandlers;
@property (strong, nonatomic, readwrite) NSMutableDictionary *allTaskSpecificDelegates;

- (void)setBackgroundSession:(NSURLSession *)backgroundSession;
- (void)notifiyNewTaskForURLSession:(NSURLSession *)session task:(NSURLSessionTask *)task newTask:(NSURLSessionTask *)newTask;

@end
