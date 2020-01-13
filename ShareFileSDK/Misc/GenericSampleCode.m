#import "GenericSampleCode.h"
#if TARGET_OS_IPHONE

#import "iOSSample/AppDelegate.h"
#import "ViewController.h"
#endif

#import "SFASDKAuthHandler.h"

@interface GenericSampleCode () <SFAURLSessionTaskDelegate>

@property (nonatomic) BOOL ranSampleOnce;
@property (strong, nonatomic) id <SFATransferTask> task;
@property (strong, nonatomic) SFIFolder *folder;
@property (strong, nonatomic) NSDictionary *credDictionary;
@property (strong, nonatomic) SFIItem *backgroundDownloadItem;
@property (strong, atomic) NSString *backgroundDownloadFilePath;

#if TARGET_OS_IPHONE
@property (strong, nonatomic) ALAssetsLibrary *lib;
@property (strong, nonatomic) ALAsset *asset;
#endif

@end

@implementation GenericSampleCode

- (instancetype)init {
    self = [super init];
    if (self) {
        [self makeClient];
        // Un-comment to test notifications
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationTest:) name:kSFATaskCompleteNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationTest:) name:kSFATaskCancelNotification object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationTest:) name:kSFATransferTaskProgressNotification object:nil];
    }
    return self;
}

- (void)loadCredentials {
#warning Credentials including client_id and client_secret must be entered into file 'ShareFileSDKSampleCred.plist'
    self.credDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ShareFileSDKSampleCred" ofType:@"plist"]];
}

- (void)makeClient {
    [self loadCredentials];
    // Make Client
    NSString *clientId = self.credDictionary[@"clientId"];
    NSString *clientSecret = self.credDictionary[@"clientSecret"];
    // Config
    SFAConfiguration *config = [SFAConfiguration defaultConfiguration];
    config.clientId = clientId;
    config.clientSecret = clientSecret;
    // Client Init
    SFAClient *client = [[SFAClient alloc] initWithBaseUrl:@"https://secure.sf-api.com/sf/v3/" andConfiguration:config];
    // Assign Client
    self.client = client;
}

#if TARGET_OS_IPHONE

static BOOL useBackgroundUploadDownload = NO;

#endif

- (void)runSample {
    if (self.ranSampleOnce) {
        return;
    }
    self.ranSampleOnce = YES;
    //
    SFAClient *client = self.client;
    // Make OAuth Service
    SFAOAuthService *oauthService = [[SFAOAuthService alloc] initWithSFAClient:self.client clientId:self.credDictionary[@"clientId"] clientSecret:self.credDictionary[@"clientSecret"]];
    // Auth Handler
    SFASDKAuthHandler *baseAuthHandler = [[SFASDKAuthHandler alloc] initWithOAuthService:oauthService];
    client.authHandler = baseAuthHandler;
    // Make Authentication
    SFApiQuery *query = [oauthService passwordGrantRequestQueryForUsername:self.credDictionary[@"email"] password:self.credDictionary[@"password"] subdomain:self.credDictionary[@"subdomain"] applicationControlPlane:@"sharefile.com"];
    //
    self.task = [client executeQueryAsync:query
                            callbackQueue:nil
                       completionCallback: ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
                     NSLog(@"Callback Queue is:%@", [NSOperationQueue currentQueue]);
                     self.task = nil;
                     if (error) {
                         NSLog(@"Error Is:%@", error);
                     }
                     else if ([returnValue isKindOfClass:[SFAOAuthToken class]]) {
                         NSLog(@"*********************OAuth Token "
                               "Received**********************************");
                         SFAOAuthToken *token = (SFAOAuthToken *)returnValue;
                         NSLog(@"token:%@", token.accessToken);
                         NSLog(@"refresh:%@", token.refreshToken);
                         NSLog(@"token type:%@", token.tokenType);
                         NSLog(@"*************************************************************"
                               "**************");
                               
                         self.client.baseUrl = [token getUrl];
                         
                         SFAOAuth2Credential *cred = [[SFAOAuth2Credential alloc] initWithOAuthToken:token];
                         [baseAuthHandler.credentialStore addCredential:cred forUrl:self.client.baseUrl authType:nil];
                         
                         [self createSession];
                     }
                     else {
                         NSLog(@"Unexpected return value type.");
                     }
                 } cancelCallback:nil];
    //
    NSLog(@"Async call is in-progress......");
}

