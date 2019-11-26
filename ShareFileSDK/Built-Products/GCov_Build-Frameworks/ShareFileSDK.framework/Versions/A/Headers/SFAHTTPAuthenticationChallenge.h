#import <Foundation/Foundation.h>

extern NSString *const kSFNSURLAuthenticationMethodOAuth2;
extern NSString *const kSFNSURLAuthenticationMethodConsumerConnector; // CCP2
extern NSString *const kSFNSURLAuthenticationMethodBearer;            // V3 API Bearer auth

@interface SFAHTTPAuthenticationChallenge : NSObject

@property (nonatomic, assign, readonly) NSUInteger authenticationRetryCount;
@property (nonatomic, copy, readonly) NSURL *originalRequestURL;
@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSURL *formsURL;
@property (nonatomic, copy, readonly) NSURL *tokenURL;
@property (nonatomic, strong, readonly) NSString *authMethod;
/**
 *  Get the protection space for an auth challenge
 */
//@property (nonatomic, copy, readonly) NSURLProtectionSpace *protectionSpace;

- (NSString *)realm;

- (instancetype)initWithAuthMethod:(NSString *)authMethod originalRequestURL:(NSURL *)originalURL andURL:(NSURL *)url isProxy:(BOOL)isProxy;
- (instancetype)initWithAuthMethod:(NSString *)authMethod originalRequestURL:(NSURL *)originalURL andFormsURL:(NSURL *)formsUrl andTokenURL:(NSURL *)tokenUrl isProxy:(BOOL)isProxy;
- (instancetype)initWithChallenge:(NSURLAuthenticationChallenge *)challenge withURL:(NSURL *)url originalRequestURL:(NSURL *)originalURL;
@end
