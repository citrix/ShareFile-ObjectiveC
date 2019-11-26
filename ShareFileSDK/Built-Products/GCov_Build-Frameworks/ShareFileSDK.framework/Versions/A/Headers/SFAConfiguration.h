#import <Foundation/Foundation.h>
#import "SFALogger.h"

/**
 *  The SFAConfiguration class contains configuration for SFAClient.
 */
@interface SFAConfiguration : NSObject <NSCopying>
/**
 *  Accept-Language header for current array of supported cultures.
 */
@property (nonatomic, readonly) NSString *acceptLanguageHeader;

/**
 *  ShareFile Client ID.
 *  Sign up for an API key at http://api.sharefile.com/rest/api-key.aspx
 */
@property (nonatomic, copy) NSString *clientId;
/**
 *  ShareFile Client Secret.
 *  Sign up for an API key at http://api.sharefile.com/rest/api-key.aspx
 */
@property (nonatomic, copy) NSString *clientSecret;
/**
 *  If YES set HTTP header field X-Http-Method-Override. Default is NO.
 */
@property (nonatomic) BOOL useHttpMethodOverride;
/**
 *  Set HTTP request timeout. Default is 100.
 */
@property (nonatomic) NSTimeInterval httpTimeout;
/**
 *  Set HTTP header field Accept-Language with supported languages.
 */
@property (nonatomic, copy) NSArray *supportedCultures;

/**
 *  Set HTTP header field X-SFAPI-Tool with tool name. Default is SF Client SDK
 */
@property (nonatomic, copy) NSString *toolName;
/**
 *  Set HTTP header field X-SFAPI-ToolVersion with tool version. Default is 3.0
 */
@property (nonatomic, copy) NSString *toolVersion;
/**
 *  A logger conforming to protocol SFALogger. Default is SFADefaultLogger.
 */
@property (nonatomic, strong) id <SFALogger> logger;
/**
 *  If YES log request headers. Default is NO.
 */
@property (nonatomic) BOOL logHeaders;
/**
 *  If YES log sensitive personal data in the request. Default is NO.
 */
@property (nonatomic) BOOL logPersonalInformation;
/**
 *  Dictionary of providerId (NSString*) and associated NSArray of NSStrings defining the client-supported capabilities for various providers
 */
@property (nonatomic, copy) NSDictionary *clientCapabilities;
/**
 *  Initializes SFAConfiguration with default values.
 *
 *  @return Returns initialized SFAConfiguration object or nil if an object could not be created for some reason.
 */
+ (instancetype)defaultConfiguration;

@end
