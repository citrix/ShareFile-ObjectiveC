#import "NSString+sfapi.h"
#import "SFAHttpRequestUtils.h"

@implementation NSString (sfapi)

- (NSArray *)componentsSeparatedByString:(NSString *)string removeEmptyEntries:(BOOL)removeEmptyEntries {
    NSMutableArray *components = [[self componentsSeparatedByString:string] mutableCopy];
    NSMutableArray *filteredComponents = [NSMutableArray new];
    if (removeEmptyEntries) {
        for (NSString *component in components) {
            if (component.length > 0) {
                [filteredComponents addObject:component];
            }
        }
    }
    else {
        filteredComponents = components;
    }
    return [filteredComponents copy];
}

- (NSString *)escapeString {
    return [SFAHttpRequestUtils escape:self];
}

- (NSDictionary *)queryStringDictionary {
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSArray *keyValuePairs = [self componentsSeparatedByString:@"&" removeEmptyEntries:YES];
    for (NSString *kvp in keyValuePairs) {
        NSArray *elts = [kvp componentsSeparatedByString:@"="];
        if (elts.count < 1) {
            continue;
        }
        else if (elts.count == 1) {
            params[elts[0]] = [NSNull null];
        }
        else {
            params[elts[0]] = elts[1];
        }
    }
    return [params copy];
}

- (NSString *)trimEndChar:(char)c {
    if (self.length > 0 && [self characterAtIndex:self.length - 1] == c) {
        return [self substringToIndex:self.length - 1];
    }
    else {
        return [self copy];
    }
}

- (NSURL *)URL {
    NSURL *url = nil;
    @try {
        url = [NSURL URLWithString:self];
		if (!url || !(url.host.length > 0) || !(url.scheme.length > 0)) {
            url = nil;
        }
    }
    @catch (NSException *ex)
    {
        url = nil;
    }
    return url;
}

- (BOOL)isValidURL {
    NSURL *url = [self URL];
    if (url) {
        return YES;
    }
    return NO;
}

- (void)addHttpBodyDataForMutableRequest:(NSMutableURLRequest *)request {
    request.HTTPBody = [self dataUsingEncoding:NSUTF8StringEncoding];
    if (request.HTTPBody.length > 0) {
        [request setValue:SFAApplicationJson forHTTPHeaderField:SFAContentType];
    }
}

@end
