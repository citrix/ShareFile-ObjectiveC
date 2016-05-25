#import "SFAEqualToFilter.h"

/**
 *  Filter query results by SFA model type. eg. Folder, File, etc.
 */
@interface SFATypeFilter : SFAEqualToFilter

/**
 *  Model type to filter by
 */
@property (nonatomic, strong, readonly) NSString *type;

/**
 *  OData isof expression, if any
 */
@property (nonatomic, strong, readonly) NSString *expression;

/**
 *  @param sfType     Model type
 *  @param expression OData isof expression
 */
- (instancetype)initWithType:(NSString *)sfType expression:(NSString *)expression;

@end
