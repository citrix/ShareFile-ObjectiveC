#import "SFABaseAuthHandlerProtected.h"
#import "SFASDKAuthHandlerProtected.h"

#import "SFAuthenticationContext.h"
#import "SFAOAuth2Credential.h"
#import "SFAOAuthService.h"
#import "SFAHttpTask.h"
#import "SFAConsumerConnectorAuthParser.h"
#import "SFABearerAuthParser.h"


@implementation SFASDKAuthHandler

- (instancetype)initWithOAuthService:(SFAOAuthService *)oauthService {
    self = [super init];
    if (self) {
        self.oauthService = oauthService;
    }
    return self;
}

- (void)internalInit {
    [super internalInit];
    self.authTasks = [NSMutableDictionary dictionary];
    self.lock = [NSObject new];
    self.credentialStore = [[SFACredentialCache alloc] init]; // Default credential store if none is provided
    
    [self registerAuthChallengeParser:NSStringFromClass([SFABearerAuthParser class])];
    [self registerAuthChallengeParser:NSStringFromClass([SFAConsumerConnectorAuthParser class])];
}

#pragma mark - Method overrides

- (SFAAuthHandling_ResponseResult)processUnauthorizedReponse:(SFAHttpRequestResponseDataContainer *)httpContainer
                                                 authContext:(SFAuthenticationContext *)authContext {
    SFAAuthHandling_ResponseResult result = [super processUnauthorizedReponse:httpContainer authContext:authContext];
    
    if (result == SFAAuthHandling_Continue && !authContext.backgroundRequest) {
        NSURLCredential *usedCredential = authContext.lastAppliedCredential;
        BOOL appliedCredential = [self isRealCredential:usedCredential];
        NSURLCredential *validOrInvalidCredential = [self credentialForRequest:httpContainer.request authContext:authContext wasChallenged:YES includeInvalid:YES];
        
        // Failed, can we refresh?
        if ([self canRefreshCredential:validOrInvalidCredential] &&
            ((!appliedCredential && authContext.challengeCount == 1) || (appliedCredential && authContext.challengeCount == 2))) {
            result = SFAAuthHandling_BackgroundAuth;
        }
        // Is this an interactive challenge? We could get assistance elsewhere
        else if ([authContext.interactiveHandler canHandleInteractiveUnauthorizedResponse:httpContainer authContext:authContext]) {
            result = SFAAuthHandling_Interactive;
        }
    }
    
    return result;
}

- (BOOL)internalHandleUnauthorizedResponse:(SFAHttpRequestResponseDataContainer *)httpContainer
                               authContext:(SFAuthenticationContext *)authContext
                         completionHandler:(void (^)(SFAAuthHandling_ResponseResult))completionHandler {
    BOOL authHandled = [super internalHandleUnauthorizedResponse:httpContainer authContext:authContext completionHandler:completionHandler];
    
    if (!authHandled && !authContext.backgroundRequest) {
        NSURLCredential *usedCredential = authContext.lastAppliedCredential;
        NSURLCredential *validOrInvalidCredential = [self credentialForRequest:httpContainer.request authContext:authContext wasChallenged:YES includeInvalid:YES];
        
        // Keep track of the most recent available cred, whether we decided to use it or not.
        // An interactive handler may want to use this to fill in an existing username, for instance.
        authContext.lastCandidateCredential = validOrInvalidCredential;
        
        BOOL appliedCredential = [self isRealCredential:usedCredential];
        if ([self canRefreshCredential:validOrInvalidCredential] &&
            ((!appliedCredential && authContext.challengeCount == 1) || (appliedCredential && authContext.challengeCount == 2))) {
            [self refreshCredential:validOrInvalidCredential forAuthContext:authContext completionHandler:completionHandler];
            authHandled = YES;
        }
        else if ([self canHandleInteractiveResponse:httpContainer authContext:authContext]) {
            authHandled = [self handleInteractiveResponse:httpContainer authContext:authContext completionHandler:completionHandler];
        }
    }
    
    return authHandled;
}

#pragma mark - Interactive Challenges
- (BOOL)canHandleInteractiveResponse:(SFAHttpRequestResponseDataContainer *)httpContainer
                         authContext:(SFAuthenticationContext *)authContext {
    if ([authContext.interactiveHandler respondsToSelector:@selector(canHandleInteractiveUnauthorizedResponse:authContext:)]) {
        return [authContext.interactiveHandler canHandleInteractiveUnauthorizedResponse:httpContainer authContext:authContext];
    }
    return NO;
}

