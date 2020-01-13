#import "SFABaseAuthHandlerProtected.h"
#import "SFAuthenticationContext.h"
#import "NSURLCredential+sfapi.h"
#import "SFAOAuth2Credential.h"
#import "SFAConnectionAuthParser.h"
#import "SFAUtils.h"
#import "NSHTTPURLResponse+sfapi.h"

@implementation SFABaseAuthHandler
@synthesize credentialStore = _credentialStore;
@synthesize credentialTracker = _credentialTracker;
#pragma mark - Initialization

- (instancetype)init {
    self = [super init];
    if (self) {
        [self internalInit];
    }
    return self;
}

- (void)internalInit {
    self.authParserClasses = [[NSMutableArray alloc] init];
}

- (SFAuthenticationContext *)initalizeContext:(SFAuthenticationContext *)existingContext {
    return [[self class] initializeContextFromExistingContext:existingContext];
}

+ (SFAuthenticationContext *)initializeContextFromExistingContext:(SFAuthenticationContext *)existingContext {
    SFAuthenticationContext *context = existingContext;
    BOOL hasContext = context != nil;
    if (!hasContext) {
        context = [[SFAuthenticationContext alloc] init];
    }
    
    if (!context.contextCredentialCache) {
        context.contextCredentialCache = [[SFACredentialCache alloc] init];
    }
    
    if (!context.interactiveCredentialCache) {
        context.interactiveCredentialCache = [[SFACredentialCache alloc] init];
    }
    
    return context;
}

#pragma mark - Checks and Flow Control

- (BOOL)isRealCredential:(NSURLCredential *)credential {
    BOOL isStub = credential == [[SFACredentialAuthorityContainer defaultCredentialContainer] credential];
    
    return credential && !isStub && [credential isUsable];
}

- (BOOL)shouldApplySavedCredentialToRequest:(NSURLRequest *)req wasChallenged:(BOOL)challenged {
    // Default implementation, only apply credentials when we're challenged for them
    return challenged;
}

#pragma mark - Credential Handling
- (NSURLCredential *)credentialForRequest:(NSURLRequest *)req
                              authContext:(SFAuthenticationContext *)context
                            wasChallenged:(BOOL)challenged
                           includeInvalid:(BOOL)includeInvalid {
    // First stop, is there an interactive credential being held for this request?
    // An interactive credential wins if it exists, and will not be checked for correctness.
    // The rationale is that if the user has supplied a credential, they want it to be tried
    // immediately, even if the system thinks it is bad. We could be mistaken, or maybe the
    // credential status has changed since it was marked.
    NSURLCredential *cred = [context.interactiveCredentialCache credentialWithURL:req.URL authenticationType:nil];
    if (![self isRealCredential:cred]) {
        // Does the current request have a credential we're already planning to include
        cred = [context.contextCredentialCache credentialWithURL:req.URL authenticationType:nil];
        
        // If not, are we allowed to use a saved credential from the shared cache?
        if (![self isRealCredential:cred] && [self shouldApplySavedCredentialToRequest:req wasChallenged:challenged]) {
            cred = [self.credentialStore credentialWithURL:req.URL authenticationType:nil];
        }
        
        // If the saved credential is marked invalid, don't return it
        if (!includeInvalid && [self.credentialTracker credentialStatus:cred forURL:req.URL] == SFACredential_StatusInvalid) {
            cred = nil;
        }
    }
    
    return cred;
}

/**
 *  Build an authorization header for the given URL.
 *  If no header is available, a nil string will be returned.
 *
 *  @param credential       Credential to apply to header
 *  @param credentialScheme Detected credential scheme for supplied credential
 *
 *  @return Authorization header, or nil if credential cannot be made into a header
 */
- (NSString *)authorizationHeaderValueForCredential:(NSURLCredential *)credential scheme:(NSString **)credentialScheme {
    NSString *authorizationHeader = nil;
    NSString *scheme = nil;
    
    if ([self isRealCredential:credential]) {
        NSString *formattedCredential = nil;
        
        // OAuth case
        if ([credential isKindOfClass:[SFAOAuth2Credential class]] && credential.password.length > 0) {
            scheme = SFABearer;
            formattedCredential = credential.password;
        }
        else {
            // If we have a credential at all, it's not something we know how to apply here
        }
        
        if (scheme && formattedCredential) {
            authorizationHeader = [NSString stringWithFormat:@"%@ %@", scheme, formattedCredential];
        }
    }
    
    *credentialScheme = scheme;
    return authorizationHeader;
}

