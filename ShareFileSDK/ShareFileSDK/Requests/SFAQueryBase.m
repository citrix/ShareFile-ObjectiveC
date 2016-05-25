#import "SFAQueryBaseProtected.h"
#import "NSString+sfapi.h"
#import "NSDate+sfapi.h"

@interface SFAQueryBase ()

@end

@implementation SFAQueryBase
{
    NSMutableArray *_subActions;
    NSMutableDictionary *_headerCollection;
}

#pragma mark - Protocol Property Synthesize

@synthesize httpMethod = _httpMethod; // has public setter
@synthesize body = _body;             // has public setter
@synthesize from = _entity;

//@synthesize subActions = _subActions;
- (NSArray *)subActions {
    return [_subActions copy];
}

@synthesize action = _action;

//@synthesize headers = _headers;
- (NSDictionary *)headers {
    return [_headerCollection copy];
}

@synthesize queryString = _queryString;
@synthesize ids = _ids;

#pragma mark - Temporary

- (void)setClient:(id <SFAClient> )client {
    _client = client;
}

#pragma mark - Public init

- (instancetype)init {
    return [self initWithClient:nil];
}

#pragma mark - Protected Code

- (instancetype)initWithClient:(id <SFAClient> )shareFileClient {
    self = [super init];
    if (self) {
        _client = shareFileClient;
        _queryString = [SFAODataParameterCollection new];
        _ids = [SFAODataParameterCollection new];
        _subActions = [NSMutableArray new];
        _headerCollection = [NSMutableDictionary new];
        _httpMethod = @"GET";
    }
    return self;
}

- (void)protectedSetShareFileClient:(id <SFAClient> )client {
    _client = client;
}

- (void)protectedAddId:(NSString *)ide {
    [self protectedAddIds:ide withKey:nil];
}

- (void)protectedAddIds:(NSString *)ide {
    [self protectedAddIds:ide withKey:nil];
}

- (void)protectedAddIds:(NSString *)ids withKey:(NSString *)key {
    SFAODataParameter *parameter = [[SFAODataParameter alloc] initWithKey:key value:ids];
    [_ids addOrUpdateObject:parameter];
}

- (void)protectedSetFrom:(NSString *)fromEntity {
    _entity = fromEntity;
}

- (void)protectedSetAction:(NSString *)action {
    if (!_action) {
        _action = [SFAODataAction new];
    }
    _action.actionName = action;
}

- (void)protectedAddActionIds:(NSString *)ide {
    [self protectedAddActionIds:ide withKey:nil];
}

- (void)protectedAddActionIds:(NSString *)ids withKey:(NSString *)key {
    if (!_action) {
        _action = [SFAODataAction new];
    }
    SFAODataParameter *parameter = [[SFAODataParameter alloc] initWithKey:key value:ids];
    [_action.parameters addOrUpdateObject:parameter];
}

- (void)protectedAddSubAction:(NSString *)subAction {
    [self protectedAddSubAction:subAction key:nil withValue:nil];
}

- (void)protectedAddSubAction:(NSString *)subAction withValue:(NSString *)ide {
    [self protectedAddSubAction:subAction key:nil withValue:ide];
}

- (void)protectedAddSubAction:(NSString *)subAction key:(NSString *)key withValue:(NSString *)ide {
    SFAODataAction *action = nil;
    for (SFAODataAction *act in _subActions) {
        if ([act.actionName caseInsensitiveCompare:subAction] == NSOrderedSame) {
            action = act;
            break;
        }
    }
    if (!action) {
        action = [SFAODataAction new];
        action.actionName = subAction;
        [_subActions addObject:action];
    }
    if (!(!ide || ide.length == 0)) {
        SFAODataParameter *parameter = [[SFAODataParameter alloc] initWithKey:key value:ide];
        [action.parameters addOrUpdateObject:parameter];
    }
}

- (void)protectedAddQueryString:(NSString *)key value:(NSString *)object {
    SFAODataParameter *parameter = [[SFAODataParameter alloc] initWithKey:key value:object];
    [_queryString addOrUpdateObject:parameter];
}

- (void)protectedAddQueryString:(NSString *)key object:(id <NSObject> )object {
    if ([object isKindOfClass:[NSDate class]]) {
        NSDate *date = (NSDate *)object;
        NSString *dateString = [date UTCStringRepresentation];
        [self protectedAddQueryString:key value:dateString];
    }
    else if ([object isKindOfClass:[[NSNumber numberWithBool:YES] class]]) {
        BOOL boolValue = ((NSNumber *)object).boolValue;
        [self protectedAddQueryString:key value:(boolValue ? @"True" : @"False")];
    }
    else {
        [self protectedAddQueryString:key value:[object description]];
    }
}

- (void)protectedAddHeaderWithKey:(NSString *)key value:(NSString *)value {
    _headerCollection[key] = value;
}

- (void)protectedSetBaseUrl:(NSURL *)url {
    NSString *baseUrlString;
    baseUrlString = [self protectedTryToGetUrlRootFrom:url];
    NSAssert(baseUrlString != nil, SFAFormatBaseUri);
    _baseUrl = [NSURL URLWithString:baseUrlString];
}

- (NSString *)protectedTryToGetUrlRootFrom:(NSURL *)providedUrl {
    NSArray *filteredComponents = [providedUrl.path componentsSeparatedByString:@"/" removeEmptyEntries:YES];
    if (filteredComponents.count > 2) {
        return [NSString stringWithFormat:@"%@://%@/%@/%@/", providedUrl.scheme, providedUrl.host, filteredComponents[0], filteredComponents[1]];
    }
    return nil;
}

#pragma mark - Public Code

- (void)setHttpMethod:(NSString *)httpMethod {
    _httpMethod = httpMethod;
}

- (void)setBody:(id <SFAHttpBodyDataProvider> )body {
    _body = body;
}

@end