- (void)createSession {
    SFApiQuery *query = [[self.client.sessions loginWithAuthmethod:nil andAuthcomparison:nil] expandProperty:@"Principal"];
    
    self.task = [self.client executeQueryAsync:query
                                 callbackQueue:nil
                            completionCallback: ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
                     self.task = nil;
                     if (error) {
                         NSLog(@"Error Is:%@", error);
                     }
                     else if ([returnValue isKindOfClass:[SFISession class]]) {
                         NSLog(@"*********************Session "
                               "Started**********************************");
                         NSLog(@"Authenticated as:%@", ((SFISession *)returnValue).Principal.Email);
                         NSLog(@"***************************************************************"
                               "*******");
                         [self defaultFolder];
                     }
                     else {
                         NSLog(@"Unexpected return value type.");
                     }
                 } cancelCallback:nil];
}

- (void)defaultFolder {
    SFApiQuery *query = [[self.client.items get] expandProperty:@"Children"];
    self.task = [self.client executeQueryAsync:query
                                 callbackQueue:nil
                            completionCallback: ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
                     self.task = nil;
                     if (error) {
                         NSLog(@"Error Is:%@", error);
                     }
                     else if ([returnValue isKindOfClass:[SFIFolder class]]) {
                         SFIFolder *folder = (SFIFolder *)returnValue;
                         NSLog(@"*********************Folder "
                               "Info**********************************");
                         NSLog(@"FileCount:%@", folder.FileCount);
                         NSLog(@"Info.IsSharedFolder:%@", folder.Info.IsSharedFolder);
                         NSLog(@"Info.IsAHomeFolder:%@", folder.Info.IsAHomeFolder);
                         for (id child in folder.Children) {
                             if ([child isKindOfClass:[SFIFile class]]) {
                                 NSLog(@"***************File Info*********************");
                                 SFIFile *file = (SFIFile *)child;
                                 NSLog(@"File's FileName:%@", file.FileName);
                                 NSLog(@"File's Name:%@", file.Name);
                                 NSLog(@"File's Hash:%@", file.Hash);
                                 NSLog(@"*********************************************");
                             }
                             else if ([child isKindOfClass:[SFIFolder class]]) {
                                 SFIFolder *childFolder = child;
                                 NSLog(@"Child Folder File Count:%@", childFolder.FileCount);
                                 NSLog(@"Child Folder Info.IsSharedFolder:%@", childFolder.Info.IsSharedFolder);
                                 NSLog(@"Child Folder Info.IsAHomeFolder:%@", childFolder.Info.IsAHomeFolder);
                             }
                         }
                         NSLog(@"***************************************************************"
                               "*******");
                         [self createFolder:folder];
                     }
                     else {
                         NSLog(@"Unexpected return value type.");
                     }
                 } cancelCallback:nil];
}

- (void)createFolder:(SFIFolder *)parentFolder {
    SFIFolder *newFolder = [[SFIFolder alloc] init];
    newFolder.Name = @"Sample Folder";
    newFolder.Description = @"Created by SF Client SDK";
    
    SFApiQuery *query = [self.client.items createFolderWithParentUrl:parentFolder.url folder:newFolder overwrite:@YES andPassthrough:@NO];
    self.task = [self.client executeQueryAsync:query
                                 callbackQueue:nil
                            completionCallback: ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
                     self.task = nil;
                     if (error) {
                         NSLog(@"Error Is:%@", error);
                     }
                     else if ([returnValue isKindOfClass:[SFIFolder class]]) {
                         SFIFolder *folder = (SFIFolder *)returnValue;
                         self.folder = folder;
                         NSLog(@"*********************Create Folder "
                               "Info**********************************");
                         NSLog(@"FileCount:%@", folder.FileCount);
                         NSLog(@"*********************Create Folder "
                               "Info**********************************");
                         [self uploadToFolder:folder useAsset:NO];
                     }
                     else {
                         NSLog(@"Unexpected return value type.");
                     }
                 } cancelCallback:nil];
}

