#import <Foundation/Foundation.h>

/*
 * Credential status used to ensure that invalid credentials are
 * tracked, and not used repeatedly.
 */
typedef NS_ENUM (NSUInteger, SFACredential_Status) {
    SFACredential_StatusUnknown,     /* Status unknown. Default state before a status is set. */
    SFACredential_StatusValid,       /* Status last known as valid. Typically marked after a cred is successfully used in a challenge. */
    SFACredential_StatusInvalid,     /* Status last known as invalid. Marked after a failed challenge. */
    SFACredential_StatusInteractive  /* Temporary status for special case where an invalid credential is supplied in an interactive challenge. */
};

/**
 *  CredentialStatusTracking describes methods used for keeping
 *  track of credential validity, so that credentials known to
 *  be invalid are not retried repeatedly.
 */
@protocol SFACredentialStatusTracking <NSObject>

#pragma mark - Credential Status

/**
 *  Get current credential validity for a supplied credential +
 *  URL combination.
 *
 *  @param credential Credential to check
 *  @param url        Associated URL
 *
 *  @return Current credential validity, or StatusUnknown if no status is available
 */
- (SFACredential_Status)credentialStatus:(NSURLCredential *)credential
                                  forURL:(NSURL *)url;
                                  
/**
 *  Get current credential validity for a supplied credential +
 *  Protection Space combination.
 *
 *  @param credential Credential to check
 *  @param space      Associated Protection Space
 *
 *  @return Current credential validity, or StatusUnknown if no status is available
 */
- (SFACredential_Status)credentialStatus:(NSURLCredential *)credential
                      forProtectionSpace:(NSURLProtectionSpace *)space;
                      
/**
 *  Get current credential validity for a supplied credential +
 *  URL combination.
 *
 *  @param credential Credential to check
 *  @param status     New credential status
 *  @param url        Associated URL
 */
- (void)updateCredentialStatus:(NSURLCredential *)credential
                        status:(SFACredential_Status)status
                        forURL:(NSURL *)url;
                        
/**
 *  Update the current credential validity for a credential +
 *  Protection Space combination.
 *
 *  @param credential Credential to update status
 *  @param status     New credential status
 *  @param space      Associated Protection Space
 */
- (void)updateCredentialStatus:(NSURLCredential *)credential
                        status:(SFACredential_Status)status
            forProtectionSpace:(NSURLProtectionSpace *)space;
            
@end
