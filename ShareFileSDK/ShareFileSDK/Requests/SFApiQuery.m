#import "SFApiQueryProtected.h"
#import "SFAQueryBaseProtected.h"
#import "NSString+sfapi.h"
#import "SFAModelClassMapper.h"

@implementation SFApiQuery
{
    NSMutableArray *_selectProperties;
    NSMutableArray *_expandProperties;
}

#pragma mark - SFAQuery Properties Synthesize

@synthesize responseClass = _responseClass;

- (Class)responseClass {
    return [SFAModelClassMapper mappedModelClassForDefaultModelClass:_responseClass];
}

@synthesize isODataFeed = _isODataFeed;

#pragma mark - SFAReadOnlyODataQuery Protocol Properties Synthesize

- (NSArray *)selectProperties {
    return [_selectProperties copy];
}

- (NSArray *)expandProperties {
    return [_expandProperties copy];
}

@synthesize skip = _skip;
@synthesize top = _top;

- (id <SFAFilter> )filter {
    if (_filterCriteria.count > 0) {
        return _filterCriteria.firstObject;
    }
    return nil;
}

#pragma mark - Public Functions

- (instancetype)initWithClient:(id <SFAClient> )shareFileClient {
    self = [super initWithClient:shareFileClient];
    if (self) {
        _selectProperties = [NSMutableArray new];
        _expandProperties = [NSMutableArray new];
        _filterCriteria = [NSMutableArray new];
        _skip = 0;
        _top = -1;
    }
    return self;
}

- (SFApiQuery *)addIds:(id <NSObject> )ids {
    if ([ids isKindOfClass:[NSURL class]]) {
        [self protectedAddIds:((NSURL *)ids).absoluteString];
    }
    else if ([ids isKindOfClass:[NSString class]]) {
        [self protectedAddIds:((NSString *)ids)];
    }
    else if ([ids isKindOfClass:[NSObject class]]) {
        [self protectedAddIds:[NSString stringWithFormat:@"%@", ids]];
    }
    else {
        NSAssert(NO, SFAFormatIds);
    }
    return self;
}

- (SFApiQuery *)addStringIds:(NSString *)ids withKey:(NSString *)key {
    [self protectedAddIds:ids withKey:key];
    return self;
}

- (SFApiQuery *)setFrom:(NSString *)fromEntity {
    [self protectedSetFrom:fromEntity];
    return self;
}

- (SFApiQuery *)setAction:(NSString *)action {
    [self protectedSetAction:action];
    return self;
}

- (SFApiQuery *)addActionIds:(NSString *)ids {
    [self protectedAddActionIds:ids];
    return self;
}

- (SFApiQuery *)addActionIds:(NSString *)ids withKey:(NSString *)key {
    [self protectedAddActionIds:ids withKey:key];
    return self;
}

- (SFApiQuery *)addSubAction:(NSString *)subAction {
    [self protectedAddSubAction:subAction];
    return self;
}

- (SFApiQuery *)addSubAction:(NSString *)subAction withValue:(NSString *)ide {
    [self protectedAddSubAction:subAction withValue:ide];
    return self;
}

- (SFApiQuery *)addSubAction:(NSString *)subAction key:(NSString *)key withValue:(NSString *)ide {
    [self protectedAddSubAction:subAction key:key withValue:ide];
    return self;
}

- (SFApiQuery *)addQueryString:(NSString *)queryString withValue:(id <NSObject> )value {
    if ([value isKindOfClass:[NSString class]]) {
        [self protectedAddQueryString:queryString value:(NSString *)value];
    }
    else {
        [self protectedAddQueryString:queryString object:value];
    }
    return self;
}

- (SFApiQuery *)addUrl:(NSURL *)url {
    [self protectedAddIds:url.absoluteString];
    return self;
}

#pragma mark - IQuery Protocol Functions

- (SFApiQuery *)filterBy:(id <SFAFilter> )filter {
    [self.filterCriteria removeAllObjects];
    [self.filterCriteria addObject:filter];
    return self;
}

- (SFApiQuery *)expandProperty:(NSString *)expandProperty {
    return [self expandProperties:[expandProperty componentsSeparatedByString:@"," removeEmptyEntries:YES]];
}

- (SFApiQuery *)expandProperties:(NSArray *)expandProperties {
    [_expandProperties addObjectsFromArray:expandProperties];
    return self;
}

- (SFApiQuery *)selectProperty:(NSString *)selectProperty {
    return [self selectProperties:[selectProperty componentsSeparatedByString:@"," removeEmptyEntries:YES]];
}

- (SFApiQuery *)selectProperties:(NSArray *)selectProperties {
    [_selectProperties addObjectsFromArray:selectProperties];
    return self;
}

- (SFApiQuery *)orderByProperty:(NSString *)orderByProperty {
    _orderBy = orderByProperty;
    return self;
}

- (SFApiQuery *)skip:(int)skip {
    _skip = skip;
    return self;
}

- (SFApiQuery *)top:(int)top {
    _top = top;
    return self;
}

- (SFApiQuery *)addHeaderWithKey:(NSString *)key value:(NSString *)value;
{
    [self protectedAddHeaderWithKey:key value:value];
    return self;
}

- (SFApiQuery *)setBaseUrl:(NSURL *)url {
    [self protectedSetBaseUrl:url];
    return self;
}

- (id <SFATransferTask> )executeAsyncWithCallbackQueue:(NSOperationQueue *)callbackQueue completionCallback:(SFATaskCompletionCallback)completionCallback cancelCallback:(SFATaskCancelCallback)cancelCallback {
    if (!self.client) {
        NSAssert(NO, @"Query can not be executed as client is nil.");
    }
    return [self.client executeQueryAsync:self callbackQueue:callbackQueue completionCallback:completionCallback cancelCallback:cancelCallback];
}

@end
