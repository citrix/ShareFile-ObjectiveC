@implementation SFAEventHandlerResponse

+ (SFAEventHandlerResponse *)eventHandlerResponseWithRedirection:(SFIRedirection *)redir {
    SFAEventHandlerResponse *response = [[SFAEventHandlerResponse alloc] init];
    [response setAction:SFAEventHandlerResponseActionRedirect];
    [response setRedirection:redir];
    return response;
}

+ (SFAEventHandlerResponse *)eventHandlerResponseWithAction:(SFAEventHandlerResponseAction)action {
    SFAEventHandlerResponse *response = [[SFAEventHandlerResponse alloc] init];
    [response setAction:action];
    return response;
}

+ (SFAEventHandlerResponse *)failWithErrorEventResponseHandler {
    static SFAEventHandlerResponse *throwResposeHandler;
    
    if (!throwResposeHandler) {
        throwResposeHandler = [SFAEventHandlerResponse eventHandlerResponseWithAction:SFAEventHandlerResponseActionFailWithError];
    }
    return throwResposeHandler;
}

+ (SFAEventHandlerResponse *)ignoreEventResponseHandler {
    static SFAEventHandlerResponse *ignoreResposeHandler;
    if (!ignoreResposeHandler) {
        ignoreResposeHandler = [SFAEventHandlerResponse eventHandlerResponseWithAction:SFAEventHandlerResponseActionIgnore];
    }
    return ignoreResposeHandler;
}

@end
