#pragma mark - Authentication Enums
/*
 * Alias for NSURLSessionAuthChallengeDisposition enum,
 * this ensures we can use this enum even when
 * targtting older iOS/OSX
 */
typedef NS_ENUM (NSInteger, SFURLAuthChallengeDisposition) {
    SFURLAuthChallengeUseCredential = 0,                     /* Use the specified credential, which may be nil */
    SFURLAuthChallengePerformDefaultHandling = 1,            /* Default handling for the challenge - as if this delegate were not implemented; the credential parameter is ignored. */
    SFURLAuthChallengeCancelAuthenticationChallenge = 2,     /* The entire request will be canceled; the credential parameter is ignored. */
    SFURLAuthChallengeRejectProtectionSpace = 3,             /* This challenge is rejected and the next authentication protection space should be tried;the credential parameter is ignored. */
};

typedef NS_ENUM (NSUInteger, SFAAuthHandling_ResponseResult) {
    SFAAuthHandling_Continue,
    SFAAuthHandling_Retry,
    SFAAuthHandling_BackgroundAuth,
    SFAAuthHandling_Interactive,
    SFAAuthHandling_Cancel
};
