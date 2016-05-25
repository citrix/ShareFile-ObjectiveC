#import <Foundation/Foundation.h>
/**
 *  The SFAFileInfo protocol describes helper methods for dealing with files on file system.
 */
@protocol SFAFileInfo <NSObject>

/**
 *  Path of the file.
 */
@property (nonatomic, strong, readonly) NSString *filePath;
/**
 *  Creates a NSInputStream for file represented by filePath.
 *
 *  @return Returns NSInputStream object or returns nil if file is not located at filePath.
 */
- (NSInputStream *)streamForRead;
/**
 *  Creates a NSInputStream for file represented by filePath.
 *
 *  @return Returns NSOutputStream object or returns nil if file is not located at filePath.
 */
- (NSOutputStream *)streamForWrite;
/**
 *  Creates a NSFileHandle for reading for file represented by filePath.
 *
 *  @return Returns NSFileHandle for reading at filePath or nil if file is not located at filePath.
 */
- (NSFileHandle *)fileHandleForReading;
/**
 *  Creates a NSFileHandle for writing for file represented by filePath.
 *
 *  @param createIfNeeded BOOL creates file if it does not exist.
 *
 *  @return Returns NSFileHandle for writing at filePath or nil if file is not located at filePath and createIfNeeded is NO.
 */
- (NSFileHandle *)fileHandleForWritingCreateIfNeeded:(BOOL)createIfNeeded;
/**
 *  Returns the attributes of the item at filePath.
 *
 *  @return NSDictionary that describes the attributes (file, directory, symlink, and etc) of the file represented by filePath or nil if an error occurred.
 */
- (NSDictionary *)fileAttributes;
/**
 *  Returns size of the file at filePath
 *
 *  @return An NSNumber containg size of the file at filePath or nil if an error occured.
 */
- (NSNumber *)fileSize;

@end

/**
 * The SFAFileInfo class conforms to SFAFileInfo protocol and is provided for convenience.
 */
@interface SFAFileInfo : NSObject <SFAFileInfo>
/**
 *  Initializes SFAFileInfo object with path.
 *
 *  @param path NSString Path of the file.
 *
 *  @return Returns initialized SFAFileInfo or nil if object could not be initialized for some reason.
 */
- (instancetype)initWithFilePath:(NSString *)path;

@end
