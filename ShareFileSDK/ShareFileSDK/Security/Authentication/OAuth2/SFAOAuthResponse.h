#import <Foundation/Foundation.h>
/**
 *  SFAOAuthResponse is a protocol that should be implemented by class containg OAuth response e.g. SFAOAuthToken class.
 */
@protocol SFAOAuthResponse <NSObject>
/**
 *  Fill properties with dictionary.
 *
 *  @param values A NSDictionary using which properties can be populated.
 */
- (void)fillWithDictionary:(NSDictionary *)values;
/**
 *  A NSDictionary containing key value pairs that could not be mapped to class properties.
 */
@property (nonatomic, strong) NSDictionary *properties;

@end