- (void)uploadToFolder:(SFIFolder *)destinationFolder useAsset:(BOOL)useAsset {
#if TARGET_OS_IPHONE
    if (useAsset) {
        self.lib = [[ALAssetsLibrary alloc] init];
        [self.lib enumerateGroupsWithTypes:ALAssetsGroupAll
                                usingBlock: ^(ALAssetsGroup *group, BOOL *stop1) {
             if (!group) {
                 return;
             }
             else if (group.numberOfAssets > 0) {
                 *stop1 = YES;
                 [group enumerateAssetsUsingBlock: ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                      if (result && index != NSNotFound && !*stop && result.defaultRepresentation.size > 0 && !self.asset) {
                          NSLog(@"Asset:%@, At Index:%lu, Stop:%d, Size:%lld", result, (unsigned long)index, *stop, result.defaultRepresentation.size);
                          *stop = YES;
                          self.asset = result;
                          [self uploadToFolder:destinationFolder];
                      }
                  }];
             }
         }
                              failureBlock: ^(NSError *error) { NSLog(@"Error:%@", error); }];
    }
    else {
#endif
    [self uploadToFolder:destinationFolder];
#if TARGET_OS_IPHONE
}

#endif
}

- (void)uploadToFolder:(SFIFolder *)destinationFolder {
    SFAUploadSpecificationRequest *request = nil;
    NSString *path = @"";
    SFAUploadMethod method = SFAUploadMethodStandard;
    BOOL canUseBackgroundUpload = NO;
#if TARGET_OS_IPHONE
    if (self.asset) {
        if (useBackgroundUploadDownload) {
            NSLog(@"ALAsset backgroud upload is not supported.");
        }
        request = [self.asset uploadSpecificationRequestWithFileName:nil parentFolderURL:destinationFolder.url description:@"ALAsset Upload" shouldOverwrite:YES uploadMethod:method];
    }
    else {
        if (useBackgroundUploadDownload) {
            if (method != SFAUploadMethodStandard) {
                NSLog(@"Backgroud upload is only supported for Standard Upload Method.");
            }
            else {
                canUseBackgroundUpload = YES;
            }
        }
#endif
    NSString *filename = @"Sample";
    NSString *extension = @"png";
    path = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    NSString *fullFileName = [NSString stringWithFormat:@"%@.%@", filename, extension];
    request = [SFAUploadSpecificationRequest new];
    request.fileName = fullFileName;
    request.title = request.fileName;
    request.details = @"Sample Details";
    request.method = method;
    request.overwrite = YES;
    request.destinationURI = destinationFolder.url;
#if TARGET_OS_IPHONE
}

#endif
    // Async Uploader Sample
    SFAAsyncUploaderBase *uploaderBase = nil;
#if ShareFile
#if TARGET_OS_IPHONE
    if (self.asset) {
        uploaderBase = [self.client asyncFileUploaderWithUploadSpecificationRequest:request asset:self.asset fileUploaderConfig:nil expirationDays:-1];
    }
    else {
#endif
    uploaderBase = [self.client asyncFileUploaderWithUploadSpecificationRequest:request filePath:path fileUploaderConfig:nil expirationDays:-1];
#if TARGET_OS_IPHONE
}
#endif

#else
#if TARGET_OS_IPHONE
    if (self.asset) {
        uploaderBase = [self.client asyncFileUploaderWithUploadSpecificationRequest:request asset:self.asset fileUploaderConfig:nil];
    }
    else {
#endif
    uploaderBase = [self.client asyncFileUploaderWithUploadSpecificationRequest:request filePath:path fileUploaderConfig:nil];
#if TARGET_OS_IPHONE
}
#endif
#endif

    if (canUseBackgroundUpload) {
        self.task = [uploaderBase uploadBackgroundAsyncWithTaskDelegate:self
                                                          callbackQueue:nil
                                                     completionCallback: ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
                         if (error) {
                             NSLog(@"Error Is:%@", error);
                         }
                         else if ([returnValue isKindOfClass:[SFABackgroundUploadInitiationResponse class]]) {
                             SFABackgroundUploadInitiationResponse *backgroundUploadInitiationResponse = (SFABackgroundUploadInitiationResponse *)returnValue;
                             NSLog(@"*********************Background Upload "
                                   "Initiation Response**********************************");
                             if (backgroundUploadInitiationResponse.uploadTask) {
                                 NSLog(@"Background Upload Started in Session:%@ and Task:%ld", backgroundUploadInitiationResponse.session.configuration.identifier, (unsigned long)backgroundUploadInitiationResponse.uploadTask.taskIdentifier);
                                 NSLog(@"Background Upload, UploadSpecification:%@", backgroundUploadInitiationResponse.uploadSpecification);
                             }
                             else {
                                 NSLog(@"Unable to start background upload.");
                             }
                         }
                         else {
                             NSLog(@"Unexpected return value type.");
                         }
                     } cancelCallback:nil];
    }
    else {
        self.task = [uploaderBase uploadAsyncWithCallbackQueue:nil
                                            completionCallback: ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
                         self.task = nil;
#if TARGET_OS_IPHONE
                         self.asset = nil;
                         self.lib = nil;
#endif
                         [self handleUploadResponseWithReturnValue:returnValue error:error];
                     }
                                                cancelCallback:nil
                                              progressCallback: ^(SFATransferProgress *transferProgress) {
                         NSLog(@"*********************Upload "
                               "Progress**********************************");
                         NSLog(@"Bytes Transfered: %llu", transferProgress.bytesTransferred);
                         NSLog(@"Bytes Remaining: %llu", transferProgress.bytesRemaining);
                         NSLog(@"Total Bytes: %llu", transferProgress.totalBytes);
                         NSLog(@"Complete: %i", transferProgress.complete);
                     }];
    }
}

