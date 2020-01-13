#import <Foundation/Foundation.h>

/**
 *  This class provides data to user when background upload is initiated.
 */
@interface SFABackgroundUploadInitiationResponse : NSObject

/**
 *  Upload specification received. May be needed for re-creation of HTTP delegate.
 */
@property (strong, nonatomic) SFIUploadSpecification *uploadSpecification;
/**
 *  Upload task that is performing the background upload.
 */
@property (strong, nonatomic) NSURLSessionUploadTask *uploadTask;
/**
 *  Session used for background upload.
 */
@property (strong, nonatomic) NSURLSession *session;

@end
