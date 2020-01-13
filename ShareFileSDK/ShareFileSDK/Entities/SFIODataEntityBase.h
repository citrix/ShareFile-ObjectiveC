#import <Foundation/Foundation.h>
#import "SFApiQuery.h"

/**
 *  Base class of all Enitity classes.
 */
@interface SFIODataEntityBase : NSObject

/**
 *  SFAClient that initialized this entity.
 */
@property (weak, nonatomic) id <SFAClient> client;
/**
 *  Name of the entity.
 */
@property (strong, nonatomic) NSString *entity;
/**
 *  Initializes an entity with provided parameters.
 *
 *  @param client SFAClient that initialized this entity.
 *
 *  @return Returns initialized SFIODataEntityBase object or nil if object could not be created for some reason.
 */
- (instancetype)initWithClient:(id <SFAClient> )client;

@end