- (NSURLCredential *)applyCredential:(NSURLCredential *)cred
                           toRequest:(NSMutableURLRequest *)req
                         authContext:(SFAuthenticationContext *)authContext {
    // Promote the credential to the request cache
    [authContext.contextCredentialCache addCredential:cred forUrl:req.URL authType:nil];
    
    NSURLCredential *appliedCredential = nil;
    if ([self isRealCredential:cred]) {
        NSString *scheme;
        NSString *authorizationHeader = [self authorizationHeaderValueForCredential:cred scheme:&scheme];
        
        if (authorizationHeader) {
            [req setValue:authorizationHeader forHTTPHeaderField:SFAAuthorization];
            appliedCredential = cred;
        }
    }
    
    return appliedCredential;
}

#pragma mark - SFAAuthHandling Methods
- (SFAuthenticationContext *)prepareRequest:(NSMutableURLRequest *)req
                                authContext:(SFAuthenticationContext *)authContext
                         interactiveHandler:(NSObject <SFAInteractiveAuthHandling> *)interactiveHandler {
    // Setup context
    authContext = [self initalizeContext:authContext];
    
    if (!authContext.originalRequestURL) {
        authContext.originalRequestURL = req.URL;
    }
    authContext.lastRequestURL = req.URL;
    
    if (interactiveHandler) {
        authContext.interactiveHandler = interactiveHandler;
    }
    
    // Get credential for request, if any
    NSURLCredential *credential = [self credentialForRequest:req authContext:authContext wasChallenged:NO includeInvalid:NO];
    
    // Apply credential
    NSURLCredential *appliedCredential = [self applyCredential:credential toRequest:req authContext:authContext];
    authContext.lastAppliedCredential = appliedCredential;
    authContext.authenticationChallenge = nil;
    
    // Classes extending BaseAuthHandler may want to do more work here. ex. manual cookie management
    
    return authContext;
}

- (SFAAuthHandling_ResponseResult)finishRequest:(SFAHttpRequestResponseDataContainer *)container
                                    authContext:(SFAuthenticationContext *)authContext {
    SFAAuthHandling_ResponseResult result = SFAAuthHandling_Continue;
    
    if ([SFAUtils didAuthFailForRequest:container]) {
        result = [self processUnauthorizedReponse:container authContext:authContext];
    }
    else {
        result = [self processAuthSuccess:container authContext:authContext];
    }
    
    return result;
}

- (void)handleUnauthorizedResponse:(SFAHttpRequestResponseDataContainer *)container
                       authContext:(SFAuthenticationContext *)authContext
                 completionHandler:(void (^)(SFAAuthHandling_ResponseResult result))completionHandler {
    BOOL handled = [self internalHandleUnauthorizedResponse:container authContext:authContext completionHandler:completionHandler];
    
    if (!handled && completionHandler) {
        completionHandler(SFAAuthHandling_Continue);
    }
}

- (void)handleAuthChallenge:(NSURLAuthenticationChallenge *)challenge
              httpContainer:(SFAHttpRequestResponseDataContainer *)container
                authContext:(SFAuthenticationContext *)authContext
          completionHandler:(void (^)(SFIURLAuthChallengeDisposition, NSURLCredential *))completionHandler {
    authContext.authenticationChallenge = [[SFAHTTPAuthenticationChallenge alloc] initWithChallenge:challenge withURL:container.request.URL originalRequestURL:authContext.originalRequestURL];
    
    void (^finishBlock)(SFAAuthHandling_ResponseResult result) = ^(SFAAuthHandling_ResponseResult result) {
        NSURLCredential *cred = nil;
        SFIURLAuthChallengeDisposition disposition = SFIURLAuthChallengePerformDefaultHandling;
        
        if (result == SFAAuthHandling_Retry) {
            cred = [self credentialForRequest:container.request authContext:authContext wasChallenged:YES includeInvalid:NO];
            disposition = SFIURLAuthChallengeUseCredential;
            authContext.lastAppliedCredential = [cred copy];
        }
        else if (result == SFAAuthHandling_Cancel) {
            disposition = SFIURLAuthChallengeCancelAuthenticationChallenge;
            authContext.lastAppliedCredential = nil;
        }
        
        if (completionHandler) {
            completionHandler(disposition, cred);
        }
    };
    
    SFAAuthHandling_ResponseResult prelimAction = [self processUnauthorizedReponse:container authContext:authContext];
    
    // Retry case can be completed now
    if (prelimAction == SFAAuthHandling_Retry) {
        finishBlock(prelimAction);
    }
    else {
        if (prelimAction == SFAAuthHandling_Continue ||
            ![self internalHandleUnauthorizedResponse:container authContext:authContext completionHandler:finishBlock]) {
            finishBlock(SFAAuthHandling_Continue);
        }
    }
}

#pragma mark - Auth Parsers
- (void)registerAuthChallengeParser:(NSString *)parserClass {
    if (parserClass.length > 0) {
        [self.authParserClasses addObject:parserClass];
    }
}

