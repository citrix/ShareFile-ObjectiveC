#import "SFAOAuthService.h"
#import "NSString+sfapi.h"

@implementation SFAOAuthService

@synthesize clientId = _clientId;
@synthesize clientSecret = _clientSecret;

- (instancetype)initWithSFAClient:(id <SFAClient> )client clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret {
    self = [super init];
    if (self) {
        NSAssert(client != nil, @"Passed parameter client can not be nil");
        NSAssert(clientId != nil, @"Passed parameter clientId can not be nil");
        _client = client;
        _clientId = clientId;
        _clientSecret = clientSecret;
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"init is not supported for:%@", NSStringFromClass([self class]));
    return nil;
}

- (SFApiQuery *)oAuthQueryForApplicationControlPlane:(NSString *)applicationControlPlane formData:(NSDictionary *)formData subdomain:(NSString *)subdomain {
    NSAssert(applicationControlPlane != nil, @"Passed parameter applicationControlPlane can not be nil");
    NSAssert(_client != nil, @"Property client can not be nil");
    if (!subdomain) {
        subdomain = @"secure";
    }
    NSMutableString *url = [NSMutableString new];
    [url appendFormat:@"https://%@.%@/oauth/token", subdomain, applicationControlPlane];
    SFApiQuery *oauthTokenQuery = [[SFApiQuery alloc] initWithClient:_client];
    [oauthTokenQuery addIds:url];
    [oauthTokenQuery addQueryString:SFARequirev3 withValue:@"true"];
    oauthTokenQuery.body = formData;
    oauthTokenQuery.httpMethod = SFAPost;
    oauthTokenQuery.responseClass = [SFAOAuthToken class];
    return oauthTokenQuery;
}

- (SFApiQuery *)tokenQueryFromAuthorizationCode:(SFAOAuthAuthorizationCode *)code {
    NSAssert(code != nil, @"Passed parameter code can not be nil");
    NSAssert(_clientId != nil, @"Property clientId can not be nil");
    NSAssert(_clientSecret != nil, @"Property clientSecret can not be nil");
    return [self oAuthQueryForApplicationControlPlane:code.applicationControlPlane formData:@{ SFAClientId : _clientId, SFAClientSecret : _clientSecret, SFACode : code.code, SFAGrantType : SFAAuthorizationCode } subdomain:code.subdomain];
}

- (SFApiQuery *)refreshOAuthTokenQuery:(SFAOAuthToken *)token {
    NSAssert(token != nil, @"Passed parameter token can not be nil");
    NSAssert(_clientId != nil, @"Property clientId can not be nil");
    NSAssert(_clientSecret != nil, @"Property clientSecret can not be nil");
    return [self oAuthQueryForApplicationControlPlane:token.applicationControlPlane formData:@{ SFAClientId : _clientId, SFAClientSecret : _clientSecret, SFARefreshToken : token.refreshToken, SFAGrantType : SFARefreshToken } subdomain:token.subdomain];
}

- (SFApiQuery *)tokenQueryFromSamlAssertion:(NSString *)samlAssertion subdomain:(NSString *)subdomain applicationControlPlane:(NSString *)applicationControlPlane {
    NSAssert(samlAssertion != nil, @"Passed parameter samlAssertion can not be nil");
    NSAssert(_clientId != nil, @"Property clientId can not be nil");
    NSAssert(_clientSecret != nil, @"Property clientSecret can not be nil");
    return [self oAuthQueryForApplicationControlPlane:applicationControlPlane formData:@{ SFAClientId : _clientId, SFAClientSecret : _clientSecret, SFAAssertion : samlAssertion, SFAGrantType : @"urn:ietf:params:oauth:grant-type:saml2-bearer" } subdomain:subdomain];
}

- (SFApiQuery *)passwordGrantRequestQueryForUsername:(NSString *)username password:(NSString *)password subdomain:(NSString *)subdomain applicationControlPlane:(NSString *)applicationControlPlane {
    NSAssert(username != nil, @"Passed parameter username can not be nil");
    NSAssert(password != nil, @"Passed parameter password can not be nil");
    NSAssert(_clientId != nil, @"Property clientId can not be nil");
    NSAssert(_clientSecret != nil, @"Property clientSecret can not be nil");
    return [self oAuthQueryForApplicationControlPlane:applicationControlPlane formData:@{ SFAClientId : _clientId, SFAClientSecret : _clientSecret, SFAGrantType : SFAPassword, SFAUsername : username, SFAPassword : password } subdomain:subdomain];
}

- (NSString *)authorizationUrlForDomain:(NSString *)domain responseType:(NSString *)responseType clientId:(NSString *)clientId redirectUrl:(NSString *)redirectUrl state:(NSString *)state additionalQueryParams:(NSDictionary *)additionalQueryParams subdomain:(NSString *)subdomain {
    NSAssert(domain != nil, @"Passed parameter domain can not be nil");
    NSAssert(responseType != nil, @"Passed parameter responseType can not be nil");
    if (!clientId) {
        if (!_clientId) {
            clientId = _clientId;
        }
        else {
            NSAssert(clientId != nil, @"Passed parameter clientId can not be nil");
        }
    }
    NSAssert(redirectUrl != nil, @"Passed parameter redirectUrl can not be nil");
    NSAssert(state != nil, @"Passed parameter state can not be nil");
    NSString *additionalQueryString = @"";
    if (additionalQueryParams) {
        NSMutableString *string = [NSMutableString new];
        for (NSString *key in additionalQueryParams) {
            [string appendFormat:@"%@=%@&", key, additionalQueryParams[key]];
        }
        if (string.length > 0) {
            additionalQueryString = [string substringToIndex:string.length - 1];
        }
    }
    if (!subdomain) {
        subdomain = @"secure";
    }
    NSMutableString *url = [NSMutableString new];
    [url appendFormat:@"https://%@.%@/oauth/"
     "authorize?response_type=%@&client_id=%@&redirect_uri=%@&"
     "state=%@",
     subdomain, domain, [responseType escapeString], [clientId escapeString], [redirectUrl escapeString], [state escapeString]];
    if (additionalQueryString.length > 0) {
        [url appendFormat:@"&%@", additionalQueryString];
    }
    return [url copy];
}

@end
