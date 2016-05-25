#import "SFAItemAlias.h"

@interface SFItemsEntity (sfapi)

/**
 *  Composed URL that point to Items(alias) for the BaseURL.
 *
 *  @param alias A NSString alias
 *
 *  @return Returns a composed NSURL.
 
 */
- (NSURL *)urlWithAlias:(NSString *)alias;
/**
 *  Composed URL that point to Items(alias) for the BaseURL.
 *
 *  @param itemAlias SFAItemAlias enum value describing the alias.
 *
 *  @return Returns a composed NSURL.
 */
- (NSURL *)urlWithItemAlias:(SFAItemAlias)itemAlias;

/**
   @abstract Copy Item
   Copies an item to a new target Folder. If the target folder is in another zone, the operation will return an AsyncOperation record instead. Clients may query the /AsyncOperation Entity to determine operation progress and result.
   @param id
   @param targetid
   @param shouldMove
   @return the modified source object
 */
- (SFApiQuery *)copyWithUrl:(NSURL *)url targetid:(NSString *)targetid andMove:(NSNumber *)shouldMove;

@end
