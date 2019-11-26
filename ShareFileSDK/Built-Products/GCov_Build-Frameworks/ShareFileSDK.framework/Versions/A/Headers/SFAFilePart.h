#import <Foundation/Foundation.h>

@interface SFAFilePart : NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic) unsigned long long index;
@property (nonatomic) unsigned long long offset;
@property (nonatomic) NSUInteger length; // File part can only be as long as NSUInteger
@property (nonatomic) NSString *uploadUrl;
@property (nonatomic) NSString *filePartHash;
@property (nonatomic) NSUInteger bytesUploaded; // File part can only be as long as NSUInteger
@property (nonatomic, getter = isLastPart) BOOL lastPart;

- (NSURL *)composedUploadUrl;

@end
