#import "SFAQueryBase.h"
#import "SFAClient.h"

/**
 * The SFApiQuery class is concrete query class returned by all entities available by default in ShareFile SDK.
 */
@interface SFApiQuery : SFAQueryBase <SFAQuery, SFAReadOnlyODataQuery>
/**
 *  Initializes a query with provided parameters
 *
 *  @param shareFileClient SFAClient used to be used to execute this query.
 *
 *  @return Returns initialized SFApiQuery object.
 */
- (instancetype)initWithClient:(id <SFAClient> )shareFileClient;
/**
 *  Helper function to add ids using object conforming to NSObject protocol.
 *
 *  @param ids An object conforming to NSObject protocol.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)addIds:(id <NSObject> )ids;
/**
 *  Helper function to add ids using key value pair.
 *
 *  @param ids NSString value.
 *  @param key NSString key.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)addStringIds:(NSString *)ids withKey:(NSString *)key;
/**
 *  Set the 'from' property of query.
 *
 *  @param fromEntity NSString name of entity making the query.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)setFrom:(NSString *)fromEntity;
/**
 *  Helper method to set action property of query.
 *
 *  @param action NSString specifying action name.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)setAction:(NSString *)action;
/**
 *  Helper method to add action with only action paramter(key=nil, value)
 *
 *  @param ids NSString value of ODataParameter that becomes parameter of ODataAction.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)addActionIds:(NSString *)ids;
/**
 *  Helper method to add action with only action paramter(key, value)
 *
 *  @param ids NSString value of ODataParameter that becomes parameter of ODataAction.
 *  @param key NSString key of ODataParameter that becomes parameter of ODataAction.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)addActionIds:(NSString *)ids withKey:(NSString *)key;
/**
 *  Helper method to add sub-action with name only.
 *
 *  @param subAction NSString subAction name.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)addSubAction:(NSString *)subAction;
/**
 *  Helper method to add sub-action with  name and action paramter(key=nil, value).
 *
 *  @param subAction NSString subAction name.
 *  @param value NSString value of ODataParameter that becomes parameter of ODataAction.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)addSubAction:(NSString *)subAction withValue:(NSString *)ide;
/**
 *  Helper method to add sub-action will all three parameters required by SFAODataAction.
 *
 *  @param subAction NSString subAction name.
 *  @param key       NSString key of ODataParameter that becomes parameter of ODataAction.
 *  @param value       NSString value of ODataParameter that becomes parameter of ODataAction.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)addSubAction:(NSString *)subAction key:(NSString *)key withValue:(NSString *)ide;
/**
 *  Helper method to add query string key value pair to query.
 *
 *  @param queryString NSString queryString key.
 *  @param value       NSString queryString value.
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)addQueryString:(NSString *)queryString withValue:(id <NSObject> )value;
/**
 *  Helper method to ids using URL
 *
 *  @param url NSURL whose absolute string will be added to query ids
 *
 *  @return Returns query reference for function call chaining.
 */
- (SFApiQuery *)addUrl:(NSURL *)url;

@end
