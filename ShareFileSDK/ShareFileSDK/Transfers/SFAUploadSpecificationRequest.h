#import <Foundation/Foundation.h>

/**
 *  SFAUploadMethod enum with NSInteger values.
 */
typedef NS_ENUM (NSInteger, SFAUploadMethod) {
    /**
     * Enum Value for standard uploader.
     */
    SFAUploadMethodStandard = 0,
    /**
     * Enum Value for streamed uploader.
     */
    SFAUploadMethodStreamed = 1,
    /**
     *  Enum Value for threaded uploader.
     */
    SFAUploadMethodThreaded = 2
};
/**
 *  The SFAUploadSpecificationRequest contains upload specification of the file being uploaded.
 */
@interface SFAUploadSpecificationRequest : NSObject
/**
 *  DestinationURI for upload. Commonly, this will be a parent SFIFolder URI, or a SFIShare request.
 *  Note: This property was previously named "parent" and was renamed for clarity.
 */
@property (nonatomic, strong) NSURL *destinationURI;
/**
 *  SFAUploadMethod enum value representing uploader/upload method to be used.
 */
@property (nonatomic) SFAUploadMethod method;
/**
 *  If YES, the uploader will send file contents directly in the POST body of the returned upload links. If NO, the uploader will send contents in MIME format. Default is YES.
 */
@property (nonatomic, getter = isRaw) BOOL raw;
/**
 *  Uploaded item file name. May be nill if the metadata is contained in MIME body, or ZIP file upload. Is mandatory for single file, raw uploads.
 */
@property (nonatomic, copy) NSString *fileName;
/**
 *  Upload item file size.
 */
@property (nonatomic) unsigned long long fileSize;
/**
 *  Inidicates that this upload is part of a batch. Batched uploads do not post notification until the whole batch is completed.
 */
@property (nonatomic, copy) NSString *batchId;
/**
 *  Boolean value that indicates that this upload is the last in a batch. Upload notifications for the whole batch are posted after this upload.
 */
@property (nonatomic, getter = isBatchLast) BOOL batchLast;
/**
 *  Boolean value that indicates if upload can be resumed or not. Upload can only be resumed if UploadMethod is SFAUploadMethodThreaded.
 */
@property (nonatomic) BOOL canResume;
/**
 *  Boolean value that indicates that the uploader wants to restart the file - i.e., ignore previous failed upload attempts.
 */
@property (nonatomic) BOOL startOver;
/**
 *  Boolean value that indicates that the upload is a Zip file, and contents must be extracted at the end of upload. The resulting files and directories will be placed in the target folder. If set to NO, the ZIP file is uploaded as a single file. Default is NO.
 */
@property (nonatomic) BOOL unzip;
/**
 *  Identifies the uploader tool.
 */
@property (nonatomic, copy) NSString *tool;
/**
 *  Boolean value that indicates whether items with the same name will be overwritten or not.
 */
@property (nonatomic) BOOL overwrite;
/**
 *  NSString that specifies the title of the uploading file.
 */
@property (nonatomic, copy) NSString *title;
/**
 *  NSString that specfies the details of the upload file
 */
@property (nonatomic, copy) NSString *details;
/**
 *  BOOL value that indicates that this upload is part of a Send operation
 */
@property (nonatomic, getter = isSend) BOOL send;
/**
 *  Used if IsSend is YES. Specifies which Send operation this upload is part of.
 */
@property (nonatomic, copy) NSString *sendGuid;
/**
 *  BOOL value that indicates whether users will be notified of this upload - based on folder preferences
 */
@property (nonatomic) BOOL notify;
/**
 *  Specifies the number of threads the threaded uploader will use. Only used if method is SFAUploadMethodThreaded, ignored otherwise.
 */
@property (nonatomic) int threadCount;
/**
 *  Client filesystem Created Date of this item.
 */
@property (nonatomic, strong) NSDate *clientCreatedDateUtc;
/**
 *  Client filesystem Modified Date of this item.
 */
@property (nonatomic, strong) NSDate *clientModifiedDateUtc;

- (NSString *)responseFormat;

@end
