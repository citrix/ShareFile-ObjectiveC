#import <Foundation/Foundation.h>
/**
 *  The SFAODataParameter class contains OData parameter key and its corresponding value.
 */
@interface SFAODataParameter : NSObject
/**
 *  OData parameter key.
 */
@property (nonatomic, copy) NSString *key;
/**
 *  OData parameter value.
 */
@property (nonatomic, copy) NSString *value;
/**
 *  BOOL value indicating if value needs to be encoded. Default is NO. This only has effect if key is nil or empty.
 */
@property (nonatomic) BOOL encodeValue;
/**
 *  Initializes SFAODataParameter with provided parameters.
 *
 *  @param aKey      NSString containing key.
 *  @param val       NSString containing value.
 *  @param encodeVal BOOL value of encodeValue.
 *
 *  @return Returns initialized SFAODataParameter object or nil if an object could not be created for some reason.
 */
- (instancetype)initWithKey:(NSString *)aKey value:(NSString *)val encodeValue:(BOOL)encodeVal;
/**
 *  Initializes SFAODataParameter with provided parameters.
 *
 *  @param val       NSString containing value.
 *  @param encodeVal BOOL value of encodeValue.
 *
 *  @return Returns initialized SFAODataParameter object or nil if an object could not be created for some reason.
 */
- (instancetype)initWithValue:(NSString *)val encodeValue:(BOOL)encodeVal;
/**
 *  Initializes SFAODataParameter with provided parameters.
 *
 *  @param aKey       NSString containing key.
 *  @param val        NSString containing value.
 *
 *  @return Returns initialized SFAODataParameter object or nil if an object could not be created for some reason.
 */
- (instancetype)initWithKey:(NSString *)key value:(NSString *)val;
/**
 *  Create a NSString suitable for use in URL/URI, replacing certain characters with the equivalent percent escape sequence if needed.
 *
 *  @return Returns NSString suitable for use in URL/URI.
 */
- (NSString *)toStringForUri;

@end