- (void)removeAuthChallengeParser:(NSString *)parserClass {
    if (parserClass.length > 0) {
        [self.authParserClasses removeObject:parserClass];
    }
}

#pragma mark - Internal Auth Handling Methods

- (SFAAuthHandling_ResponseResult)processAuthSuccess:(SFAHttpRequestResponseDataContainer *)httpContainer
                                         authContext:(SFAuthenticationContext *)authContext {
    if ([httpContainer.response isSuccessCode]) {
        NSURLCredential *lastAppliedCredential = authContext.lastAppliedCredential;
        
        // Mark last credential as good. * Note:
        // Even if we have a nil credential, it's still OK to mark it as good here. We may be in a case where
        // another component is satisfying challenges for us, such as MDX or a netscaler. We just want to note
        // that we had a successful call for this credential (or nil credential) and URL combo
        [self.credentialTracker updateCredentialStatus:lastAppliedCredential status:SFACredential_StatusValid forURL:httpContainer.request.URL];
        
        // Save credential
        if (lastAppliedCredential) {
            [self.credentialStore addCredential:lastAppliedCredential forUrl:httpContainer.request.URL authType:nil];
            
            // Optionally, persist
            if ([self.credentialStore respondsToSelector:@selector(persist:)]) {
                [self.credentialStore persist:lastAppliedCredential];
            }
        }
    }
    
    return SFAAuthHandling_Continue;
}

- (SFAAuthHandling_ResponseResult)processUnauthorizedReponse:(SFAHttpRequestResponseDataContainer *)httpContainer
                                                 authContext:(SFAuthenticationContext *)authContext {
    authContext.challengeCount++;
    
    // If we've already parsed out an authentication challenge before getting here, then keep the one we have
    if (!authContext.authenticationChallenge) {
        authContext.authenticationChallenge = [self challengeForHttpContainer:httpContainer authContext:authContext];
    }
    
    NSURLCredential *lastAppliedCredential = authContext.lastAppliedCredential;
    
    // Mark the last credential we tried as bad
    [self.credentialTracker updateCredentialStatus:lastAppliedCredential status:SFACredential_StatusInvalid forURL:httpContainer.request.URL];
    
    // Remove the failed credential from the temp credential caches
    [authContext.interactiveCredentialCache removeCredential:lastAppliedCredential forUrl:httpContainer.request.URL authType:nil];
    [authContext.contextCredentialCache removeCredential:lastAppliedCredential forUrl:httpContainer.request.URL authType:nil];
    
    NSURLCredential *availableCredential = [self credentialForRequest:httpContainer.request authContext:authContext wasChallenged:YES includeInvalid:NO];
    
    SFAAuthHandling_ResponseResult result = SFAAuthHandling_Continue;
    
    // If the container's error indicates that we already challenged and skipped, then pass the AuthHandling_Cancel along
    if ([SFAUtils wasAuthCanceledForRequest:httpContainer]) {
        result = SFAAuthHandling_Cancel;
    }
    else if ([self isRealCredential:availableCredential] && ![availableCredential isEqualToCredential:lastAppliedCredential]) {
        // Promote available credential to the request credential cache
        [authContext.contextCredentialCache addCredential:availableCredential forUrl:httpContainer.request.URL authType:nil];
        result = SFAAuthHandling_Retry;
    }
    
    return result;
}

- (BOOL)internalHandleUnauthorizedResponse:(SFAHttpRequestResponseDataContainer *)httpContainer
                               authContext:(SFAuthenticationContext *)authContext
                         completionHandler:(void (^)(SFAAuthHandling_ResponseResult))completionHandler {
    // Default handler does nothing
    return NO;
}

- (SFAHTTPAuthenticationChallenge *)challengeForHttpContainer:(SFAHttpRequestResponseDataContainer *)container
                                                  authContext:(SFAuthenticationContext *)authContext {
    if (self.authParserClasses.count > 0) {
        NSMutableArray *classesToRemove = [NSMutableArray arrayWithCapacity:_authParserClasses.count];
        
        for (NSUInteger i = self.authParserClasses.count; i > 0; i--) {
            NSString *className = self.authParserClasses[i - 1];
            Class class = NSClassFromString(className);
            if (class) {
                id <SFAConnectionAuthParser> parser = [class new];
                if ([parser conformsToProtocol:@protocol(SFAConnectionAuthParser)]) {
                    SFAHTTPAuthenticationChallenge *result = [parser authChallengeWithResponseContainer:container authContext:authContext];
                    if (result) {
                        return result;
                    }
                }
                else {
                    [classesToRemove addObject:className];
                }
            }
            else {
                [classesToRemove addObject:className];
            }
        }
        
        [self.authParserClasses removeObjectsInArray:classesToRemove];
    }
    return nil;
}

@end
