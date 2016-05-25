#import <Foundation/Foundation.h>

@interface SFAUtils : NSObject

+ (id)nullForNil:(id)object;
+ (id)nilForNSNull:(id)object;

#pragma mark - Auth Utils
/**
 *  Determine if a given HTTP response container includes an auth failure.
 *
 *  @param responseContainer container for request
 *
 *  @return YES if auth failed
 */
+ (BOOL)didAuthFailForRequest:(SFAHttpRequestResponseDataContainer *)responseContainer;

/**
 *  Determine if an auth challenge was canceled for a given HTTP response container.
 *
 *  @param responseContainer container for request
 *
 *  @return YES if an auth challenge was canceled
 */
+ (BOOL)wasAuthCanceledForRequest:(SFAHttpRequestResponseDataContainer *)responseContainer;

/**
 *  Build SF-compatible Accept-Language header for a given array of locales
 *
 *  @param cultures NSArray<NSLocale>
 *
 *  @return Accept-Language Header
 */
+ (NSString *)acceptHeaderForCultures:(NSArray *)cultures;

@end
