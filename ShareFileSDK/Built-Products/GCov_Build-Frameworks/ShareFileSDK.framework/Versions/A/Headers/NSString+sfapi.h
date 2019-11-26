#import <Foundation/Foundation.h>
#import "SFAHttpBodyDataProvider.h"

/**
 *  Category of NSString with useful methods not available in NSString.
 */
@interface NSString (sfapi) <SFAHttpBodyDataProvider>

/**
 *  Splits the receiver into components separated by passed string.
 *
 *  @param string             String which separates the components.
 *  @param removeEmptyEntries If YES removes empty entries i.e. length = 0.
 *
 *  @return NSArray containing seprated components(NSString).
 */
- (NSArray *)componentsSeparatedByString:(NSString *)string removeEmptyEntries:(BOOL)removeEmptyEntries;
/**
 *  Escapes the receiver for use in HTTP URL(using percent-encoding).
 *
 *  @return Escaped NSString
 */
- (NSString *)escapeString;
/**
 *  Returns NSDictionary containing key-value from the query string represented by receiver. Example string: @"key1=value1&key2=value2"
 *
 *  @return NSDictionary containing key-value pairs from query string represented by receiver.
 */
- (NSDictionary *)queryStringDictionary;

/**
 *  Trims passed character if found at the end of the string.
 *
 *  @param c Character to be trimmed.
 *
 *  @return Trimmed NSString.
 */
- (NSString *)trimEndChar:(char)c;
/**
 *  Returns YES if string represents a valid URL, NO otherwise.
 *
 *  @return Returns YES if string represents a valid URL, NO otherwise.
 */
- (BOOL)isValidURL;
/**
 *  NSURL instantiated with the receiver.
 *
 *  @return NSURL intantiated with the receiver or nil if some error occured.
 */
- (NSURL *)URL;

@end
