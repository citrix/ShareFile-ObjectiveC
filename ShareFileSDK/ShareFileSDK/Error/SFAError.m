NSString *const kSFAErrorMessage = @"mesage";
NSString *const kSFAErrorType = @"errorType";

@implementation SFAError

- (SFAErrorType)errorType {
    return ((NSNumber *)self.userInfo[kSFAErrorType]).intValue;
}

+ (instancetype)errorWithMessage:(NSString *)message type:(SFAErrorType)errorType;
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if (message) {
        dictionary[kSFAErrorMessage] = message;
    }
    dictionary[kSFAErrorType] = [NSNumber numberWithInteger:errorType];
    return [[[self class] alloc] initWithDomain:NSStringFromClass([self class]) code:0 userInfo:[dictionary copy]];
}

+ (instancetype)errorWithMessage:(NSString *)message type:(SFAErrorType)errorType domain:(NSString *)domain code:(NSInteger)code userInfo:(NSDictionary *)dict {
    return [self errorWithMessage:message type:errorType domain:domain code:code underlyingError:nil userInfo:dict];
}

+ (instancetype)errorWithMessage:(NSString *)message type:(SFAErrorType)errorType domain:(NSString *)domain code:(NSInteger)code underlyingError:(NSError *)error userInfo:(NSDictionary *)dict {
    NSMutableDictionary *userInfoDict = [dict mutableCopy];
    if (!userInfoDict) {
        userInfoDict = [NSMutableDictionary new];
    }
    if (message) {
        userInfoDict[kSFAErrorMessage] = message;
    }
    if (error) {
        userInfoDict[NSUnderlyingErrorKey] = error;
    }
    userInfoDict[kSFAErrorType] = [NSNumber numberWithInteger:errorType];
    
    return [[[self class] alloc] initWithDomain:domain code:code userInfo:[userInfoDict copy]];
}

- (NSError *)underlyingError {
    return self.userInfo[NSUnderlyingErrorKey];
}

- (NSString *)userFriendlyErrorMessage {
    return self.underlyingError.localizedFailureReason ? : self.underlyingError.localizedDescription ? : self.message;
}

- (NSString *)message {
    return self.userInfo[kSFAErrorMessage];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n%@:%@\n%@:%ld\n%@:%ld\n%@:%@ : %@", SFADomain, self.domain, SFAType, (long)self.errorType, SFACode, (long)self.code, SFAMessage, self.message, [self userFriendlyErrorMessage]];
}

@end
