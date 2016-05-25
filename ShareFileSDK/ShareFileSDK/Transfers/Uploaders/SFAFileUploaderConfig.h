#import <Foundation/Foundation.h>
/**
 *  The SFAFileUploaderConfig class contains uploader configurations.
 */
@interface SFAFileUploaderConfig : NSObject
/**
 *  Default part size with value 4194304.
 */
    extern const NSUInteger SFADefaultPartSize;
/**
 *  Default number of thread with value 4.
 */
extern const NSUInteger SFADefaultNumberOfThreads;
/**
 *  Default Http timeout with value 60000.
 */
extern const NSTimeInterval SFADefaultHttpTimeout;
/**
 *  Maximum number of threads with value 4.
 */
extern const NSUInteger SFAMaxNumberOfThreads;
/**
 *  Size of file part to be uploaded. Min value can be 1.
 */
@property (nonatomic) NSUInteger partSize;
/**
 *  HTTP timeout of upload request.
 */
@property (nonatomic) NSTimeInterval httpTimeout;
/**
 *  Specifies the number of threads the threaded uploader will use. Min can be 1, max defined by SFAMaxNumberOfThreads. Only used if upload method is SFAUploadMethodThreaded.
 */
@property (nonatomic) NSUInteger numberOfThreads;

@end