- (void)handleUploadResponseWithReturnValue:(id)returnValue error:(SFAError *)error {
    if (error) {
        NSLog(@"Error Is:%@", error);
    }
    else if ([returnValue isKindOfClass:[SFAUploadResponse class]]) {
        SFAUploadResponse *uploadResponse = (SFAUploadResponse *)returnValue;
        NSLog(@"*********************Upload "
              "Response**********************************");
        for (SFAUploadFile *file in uploadResponse) {
            NSLog(@"File Name: %@", file.filename);
            NSLog(@"Display Name: %@", file.displayName);
            NSLog(@"Id: %@", file.idString);
            NSLog(@"Hash: %@", file.fileHash);
            NSLog(@"Size: %llu", file.size);
            NSLog(@"Upload Id: %@", file.uploadId);
        }
        NSLog(@"*********************Upload "
              "Response**********************************");
        [self checkUploadFile:[[uploadResponse objectAtIndex:0] idString]];
    }
    else {
        NSLog(@"Unexpected return value type.");
    }
}

- (void)checkUploadFile:(NSString *)uploadId {
    NSURL *url = [self.client.items urlWithAlias:uploadId];
    
    SFApiQuery *query = [self.client.items getWithUrl:url andIncludeDeleted:@NO];
    self.task = [self.client executeQueryAsync:query
                                 callbackQueue:nil
                            completionCallback: ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
                     self.task = nil;
                     if (error) {
                         NSLog(@"Error Is:%@", error);
                     }
                     else if ([returnValue isKindOfClass:[SFIFile class]]) {
                         SFIFile *file = (SFIFile *)returnValue;
                         NSLog(@"*********************File "
                               "Info**********************************");
                         NSLog(@"File Id:%@", file.Id);
                         NSLog(@"Uploaded File Name:%@", file.Name);
                         NSLog(@"*********************File "
                               "Info**********************************");
                         [self downloadItem:file];
                         // Un-comment below to check folder download.
                         //[self downloadItem:self.folder];
                     }
                     else {
                         NSLog(@"Unexpected return value type.");
                     }
                 } cancelCallback:nil];
}

