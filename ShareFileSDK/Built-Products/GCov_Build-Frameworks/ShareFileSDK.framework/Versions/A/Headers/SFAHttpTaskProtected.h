#import <Foundation/Foundation.h>
#import "SFAHttpTask.h"

@interface SFAHttpTask () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) id <SFAHttpTaskDelegate> delegate;
@property (nonatomic, strong) id <SFAQuery> query;
@property (nonatomic, strong) SFAClient *client;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSOperationQueue *delegateQueue;
@property (nonatomic, strong) SFAHttpTask *redirectionTask;
@property (nonatomic, strong) NSDictionary *redirectionTaskAdditionalDictionary;
// Progress
@property (nonatomic) unsigned long long transferSize;
@property (nonatomic) unsigned long long byteTransfered;

- (instancetype)initWithDelegate:(id <SFAHttpTaskDelegate> )delegate contextObject:(id)contextObject callbackQueue:(NSOperationQueue *)queue client:(SFAClient *)client;
- (void)handleCompletion;
- (void)notifyProgress;
- (void)notifyProgressWithTransferProgress:(SFATransferProgress *)transferProgress;
- (void)needsToReExecute;
- (instancetype)needsRedirectionTask;

@end
