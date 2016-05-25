#import "NSURL+sfapi.h"
#import "NSString+sfapi.h"

@implementation NSURL (sfapi)

- (NSString *)authority {
    if (self.port != nil) {
        return [NSString stringWithFormat:@"%@:%@", self.host, self.port];
    }
    else {
        return self.host;
    }
}

- (NSString *)getAuthority {
    if (self.scheme != nil) {
        return [NSString stringWithFormat:@"%@://%@", self.scheme, self.host];
    }
    else {
        return self.host;
    }
}

- (NSNumber *)portWithHTTPSchemeDefaults {
    NSNumber *urlPortNumber = [self port];
    NSUInteger urlPort = 0;
    if (!urlPortNumber) {
        NSString *lowerScheme = self.scheme.lowercaseString;
        if (lowerScheme.length > 0) {
            if ([lowerScheme isEqualToString:NSURLProtectionSpaceHTTPS]) {
                urlPort = 443;
            }
            else if ([lowerScheme isEqualToString:NSURLProtectionSpaceHTTP]) {
                urlPort = 80;
            }
            else if ([lowerScheme isEqualToString:NSURLProtectionSpaceFTP]) {
                urlPort = 21;
            }
        }
        
        urlPortNumber = [NSNumber numberWithUnsignedInteger:urlPort];
    }
    return urlPortNumber;
}

- (NSURLProtectionSpace *)protectionSpaceWithAuthenticationMethod:(NSString *)authenticationMethod realm:(NSString *)realm isProxy:(BOOL)isProxy {
    NSString *mRelm = realm.lowercaseString;
    NSString *protocol = nil;
    NSString *lowerScheme = self.scheme.lowercaseString;
    if ([lowerScheme isEqualToString:@"http"]) {
        protocol = NSURLProtectionSpaceHTTP;
    }
    else if ([lowerScheme isEqualToString:@"https"]) {
        protocol = NSURLProtectionSpaceHTTPS;
    }
    else if ([lowerScheme isEqualToString:@"ftp"]) {
        protocol = NSURLProtectionSpaceFTP;
    }
    else {
        protocol = lowerScheme;
    }
    
    NSNumber *port = [self portWithHTTPSchemeDefaults];
    
    NSURLProtectionSpace *result = nil;
    if (isProxy) {
        result = [[NSURLProtectionSpace alloc] initWithProxyHost:self.host.lowercaseString port:[port integerValue] type:[protocol isEqualToString:NSURLProtectionSpaceHTTPSProxy] ? NSURLProtectionSpaceHTTPSProxy : NSURLProtectionSpaceHTTPProxy realm:mRelm authenticationMethod:authenticationMethod];
    }
    else {
        result = [[NSURLProtectionSpace alloc] initWithHost:self.host.lowercaseString port:[port integerValue] protocol:protocol realm:mRelm authenticationMethod:authenticationMethod];
    }
    
    return result;
}

@end
