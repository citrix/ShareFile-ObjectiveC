#import "SFIItemsEntity+sfapi.h"
#import "SFIEntityConstants.h"
#import "SFIHttpMethodConstants.h"

@implementation SFIItemsEntity (sfapi)

- (NSURL *)urlWithAlias:(NSString *)alias {
    NSString *url = [[self.client baseUrl] absoluteString];
    NSURL *aliasUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@(%@)", url, self.entity, alias]];
    return aliasUrl;
}

- (NSURL *)urlWithItemAlias:(SFAItemAlias)itemAlias {
    NSString *aliasString = [NSString stringWithUTF8String:ItemAliasCStrings[itemAlias]];
    return [self urlWithAlias:aliasString];
}

- (SFApiQuery *)copyWithUrl:(NSURL *)url targetid:(NSString *)targetid andMove:(NSNumber *)shouldMove {
    SFApiQuery *sfApiQuery = [[SFApiQuery alloc] initWithClient:self.client];
    
    [sfApiQuery setFrom:kSFEntities_Items];
    [sfApiQuery setAction:@"Copy"];
    [sfApiQuery addIds:url];
    [sfApiQuery addQueryString:@"targetid" withValue:targetid];
    [sfApiQuery addQueryString:@"ismove" withValue:shouldMove];
    [sfApiQuery setHttpMethod:kSFHttpMethodPOST];
    return sfApiQuery;
}

@end
