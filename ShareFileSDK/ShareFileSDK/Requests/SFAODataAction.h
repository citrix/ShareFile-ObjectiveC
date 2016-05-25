#import <Foundation/Foundation.h>
#import "SFAODataParameterCollection.h"
/**
 * The SFAODataAction class represents an OData action and its correponding OData parameters.
 */
@interface SFAODataAction : NSObject
/**
 *  NSString representing name of OData Action.
 */
@property (nonatomic, copy) NSString *actionName;
/**
 *  SFAODataParameterCollection a collection of SFAODataParameter.
 */
@property (nonatomic, strong) SFAODataParameterCollection *parameters;

@end
