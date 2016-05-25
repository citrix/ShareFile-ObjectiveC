// Objective-C method for composing a HTTP multipart/form-data body.
// Provide parameters and data in a NSDictionary. Outputs a NSData request body.
// License: Public Domain
// Author:  Leonard van Driel, 2012

#import "SFAHttpRequestUtils.h"

@implementation SFAHttpRequestUtils

#pragma mark - Content - type : application / x - www - form - urlencoded

+ (void)addFormDataWithParameters:(NSDictionary *)parameters toURLRequest:(NSMutableURLRequest *)request {
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    NSString *query = [self joinQueryWithDictionary:parameters];
    request.HTTPBody = [query dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Content - type : multipart / form - data

+ (void)addMultipartDataWithParameters:(NSDictionary *)parameters toURLRequest:(NSMutableURLRequest *)request {
    NSString *boundary = nil;
    NSData *post = [self multipartDataWithParameters:parameters boundary:&boundary];
    [request setValue:[@"multipart/form-data; boundary=" stringByAppendingString:boundary] forHTTPHeaderField:@"Content-type"];
    request.HTTPBody = post;
}

+ (NSData *)multipartDataWithParameters:(NSDictionary *)parameters boundary:(NSString **)boundary {
    NSMutableData *result = [[NSMutableData alloc] init];
    if (boundary && !*boundary) {
        char buffer[32];
        for (NSUInteger i = 0; i < 32; i++)
            buffer[i] = "0123456789ABCDEF"[rand() % 16];
        NSString *random = [[NSString alloc] initWithBytes:buffer length:32 encoding:NSASCIIStringEncoding];
        *boundary = [NSString stringWithFormat:@"MyApp--%@", random];
    }
    NSData *newline = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *boundaryData = [[NSString stringWithFormat:@"--%@\r\n", boundary ? *boundary : @""] dataUsingEncoding:NSUTF8StringEncoding];
    
    for (NSArray *pair in[self flatten:parameters]) {
        [result appendData:boundaryData];
        [self appendToMultipartData:result key:pair[0] value:pair[1]];
        [result appendData:newline];
    }
    NSString *end = [NSString stringWithFormat:@"--%@--\r\n", boundary ? *boundary : @""];
    [result appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    return result;
}

+ (void)appendToMultipartData:(NSMutableData *)data key:(NSString *)key value:(id)value {
    if ([value isKindOfClass:NSData.class]) {
        NSString *name = key;
        if ([key rangeOfString:@"%2F"].length) {
            NSRange r = [name rangeOfString:@"%2F"];
            key = [key substringFromIndex:r.location + r.length];
            name = [name substringToIndex:r.location];
        }
        NSString *string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", name, key];
        [data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
        [data appendData:value];
    }
    else {
        NSString *string = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, value];
        [data appendData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

#pragma mark - URL

+ (NSString *)urlWithBase:(NSString *)root path:(NSArray *)path query:(NSDictionary *)query {
    NSMutableString *result = [[NSMutableString alloc] initWithString:root];
    if (path) {
        if (![result hasSuffix:@"/"])
            [result appendString:@"/"];
        [result appendString:[self joinPathWithArray:path]];
    }
    if (query) {
        if (![result rangeOfString:@"?"].length)
            [result appendString:@"?"];
        else if (![result hasSuffix:@"?"] && ![result hasSuffix:@"&"])
            [result appendString:@"&"];
        [result appendString:[self joinQueryWithDictionary:query]];
    }
    return result;
}

+ (NSString *)joinPathWithArray:(NSArray *)array {
    NSMutableString *result = [[NSMutableString alloc] init];
    for (id component in array) {
        if (result.length)
            [result appendString:@"/"];
        [result appendString:[self escape:[component description]]];
    }
    return result;
}

+ (NSString *)joinQueryWithDictionary:(NSDictionary *)dictionary {
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSArray *pair in[self flatten:dictionary]) {
        if (result.length)
            [result appendString:@"&"];
        [result appendString:pair[0]];
        [result appendString:@"="];
        [result appendString:[self escape:[pair[1] description]]];
    }
    return result;
}

+ (NSDictionary *)splitQueryWithString:(NSString *)string {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *pair in[string componentsSeparatedByString:@"&"]) {
        NSRange r = [pair rangeOfString:@"="];
        if (r.location == NSNotFound) {
            result[[self unescape:pair]] = @"";
        }
        else {
            NSString *value = [self unescape:[pair substringFromIndex:r.location + r.length]];
            result[[self unescape:[pair substringToIndex:r.location]]] = value;
        }
    }
    return result;
}

#pragma mark - Helpers

+ (NSString *)unescape:(NSString *)string {
    return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)string, CFSTR(""), kCFStringEncodingUTF8));
}

+ (NSString *)escape:(NSString *)string {
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, NULL, CFSTR("*'();:@&=+$,/?!%#[]"), kCFStringEncodingUTF8));
}

+ (NSArray *)flatten:(NSDictionary *)dictionary {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:dictionary.count];
    NSArray *keys = [dictionary.allKeys sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in keys) {
        id value = [dictionary objectForKey:key];
        if ([value isKindOfClass:NSArray.class] || [value isKindOfClass:NSSet.class]) {
            NSString *k = [[self escape:key] stringByAppendingString:@"[]"];
            for (id v in value) {
                [result addObject:@[k, v]];
            }
        }
        else if ([value isKindOfClass:NSDictionary.class]) {
            for (NSString *k in value) {
                NSString *kk = [[self escape:key] stringByAppendingFormat:@"[%@]", [self escape:k]];
                [result addObject:@[kk, [value valueForKey:k]]];
            }
        }
        else {
            [result addObject:@[[self escape:key], value]];
        }
    }
    return result;
}

@end