- (BOOL)handleInteractiveResponse:(SFAHttpRequestResponseDataContainer *)httpContainer
                      authContext:(SFAuthenticationContext *)authContext
                completionHandler:(void (^)(SFAAuthHandling_ResponseResult))completionHandler {
    if ([authContext.interactiveHandler respondsToSelector:@selector(canHandleInteractiveUnauthorizedResponse:authContext:)]) {
        return [authContext.interactiveHandler handleInteractiveUnauthorizedResponse:httpContainer authContext:authContext completionHandler: ^(SFIURLAuthChallengeDisposition disposition, NSURLCredential *credential) {
                    SFAAuthHandling_ResponseResult handlerResult = SFAAuthHandling_Continue;
                    switch (disposition) {
                        case SFIURLAuthChallengeUseCredential:
                            [authContext.interactiveCredentialCache addCredential:credential forUrl:httpContainer.request.URL authType:nil];
                            handlerResult = SFAAuthHandling_Retry;
                            break;
                            
                        case SFIURLAuthChallengeCancelAuthenticationChallenge:
                            handlerResult = SFAAuthHandling_Cancel;
                            break;
                            
                        default:
                            break;
                    }
                    
                    if (completionHandler) {
                        completionHandler(handlerResult);
                    }
                }];
    }
    return NO;
}

#pragma mark - Auth Refresh
- (BOOL)canRefreshCredential:(NSURLCredential *)cred {
    // OAuth only for now
    return self.oauthService && [self isRealCredential:cred] && [cred isKindOfClass:[SFAOAuth2Credential class]] && ((SFAOAuth2Credential *)cred).oAuthToken.refreshToken != nil;
}

- (void)refreshCredential:(NSURLCredential *)credential
           forAuthContext:(SFAuthenticationContext *)context
        completionHandler:(void (^)(SFAAuthHandling_ResponseResult))completionHandler {
    SFAOAuthService *oauthService = self.oauthService;
    id <SFAClient> oauthSFAClient = self.oauthService.client;
    
    if (oauthService && oauthSFAClient) {
        SFAOAuth2Credential *oauthCred = (SFAOAuth2Credential *)credential;
        
        SFAuthenticationContext *refreshContext = [self initalizeContext:nil];
        refreshContext.challengeCount = context.challengeCount;
        
        SFASDKAuthHandler __weak *weakSelf = self;
        
        SFApiQuery *refreshQuery = [oauthService refreshOAuthTokenQuery:oauthCred.oAuthToken];
        id <SFATask> refreshTask = [oauthSFAClient taskWithQuery:refreshQuery callbackQueue:nil completionCallback: ^(id returnValue, SFAError *error, NSDictionary *additionalInfo) {
                                        SFASDKAuthHandler *strongSelf = weakSelf;
                                        
                                        SFAAuthHandling_ResponseResult refreshResult = SFAAuthHandling_Continue;
                                        
                                        if (!error && [returnValue isKindOfClass:[SFAOAuthToken class]]) {
                                            SFAOAuthToken *token = returnValue;
                                            SFAOAuth2Credential *credential = [[SFAOAuth2Credential alloc] initWithOAuthToken:token];
                                            
                                            [context.contextCredentialCache addCredential:credential forUrl:token.getUrl authType:nil];
                                            [self.credentialStore addCredential:credential forUrl:token.getUrl authType:nil];
                                            refreshResult = SFAAuthHandling_Retry;
                                        }
                                        
                                        [strongSelf finishAuthSubtaskWithOriginalContext:context subContext:refreshContext withResult:refreshResult completionHandler:completionHandler];
                                    } cancelCallback: ^{
                                        [weakSelf finishAuthSubtaskWithOriginalContext:context subContext:refreshContext withResult:SFAAuthHandling_Continue completionHandler:completionHandler];
                                    }];
                                    
        [self startAuthSubtask:refreshTask withClient:oauthSFAClient originalContext:context subContext:refreshContext];
        
        return;
    }
    
    // We weren't able to handle the refresh
    if (completionHandler) {
        completionHandler(SFAAuthHandling_Continue);
    }
}

- (void)startAuthSubtask:(id <SFATask> )task
              withClient:(id <SFAClient> )client
         originalContext:(SFAuthenticationContext *)context
              subContext:(SFAuthenticationContext *)subContext {
    // Inject this auth context into subtask
    if ([task isKindOfClass:[SFAHttpTask class]]) {
        SFAHttpTask *httpTask = (SFAHttpTask *)task;
        httpTask.contextObject = httpTask.contextObject ? :[NSMutableDictionary dictionary];
        
        [httpTask.contextObject setObject:SFAAuthContextKey forKey:subContext];
    }
    
    if (subContext && context) {
        @synchronized(self.lock)
        {
            [self.authTasks setObject:task forKey:subContext];
        }
    }
    
    [client executeTask:task];
}

- (void)finishAuthSubtaskWithOriginalContext:(SFAuthenticationContext *)context
                                  subContext:(SFAuthenticationContext *)subContext
                                  withResult:(SFAAuthHandling_ResponseResult)result
                           completionHandler:(void (^)(SFAAuthHandling_ResponseResult))completionHandler {
    if (context) {
        NSUInteger additionalAttempts = subContext.challengeCount - context.challengeCount;
        if (additionalAttempts > 0) {
            context.challengeCount += additionalAttempts;
        }
    }
    
    if (subContext) {
        @synchronized(self.lock)
        {
            [self.authTasks removeObjectForKey:subContext];
        }
    }
    
    if (completionHandler) {
        completionHandler(result);
    }
}

@end
