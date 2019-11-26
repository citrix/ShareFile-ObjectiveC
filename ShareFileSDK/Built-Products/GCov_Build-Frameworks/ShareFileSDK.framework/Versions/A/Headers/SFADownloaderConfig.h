#import <Foundation/Foundation.h>
/**
 * The SFARangeRequest class is data container for HTTP Range header configuration.
 */
@interface SFARangeRequest : NSObject
/**
 *  NSNumber containing beginning of range in HTTP header
 */
@property (strong, nonatomic) NSNumber *begin;
/**
 *  NSNumber containing ending of range in HTTP header.
 */
@property (strong, nonatomic) NSNumber *end;

@end
/**
 *  The SFADownloaderConfig class contains configuration for downloading item.
 */
@interface SFADownloaderConfig : NSObject
/**
 *  SFARangeRequest object.
 */
@property (nonatomic, strong) SFARangeRequest *rangeRequest;

/**
 *  Optional: Share (Send) URL for this downloader.
 *  Ex: https://subdomain.sf-api.com/sf/v3/Shares(s000000fffffff)
 */
@property (nonatomic, copy) NSURL *shareURL;

/**
 *  Optional: Share (Send) AliasID for this downloader
 */
@property (nonatomic, copy) NSString *shareAliasId;

/**
 *  Initializes SFADownloaderConfig with default values.
 *
 *  @return Returns initialzed SFADownloaderConfig object or nil if an object could not be created for some reason.
 */
+ (instancetype)defaultDownloadConfig;

@end
