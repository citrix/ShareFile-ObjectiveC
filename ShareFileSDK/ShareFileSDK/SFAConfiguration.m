#import "SFADefaultLogger.h"
#import "SFAUtils.h"

@implementation SFAConfiguration

+ (instancetype)defaultConfiguration;
{
    return [[[self class] alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        self.useHttpMethodOverride = NO;
        self.httpTimeout = SFAHttpTimeout;
        self.toolName = SFAToolName;
        self.toolVersion = SFAToolVersion;
        self.logger = [SFADefaultLogger new];
        self.logHeaders = NO;
        self.logPersonalInformation = NO;
        self.clientId = @"";
        self.clientSecret = @"";
        self.clientCapabilities = [[NSDictionary alloc] init];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    SFAConfiguration *copy = [self.class alloc];
    copy.useHttpMethodOverride = self.useHttpMethodOverride;
    copy.httpTimeout = self.httpTimeout;
    copy.toolName = self.toolName;
    copy.toolVersion = self.toolVersion;
    copy.logger = self.logger;
    copy.logHeaders = self.logHeaders;
    copy.logPersonalInformation = self.logPersonalInformation;
    copy.clientId = self.clientId;
    copy.clientSecret = self.clientSecret;
    copy.supportedCultures = self.supportedCultures;
    copy.clientCapabilities = self.clientCapabilities;
    return copy;
}

- (void)setSupportedCultures:(NSArray *)supportedCultures {
    _supportedCultures = supportedCultures;
    _acceptLanguageHeader = [SFAUtils acceptHeaderForCultures:supportedCultures];
}

@end
