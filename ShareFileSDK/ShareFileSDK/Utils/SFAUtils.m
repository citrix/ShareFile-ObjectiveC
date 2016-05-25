#import "SFAUtils.h"
#import "NSHTTPURLResponse+sfapi.h"

static const NSUInteger kDefaultLocalizationQValue = 9;
static const NSUInteger kMaxLocaleOptions = 6;

@implementation SFAUtils

+ (id)nilForNSNull:(id)object {
    if ([object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return object;
}

+ (id)nullForNil:(id)object {
    if (!object) {
        return [NSNull null];
    }
    return object;
}

#pragma mark - Auth Utils
+ (BOOL)didAuthFailForRequest:(SFAHttpRequestResponseDataContainer *)responseContainer {
    return [responseContainer.response isUnauthorizedCode] || [self wasAuthCanceledForRequest:responseContainer];
}

+ (BOOL)wasAuthCanceledForRequest:(SFAHttpRequestResponseDataContainer *)responseContainer {
    return [responseContainer.error.domain isEqualToString:NSURLErrorDomain] && responseContainer.error.code == NSURLErrorUserCancelledAuthentication;
}

+ (NSString *)acceptHeaderForCultures:(NSArray *)cultures {
    NSMutableString *acceptLanguageHeaderValue = [NSMutableString new];
    
    for (NSUInteger i = 0; i < cultures.count && i < kMaxLocaleOptions; i++) {
        NSString *localeIdentifier = ((NSLocale *)cultures[i]).localeIdentifier;
        NSUInteger localeQValue = kDefaultLocalizationQValue - i;
        
        // Portuguese requires that we specify pt-BR to the server.
        if ([localeIdentifier rangeOfString:@"pt" options:NSCaseInsensitiveSearch].location == 0) {
            localeIdentifier = @"pt-BR";
        }
        // Simplified Chinese should be mapped to zh-CN for ShareFile requests
        else if ([localeIdentifier caseInsensitiveCompare:@"zh"] == NSOrderedSame || [localeIdentifier rangeOfString:@"zh-Hans" options:NSCaseInsensitiveSearch].location == 0) {
            localeIdentifier = @"zh-CN";
        }
        
        [acceptLanguageHeaderValue appendFormat:@"%@;q=0.%lu,", localeIdentifier, (unsigned long)localeQValue];
    }
    
    return [acceptLanguageHeaderValue copy];
}

@end