- (void)downloadItem:(SFIItem *)downloadItem {
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [dirPath stringByAppendingPathComponent:downloadItem.Name];
    if ([downloadItem isKindOfClass:[SFIFolder class]]) {
        filePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", downloadItem.Name]];
    }
    SFAFileInfo *info = [[SFAFileInfo alloc] initWithFilePath:filePath];
    SFAAsyncFileDownloader *fileDownloader = [self.client asyncFileDownloaderForItem:downloadItem withDownloaderConfig:nil];
#if TARGET_OS_IPHONE
    if (useBackgroundUploadDownload) {
        self.backgroundDownloadItem = downloadItem;
        self.backgroundDownloadFilePath = filePath;
        NSURLSessionDownloadTask *downloadTask = [fileDownloader downloadBackgroundAsyncWithTaskDelegate:self];
        NSLog(@"Background Download Started, Task:%ld", (unsigned long)downloadTask.taskIdentifier);
    }
    else {
#endif
    NSFileHandle *handle = [info fileHandleForWritingCreateIfNeeded:YES];
    
    self.task = [fileDownloader downloadAsyncToFileHandle:handle
                                     withTransferMetadata:nil
                                            callbackQueue:nil
                                       completionCallback: ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
                     self.task = nil;
                     [self handleDownloadResponseWithFilePath:filePath downloadItem:downloadItem error:error];
                 }
                                           cancelCallback:nil
                                         progressCallback: ^(SFATransferProgress *transferProgress) { NSLog(@"Download Progress:%f%%", (((float)transferProgress.bytesTransferred) / transferProgress.totalBytes) * 100); }
                                     dataReceivedCallback: ^NSData * (NSData *receivedData) {
                     NSLog(@"Data Received Callback, data of length:%lu", (unsigned long)receivedData.length);
                     return receivedData;
                 }];
#if TARGET_OS_IPHONE
}

#endif
}

- (void)handleDownloadResponseWithFilePath:(id)filePath downloadItem:(SFIItem *)downloadItem error:(SFAError *)error {
    if (error) {
        NSLog(@"Error Is:%@", error);
    }
    else {
        NSLog(@"*********************File Download*********************");
        NSLog(@"Download Complete:%@", downloadItem.Name);
        NSLog(@"At Path:%@", filePath);
        NSLog(@"*********************File Download*********************");
#if TARGET_OS_IPHONE
        NSString *imageFilePath = nil;
        if ([filePath isKindOfClass:[NSURL class]]) {
            imageFilePath = [[NSString alloc] initWithUTF8String:((NSURL *)filePath).fileSystemRepresentation];
        }
        else if ([filePath isKindOfClass:[NSString class]]) {
            imageFilePath = filePath;
        }
        if (imageFilePath) {
            id <UIApplicationDelegate> appDelegate = [UIApplication sharedApplication].delegate;
            if ([appDelegate isKindOfClass:[AppDelegate class]]) {
                UIViewController *uivc = ((AppDelegate *)appDelegate).window.rootViewController;
                if ([uivc isKindOfClass:[ViewController class]]) {
                    ViewController *vc = (ViewController *)uivc;
                    vc.imageView.image = [UIImage imageWithContentsOfFile:imageFilePath];
                }
            }
        }
#endif
        [self shareViaEmailItem:downloadItem];
    }
}

- (void)shareViaLinkItem:(SFIItem *)itemToShare {
    SFIShare *share = [[SFIShare alloc] init];
    share.Items = [[NSMutableArray alloc] initWithObjects:itemToShare, nil];
    SFApiQuery *query = [self.client.shares createWithShare:share andNotify:@1];
    self.task = [self.client executeQueryAsync:query
                                 callbackQueue:nil
                            completionCallback: ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
                     self.task = nil;
                     if (error) {
                         NSLog(@"Error Is:%@", error);
                     }
                     else if ([returnValue isKindOfClass:[SFIShare class]]) {
                         NSLog(@"*********************Share Link*********************");
                         SFIShare *share = (SFIShare *)returnValue;
                         NSLog(@"Share Link: %@", share.Uri);
                         NSLog(@"****************************************************");
                         // Un-comment to test cancel
                         //[self testCancel];
                     }
                     else {
                         NSLog(@"Unexpected return value type.");
                     }
                 } cancelCallback:nil];
}

