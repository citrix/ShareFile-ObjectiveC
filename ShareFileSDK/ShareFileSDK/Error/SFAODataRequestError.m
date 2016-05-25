#import "SFAODataRequestError.h"
#import "NSDictionary+sfapi.h"

NSString *const kSFAErrorLanguage = @"language";
NSString *const kSFADictCode = @"code";
NSString *const kSFADictValue = @"value";
NSString *const kSFADictLang = @"lang";
NSString *const kSFADictMessage = @"message";

@implementation SFAODataRequestError

- (NSString *)language {
    return self.userInfo[kSFAErrorLanguage];
}

+ (instancetype)errorWithDictionary:(NSDictionary *)errorDictionary response:(NSHTTPURLResponse *)response {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if ([errorDictionary[kSFADictMessage] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *errorDetailDict = (NSDictionary *)errorDictionary[kSFADictMessage];
        if (errorDetailDict[kSFADictValue]) {
            dictionary[kSFAErrorMessage] = errorDetailDict[kSFADictValue];
        }
        if (errorDetailDict[kSFADictLang]) {
            dictionary[kSFAErrorLanguage] = errorDetailDict[kSFADictLang];
        }
    }
    dictionary[kSFAErrorType] = [NSNumber numberWithInteger:SFAErrorTypeODataRequestError];
    
    SFAODataRequestError *error = [[[self class] alloc] initWithDomain:NSStringFromClass([self class]) code:response.statusCode
                                                              userInfo:[dictionary copy]];
                                                              
    error.errorCode = [NSString stringWithFormat:@"%@", errorDictionary[kSFADictCode]];
    return error;
}

- (NSString *)userFriendlyErrorMessage {
    return self.message;
}

@end
