#import <Foundation/Foundation.h>
/**
 *  The SFAUploadFile class contain response of file upload to the server
 */
@interface SFAUploadFile : NSObject
/**
 *  Display name of the file.
 */
@property (nonatomic, copy) NSString *displayName;
/**
 *   Item file name.
 */
@property (nonatomic, copy) NSString *filename;
/**
 *  NSString containing id of the file.
 */
@property (nonatomic, copy) NSString *idString;
/**
 *  NSString containing MD5 hash of file.
 */
@property (nonatomic, copy) NSString *fileHash;
/**
 *  Size of file in bytes.
 */
@property (nonatomic) unsigned long long size;
/**
 *  Upload id of the file.
 */
@property (nonatomic, copy) NSString *uploadId;

@end

/**
 * Collection representing responses received for an upload operation.
 */
@interface SFAUploadResponse : NSMutableArray

/**
 *  Array of SFAUploadFile objects.
 */
@property (nonatomic, strong) NSMutableArray *files;

@end