- (void)shareViaEmailItem:(SFIItem *)itemToShare {
    SFIShareSendParams *sendParams = [[SFIShareSendParams alloc] init];
    sendParams.Emails = [[NSMutableArray alloc] initWithObjects:self.credDictionary[@"shareEmail"], nil];
    sendParams.Items = [[NSMutableArray alloc] initWithObjects:itemToShare.Id, nil];
    sendParams.Subject = @"Sample SDK Share";
    // Allow unlimited downloads
    sendParams.MaxDownloads = @ - 1;
    SFApiQuery *query = [self.client.shares createSendWithParameters:sendParams];
    self.task = [self.client executeQueryAsync:query
                                 callbackQueue:nil
                            completionCallback: ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
                     self.task = nil;
                     if (error) {
                         NSLog(@"Error Is:%@", error);
                     }
                     else {
                         NSLog(@"*********************Share Via Email*********************");
                         for (NSString *str in sendParams.Emails) {
                             NSLog(@"Email Sent To: %@", str);
                         }
                         NSLog(@"****************************************************");
                         [self shareViaLinkItem:itemToShare];
                     }
                 }];
}

- (void)testCancel {
    SFApiQuery *query = [[self.client.items get] expandProperty:@"Children"];
    self.task = [self.client executeQueryAsync:query
                                 callbackQueue:nil
                            completionCallback: ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
                     // Un-comment to test KVO
                     //[(NSObject *)self.task removeObserver:self forKeyPath:@"isCancelled"];
                     //[(NSObject *)self.task removeObserver:self forKeyPath:@"isExecuting"];
                     //[(NSObject *)self.task removeObserver:self forKeyPath:@"isFinished"];
                     // self.task = nil;
                     NSLog(@"Complete");
                 }
                                cancelCallback: ^{
                     // Un-comment to test KVO
                     //[(NSObject *)self.task removeObserver:self forKeyPath:@"isCancelled"];
                     //[(NSObject *)self.task removeObserver:self forKeyPath:@"isExecuting"];
                     //[(NSObject *)self.task removeObserver:self forKeyPath:@"isFinished"];
                     // self.task = nil;
                     NSLog(@"Cancelled");
                 }];
    if ([self.task isKindOfClass:[NSObject class]]) {
        // Un-comment to test KVO
        // NSObject *obj = self.task;
        //[obj addObserver:self forKeyPath:@"isCancelled" options:NSKeyValueObservingOptionNew context:NULL];
        //[obj addObserver:self forKeyPath:@"isExecuting" options:NSKeyValueObservingOptionNew context:NULL];
        //[obj addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:NULL];
    }
    [self.task cancel];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"\nKVO\nKeyPath:%@\nDictionary:%@", keyPath, change);
}

- (void)notificationTest:(NSNotification *)notification {
    NSLog(@"*****Notification*****\nObj:%@\nNotif-Name:%@\nDict:%@", notification.object, notification.name, notification.userInfo);
}

#pragma mark - SFAURLSessionTaskDelegate
// NOTE: delegate functions may be called on any queue.

- (BOOL)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithReturnValue:(id)returnValue error:(SFAError *)error additionalInfo:(NSDictionary *)additionalInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Background Task in Session:%@ Task:%ld Completed!", session.configuration.identifier, (unsigned long)task.taskIdentifier);
        if ([task isKindOfClass:[NSURLSessionUploadTask class]]) {
            [self handleUploadResponseWithReturnValue:returnValue error:error];
        }
        else if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
            [self handleDownloadResponseWithFilePath:returnValue downloadItem:self.backgroundDownloadItem error:error];
            self.backgroundDownloadItem = nil;
            self.backgroundDownloadFilePath = nil;
        }
        else {
            NSLog(@"Unexpected Background Task Type encountered");
        }
    });
    return YES;
}

- (BOOL)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    NSLog(@"Upload Progress:%f%%", (((float)totalBytesSent) / totalBytesExpectedToSend) * 100);
    return YES;
}

- (BOOL)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"Download Progress:%f%%", (((float)totalBytesWritten) / totalBytesExpectedToWrite) * 100);
    return YES;
}

- (NSURL *)URLSession:(NSURLSession *)session downloadTaskNeedsDestinationFileURL:(NSURLSessionDownloadTask *)downloadTask {
    NSString *filePath = self.backgroundDownloadFilePath;
    return [NSURL fileURLWithPath:filePath];
}

@end
