#import <Foundation/Foundation.h>
/**
 *  SFAErrorType NS_ENUM with NSInteger values.
 */
typedef NS_ENUM (NSInteger, SFAErrorType) {
    /**
     *  Enum value for web authentication error.
     */
    SFAErrorTypeWebAuthenticationError = 1001,
    /**
     *  Enum value  for invalid response error.
     */
    SFAErrorTypeInvalidResponseError = 1002,
    /**
     *  Enum value for proxy authentication error.
     */
    SFAErrorTypeProxyAuthenticationError = 1003,
    /**
     *  Enum value for unknown error.
     */
    SFAErrorTypeUnknownError = 1004,
    /**
     *  Enum value for application error.
     */
    SFAErrorTypeApplicationError = 1005,
    /**
     *  Enum value for async operation scheduled error.
     */
    SFAErrorTypeAsyncOperationScheduledError = 1006,
    /**
     *  Enum value for upload error.
     */
    SFAErrorTypeUploadError = 1007,
    /**
     *  Enum value for HTTP request error.
     */
    SFAErrorTypeHttpRequestError = 1008,
    /**
     *  Enum value for HTTP content retrieval error.
     */
    SFAErrorTypeUnableToRetrieveHttpContentError = 1009,
    /**
     *  Enum value for OAuth error.
     */
    SFAErrorTypeOAuthError = 1010,
    /**
     *  Enum value for OData request error.
     */
    SFAErrorTypeODataRequestError = 1011,
    /**
     *  Enum value for File Copy error.
     */
    SFAErrorTypeFileCopyError = 1012,
    /**
     *  Enum value for Background URL Session Task failing with error.
     */
    SFAErrorTypeBackgroundURLSessionTaskFailWithError = 1013,
    /**
     *  Enum value for situation when a new URL Session Task could not be created for existing URL Session Task.
     */
    SFAErrorTypeUnableToCreateNewTaskForExistingURLSessionTask = 1014
};
/**
 *  String constant for error message key in user info dictionary.
 */
extern NSString *const kSFAErrorMessage;
/**
 *  String constant for error type key in user info dictionary.
 */
extern NSString *const kSFAErrorType;

/**
 * The SFAError class is used to inform API user about an error.
 */
@interface SFAError : NSError

/**
 *  String value of the specific failure.  While the .code property may return a numeric error code, i.e. 404, this property would return a string code i.e. "NotFound" instead.  This code is populated for SF API errors only.  It will present an API error code.
 */
@property (nonatomic, copy) NSString *errorCode;
/**
 *  NSString representing error message.   This is typically an internal SDK description of an error, not user presentable.
 */
@property (nonatomic, copy, readonly) NSString *message;
/**
 *  SFAErrorType enum value representing error type.
 */
@property (nonatomic, readonly) SFAErrorType errorType;
/**
 *  If an error was not an SF API error or internal SDK error, this property will be populated with the root cause.
 */
@property (nonatomic, readonly) NSError *underlyingError;
/**
 *  @return a localized failure reason for this error or, if present, the underlying error.  This message can be presented to users.
 */
- (NSString *)userFriendlyErrorMessage;
/**
 *  Initializes SFAError with provided parameters.
 *
 *  @param message   NSString representing error message.
 *  @param errorType SFAErrorType enum value representing error type.
 *
 *  @return Returns initialized SFAError object or nil if an object could not be created for some reason.
 */
+ (instancetype)errorWithMessage:(NSString *)message type:(SFAErrorType)errorType;
/**
 *  Initializes SFAError with provided parameters.
 *
 *  @param message   NSString representing error message.
 *  @param errorType SFAErrorType enum value representing error type.
 *  @param domain    NSString representing error domain. This can be one of the predefined NSError domains, or an arbitrary string describing a custom domain. domain must not be nil. See Error Domains for a list of predefined domains.
 *  @param code      NSInteger represent error code for the error.
 *  @param dict      NSDictionary representing userInfo dictionary for the error. userInfo may be nil.
 *
 *  @return Returns initialized SFAError object or nil if an object could not be created for some reason.
 */
+ (instancetype)errorWithMessage:(NSString *)message type:(SFAErrorType)errorType domain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict;

/**
 *  Initializes SFAError with provided parameters.
 *
 *  @param message   NSString representing error message.
 *  @param errorType SFAErrorType enum value representing error type.
 *  @param domain    NSString representing error domain. This can be one of the predefined NSError domains, or an arbitrary string describing a custom domain. domain must not be nil. See Error Domains for a list of predefined domains.
 *  @param code      NSInteger represent error code for the error.
 *  @param error     underlying error, if any
 *  @param dict      NSDictionary representing userInfo dictionary for the error. userInfo may be nil.
 *
 *  @return Returns initialized SFAError object or nil if an object could not be created for some reason.
 */
+ (instancetype)errorWithMessage:(NSString *)message type:(SFAErrorType)errorType domain:(NSString *)domain code:(NSInteger)code underlyingError:(NSError *)error userInfo:(NSDictionary *)dict;

@end
