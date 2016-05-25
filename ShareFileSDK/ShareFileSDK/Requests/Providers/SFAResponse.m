#import "SFAResponse.h"

@implementation SFAResponse

+ (instancetype)createAction:(SFAEventHandlerResponse *)action {
    SFAResponse *response = [[[self class] alloc] init];
    [response setAction:action];
    return response;
}

+ (SFAResponse *)success {
    SFAResponse *response = [[[self class] alloc] init];
    return response;
}

+ (SFAResponse *)createSuccess:(id)value {
    SFAResponse *response = [[[self class] alloc] init];
    [response setValue:value];
    return response;
}

@end
