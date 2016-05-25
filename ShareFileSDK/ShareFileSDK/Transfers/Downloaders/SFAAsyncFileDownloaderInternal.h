#import <Foundation/Foundation.h>
#import "SFAAsyncFileDownloader.h"

@interface SFAAsyncFileDownloader ()

- (instancetype)initWithItem:(SFItem *)item withSFAClient:(SFAClient *)client andDownloaderConfig:(SFADownloaderConfig *)config;
+ (instancetype)downloaderForURLSessionTaskDefaultHTTPDelegateWithClient:(SFAClient *)client;
+ (instancetype)downloaderForURLSessionTaskHTTPDelegateWithItem:(SFItem *)item client:(SFAClient *)client config:(SFADownloaderConfig *)config;

@end
