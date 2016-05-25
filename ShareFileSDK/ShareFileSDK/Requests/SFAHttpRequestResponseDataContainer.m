@implementation SFAHttpRequestResponseDataContainer

- (instancetype)initWithRequest:(NSURLRequest *)request response:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *)error {
    self = [super init];
    if (self) {
        _request = request;
        _response = response;
        _data = data;
        _error = error;
    }
    return self;
}

- (instancetype)init {
    return [self initWithRequest:nil response:nil data:nil error:nil];
}

@end
