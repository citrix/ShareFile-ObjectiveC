#import <Foundation/Foundation.h>

@interface NSURLCredential (sfapi)

/**
 *  Check credential for equality based relevant credential properties
 *
 *  @param credential Credential to compare
 *
 *  @return Boolean indicating equality
 */
- (BOOL)isEqualToCredential:(NSURLCredential *)credential;

/**
 *  Is the current credential ready for use in SDK?
 */
- (BOOL)isUsable;

@end
