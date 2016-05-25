#import "SFAWebAuthenticationError.h"

NSString *const kSFAWebAuthenticationErrorDomain = @"SFAWebAuthenticationError";
NSString *const kSFAErrorWWWAuthenticateHeader = @"wwwAuthenticateHeader";
NSString *const kSFAErrorRequestURL = @"requestURL";
NSInteger const kSFAWebAuthenticationErrorCode_Failed = 401;
/**
 *  Note, there's no significance to -1, we just felt that it would not
 *  be appropriate to number it 402 or anything else because it's not analagous
 *  to any HTTP response code.
 */
NSInteger const kSFAWebAuthenticationErrorCode_ChallengeCancelled = -1;

@implementation SFAWebAuthenticationError

- (NSString *)wwwAuthenticateHeader {
    return self.userInfo[kSFAErrorWWWAuthenticateHeader];
}

- (NSURL *)requestUrl {
    return self.userInfo[kSFAErrorRequestURL];
}

+ (instancetype) errorWithMessage:(NSString *)message
    wwwAuthenticationHeaderString:(NSString *)header
                       requestURL:(NSURL *)url
                  underlyingError:(NSError *)error {
    return [self internalErrorWithCode:kSFAWebAuthenticationErrorCode_Failed
                               message:message
         wwwAuthenticationHeaderString:header
                            requestURL:url
                       underlyingError:error];
}

+ (instancetype)challengeCanceledWithMessage:(NSString *)message
               wwwAuthenticationHeaderString:(NSString *)header
                                  requestURL:(NSURL *)url
                             underlyingError:(NSError *)error {
    return [self internalErrorWithCode:kSFAWebAuthenticationErrorCode_ChallengeCancelled
                               message:message
         wwwAuthenticationHeaderString:header
                            requestURL:url
                       underlyingError:error];
}

+ (instancetype)internalErrorWithCode:(NSInteger)code
                              message:(NSString *)message
        wwwAuthenticationHeaderString:(NSString *)header
                           requestURL:(NSURL *)url
                      underlyingError:(NSError *)error {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if (header) {
        dictionary[kSFAErrorWWWAuthenticateHeader] = header;
    }
    if (url) {
        dictionary[kSFAErrorRequestURL] = url;
    }
    
    return [[self class] errorWithMessage:message
                                     type:SFAErrorTypeWebAuthenticationError
                                   domain:kSFAWebAuthenticationErrorDomain
                                     code:code
                          underlyingError:error
                                 userInfo:dictionary];
}

- (NSString *)description {
    NSMutableString *desc = [[super description] mutableCopy];
    [desc appendFormat:@"\n%@ %@:%@\n%@ %@:%@", SFAWWWAuthenticate, SFAHeader, self.wwwAuthenticateHeader, SFARequest, SFAURL, self.requestUrl];
    return [desc copy];
}

@end
