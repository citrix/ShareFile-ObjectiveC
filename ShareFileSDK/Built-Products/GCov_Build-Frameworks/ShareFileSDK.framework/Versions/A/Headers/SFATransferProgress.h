#import <Foundation/Foundation.h>
/**
 *  The SFATransferProgress contains progress related information of the data being transfered.
 */
@interface SFATransferProgress : NSObject <NSCopying>
/**
 *  Total number of bytes transfered.
 */
@property (nonatomic) int64_t bytesTransferred;
/**
 *  Total number of bytes remaining to be transfered.
 */
@property (nonatomic) int64_t bytesRemaining;
/**
 *  Total bytes to be transfered.
 */
@property (nonatomic) int64_t totalBytes;
/**
 *  TransferId contains the NSString representation of formatted UUID.
 */
@property (nonatomic, copy) NSString *transferId;
/**
 *  BOOL value representing if transfer is complete.
 */
@property (nonatomic, getter = isComplete) BOOL complete;
/**
 *  NSDictionary to be passed back with each transfer progress callback call.
 */
@property (nonatomic, strong) NSDictionary *transferMetadata;

@end
