#import <Foundation/Foundation.h>
#import "SFAAsyncFileDownloader.h"

@interface SFAAsyncFileDownloader ()

- (instancetype)initWithItem:(SFIItem *)item withSFAClient:(SFAClient *)client andDownloaderConfig:(SFADownloaderConfig *)config;
+ (instancetype)downloaderForURLSessionTaskDefaultHTTPDelegateWithClient:(SFAClient *)client;
+ (instancetype)downloaderForURLSessionTaskHTTPDelegateWithItem:(SFIItem *)item client:(SFAClient *)client config:(SFADownloaderConfig *)config;

@end
