#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (sfapi)

/**
 *  Initializes and returns a SFAUploadSpecificationRequest object with provided parameters and information of the receiver.
 *
 *  @param fileName        See SFAUploadSpecificationRequest fileName. If not provided, assigns name based on receiver's date and type.
 *  @param parentFolderURL See SFAUploadSpecificationRequest parent.
 *  @param description     See SFAUploadSpecificationRequest details.
 *  @param overwrite       See SFAUploadSpecificationRequest details.
 *  @param method          See SFAUploadSpecificationRequest method.
 *
 *  @return An initialized SFAUploadSpecificationRequest object or nil if object can not be initialized for some reason.
 */
- (SFAUploadSpecificationRequest *)uploadSpecificationRequestWithFileName:(NSString *)fileName parentFolderURL:(NSURL *)parentFolderURL description:(NSString *)description shouldOverwrite:(BOOL)overwrite uploadMethod:(SFAUploadMethod)method;

/**
 *   Trys to parse the file extension from the asset url.
 */
- (NSString *)fileExtension;

@end
