#import "NSURLProtectionSpace+sfapi.h"

@implementation NSURLProtectionSpace (sfapi)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
/**
 *  Return a NSURL representation for a given protection space
 */
- (NSURL *)urlRepresentation {
    return [[NSURL alloc] initWithScheme:self.protocol host:self.host path:@"/"];
}
#pragma clang diagnostic pop
@end
