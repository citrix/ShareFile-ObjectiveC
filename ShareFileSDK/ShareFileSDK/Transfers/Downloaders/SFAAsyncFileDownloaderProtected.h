#import <Foundation/Foundation.h>
#import "SFAAsyncFileDownloader.h"

@interface SFAAsyncFileDownloader ()

@property (nonatomic, strong) SFIItem *item;

- (SFApiQuery *)createDownloadQuery;

@end
