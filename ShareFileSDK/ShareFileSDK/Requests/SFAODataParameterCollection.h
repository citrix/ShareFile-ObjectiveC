#import <Foundation/Foundation.h>
#import "SFAODataParameter.h"
/**
 *  The SFAODataParameterCollection class is collection of SFAODataParameter objects. Similar to NSSet this collection does not contain multiple entries of same instance.
 */
@interface SFAODataParameterCollection : NSObject
/**
 *  Creates comma seprated toStringForUri representation of contained SFAODataParameter objects suitable for use in URL/URI.
 *
 *  @return NSString of comma separated toStringForUri representation of contained SFAODataParameter objects.
 */
- (NSString *)toStringForUri;
/**
 *  Adds or Updates SFAODataParameter in the collection.
 *
 *  @param parameter SFAODataParameter object to be added to the collection.
 */
- (void)addOrUpdateObject:(SFAODataParameter *)parameter;
/**
 *  Removes the SFAODataParameter object from the collection.
 *
 *  @param parameter SFAODataParameter to be removed from the collection.
 */
- (void)removeObject:(SFAODataParameter *)parameter;
/**
 *  Returns a BOOL value that indicates whether a given SFAODataParameter object is present in the collection.
 *
 *  @param parameter SFAODataParameter object to be tested for membership.
 *
 *  @return Returns YES if SFAODataParameter is present in the collection, otherwise NO.
 */
- (BOOL)containsObject:(SFAODataParameter *)parameter;
/**
 *  @return NSUInteger representing number of members in the collection.
 */
- (NSUInteger)count;
/**
 *  @return Returns a new collection conforming to NSFastEnumeration, representing current state of the SFAODataParameterCollection instance.
 */
- (id <NSFastEnumeration> )collectionAsFastEnumrable;

@end
