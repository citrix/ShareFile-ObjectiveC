#import "NSURLProtectionSpace+sfapi.h"

@implementation NSURLProtectionSpace (sfapi)

/**
 *  Return a NSURL representation for a given protection space
 */
- (NSURL *)urlRepresentation {
    return [[NSURL alloc] initWithScheme:self.protocol host:self.host path:@"/"];
}

@end
