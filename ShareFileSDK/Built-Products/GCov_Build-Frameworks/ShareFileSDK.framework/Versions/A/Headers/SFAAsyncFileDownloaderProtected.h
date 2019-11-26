#import <Foundation/Foundation.h>
#import "SFAAsyncFileDownloader.h"

@interface SFAAsyncFileDownloader ()

@property (nonatomic, strong) SFItem *item;

- (SFApiQuery *)createDownloadQuery;

@end
