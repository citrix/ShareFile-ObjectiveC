#import "ShareFileSDKTests.h"
#import "ShareFileSDKTestsProtected.h"

@implementation ShareFileSDKTests

- (void)setUp {
    [super setUp];
    self.client = [[SFAClient alloc] initWithBaseUrl:@"https://secure.sf-api.com/sf/v3/" andConfiguration:[SFAConfiguration defaultConfiguration]];
    
    self.authHandler = [[SFASDKAuthHandler alloc] init];
    self.client.authHandler = self.authHandler;
}

- (void)tearDown {
    extern void __gcov_flush(void);
    
    __gcov_flush();
    self.client = nil;
    self.authHandler = nil;
    [super tearDown];
}

#pragma mark - Helper Function(s)

- (NSArray *)navigationURLsArrayWithCount:(int)count {
    NSMutableArray *array = [NSMutableArray new];
    
    for (int i = 0; i < count; i++) {
        [array addObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://secure.sharefile.com/oauth/oauthtest%d.aspx", i]]];
    }
    return [array copy];
}

- (NSURL *)OAuthCompleteUriWithParametersFromDictionary:(NSDictionary *)dictionary {
    NSURL *baseOAuthComplete = [self OAuthCompleteURL];
    NSMutableString *ms = [NSMutableString new];
    [ms appendString:baseOAuthComplete.absoluteString];
    [ms appendString:@"?"];
    for (NSString *key in dictionary) {
        [ms appendFormat:@"%@=%@&", key, dictionary[key]];
    }
    return [NSURL URLWithString:[[ms copy] trimEndChar:'&']];
}

- (NSURL *)OAuthCompleteURL {
    return [NSURL URLWithString:@"https://secure.sharefile.com/oauth/oauthcomplete.aspx"];
}

- (NSString *)joinByAmpersandSeparatingCollection:(SFAODataParameterCollection *)collection {
    return [self joinBy:@"&" collection:collection];
}

- (NSString *)joinByCommaSeparatingCollection:(SFAODataParameterCollection *)collection {
    return [self joinBy:@"," collection:collection];
}

- (NSString *)joinBy:(NSString *)charater collection:(SFAODataParameterCollection *)collection {
    NSMutableString *mString = [NSMutableString new];
    id <NSFastEnumeration> enumerable = [collection collectionAsFastEnumrable];
    for (SFAODataParameter *param in enumerable) {
        [mString appendString:[self joinByCommaSeparatingParam:param]];
        [mString appendString:charater];
    }
    if (mString.length > 0) {
        return [mString substringToIndex:mString.length - 1];
    }
    return @"";
}

- (NSString *)joinByCommaSeparatingParam:(SFAODataParameter *)param {
    NSMutableString *mString = [NSMutableString new];
    if (!param.key) {
        [mString appendString:param.value];
    }
    else {
        [mString appendFormat:@"%@=%@", param.key, param.value];
    }
    return [mString copy];
}

- (BOOL)compareObjectsInDictionary:(NSDictionary *)dict1 toDictionary:(NSDictionary *)dict2 {
    for (NSString *key in dict1) {
        if (!dict2[key]) {
            return NO;
        }
        id obj1 = [dict1[key] copy];
        id obj2 = [dict2[key] copy];
        if ([obj1 isKindOfClass:[NSDictionary class]] && [obj2 isKindOfClass:[NSDictionary class]]) {
            if (![self compareObjectsInDictionary:obj1 toDictionary:obj2]) {
                return NO;
            }
        }
        else if ([obj1 isKindOfClass:[NSArray class]] && [obj2 isKindOfClass:[NSArray class]]) {
            if (![self compareObjectsInArray:obj1 toArray:obj2]) {
                return NO;
            }
        }
        else if (![obj1 isEqual:obj2]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)compareObjectsInArray:(NSArray *)array1 toArray:(NSArray *)array2 {
    if (array1.count != array2.count) {
        return NO;
    }
    for (int i = 0; i < array1.count; i++) {
        id obj1 = [array1[i] copy];
        id obj2 = [array2[i] copy];
        if ([obj1 isKindOfClass:[NSDictionary class]] && [obj2 isKindOfClass:[NSDictionary class]]) {
            if (![self compareObjectsInDictionary:obj1 toDictionary:obj2]) {
                return NO;
            }
        }
        else if ([obj1 isKindOfClass:[NSArray class]] && [obj2 isKindOfClass:[NSArray class]]) {
            if (![self compareObjectsInArray:obj1 toArray:obj2]) {
                return NO;
            }
        }
        else if (![obj1 isEqual:obj2]) {
            return NO;
        }
    }
    return YES;
}

@end
