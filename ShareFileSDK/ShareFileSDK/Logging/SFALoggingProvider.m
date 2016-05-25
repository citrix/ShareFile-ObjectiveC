#import "SFADefaultLogger.h"

@interface SFALoggingProvider ()

@property (nonatomic, strong, readonly) id <SFALogger> instance;

- (BOOL)hasLoggingWithLogLevel:(SFALogLevel)logLevel;

@end

@implementation SFALoggingProvider

#pragma mark - Public Functions

- (BOOL)isTraceEnabled {
    return [self hasLoggingWithLogLevel:SFALogLevelTrace];
}

- (BOOL)isDebugEnabled {
    return [self hasLoggingWithLogLevel:SFALogLevelDebug];
}

- (BOOL)isInformationEnabled {
    return [self hasLoggingWithLogLevel:SFALogLevelInfo];
}

- (BOOL)isWarningEnabled {
    return [self hasLoggingWithLogLevel:SFALogLevelWarn];
}

- (BOOL)isErrorEnabled {
    return [self hasLoggingWithLogLevel:SFALogLevelError];
}

- (BOOL)isFatalEnabled {
    return [self hasLoggingWithLogLevel:SFALogLevelFatal];
}

- (void)traceActionStopWatch:(SFAActionStopwatch *)actionStopwatch {
    if ([self isTraceEnabled]) {
        [actionStopwatch stop];
        [self traceWithFormat:@"%@ took %f second(s) to execute.", actionStopwatch.name, actionStopwatch.elapsedTime];
    }
}

- (instancetype)initWithLogger:(id <SFALogger> )logger {
    self = [super init];
    if (self) {
        _instance = logger;
    }
    return self;
}

- (instancetype)init {
    return [self initWithLogger:[[SFADefaultLogger alloc] init]];
}

- (void)traceWithFormat:(NSString *)format, ...
{
    if ([self isTraceEnabled]) {
        va_list va;
        va_start(va, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:va];
        va_end(va);
        [_instance trace:string];
    }
}

- (void)traceWithError:(NSError *)error format:(NSString *)format, ...
{
    if ([self isTraceEnabled]) {
        va_list va;
        va_start(va, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:va];
        va_end(va);
        [_instance traceWithError:error message:string];
    }
}

- (void)debugWithFormat:(NSString *)format, ...
{
    if ([self isDebugEnabled]) {
        va_list va;
        va_start(va, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:va];
        va_end(va);
        [_instance debug:string];
    }
}

- (void)debugWithError:(NSError *)error format:(NSString *)format, ...
{
    if ([self isDebugEnabled]) {
        va_list va;
        va_start(va, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:va];
        va_end(va);
        [_instance debugWithError:error message:string];
    }
}

- (void)infoWithFormat:(NSString *)format, ...
{
    if ([self isInformationEnabled]) {
        va_list va;
        va_start(va, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:va];
        va_end(va);
        [_instance info:string];
    }
}

- (void)infoWithError:(NSError *)error format:(NSString *)format, ...
{
    if ([self isInformationEnabled]) {
        va_list va;
        va_start(va, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:va];
        va_end(va);
        [_instance infoWithError:error message:string];
    }
}

- (void)warnWithFormat:(NSString *)format, ...
{
    if ([self isWarningEnabled]) {
        va_list va;
        va_start(va, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:va];
        va_end(va);
        [_instance warn:string];
    }
}

- (void)warnWithError:(NSError *)error format:(NSString *)format, ...
{
    if ([self isWarningEnabled]) {
        va_list va;
        va_start(va, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:va];
        va_end(va);
        [_instance warnWithError:error message:string];
    }
}

- (void)errorWithFormat:(NSString *)format, ...
{
    if ([self isErrorEnabled]) {
        va_list va;
        va_start(va, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:va];
        va_end(va);
        [_instance error:string];
    }
}

- (void)errorWithError:(NSError *)error format:(NSString *)format, ...
{
    if ([self isErrorEnabled]) {
        va_list va;
        va_start(va, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:va];
        va_end(va);
        [_instance errorWithError:error message:string];
    }
}

- (void)fatalWithFormat:(NSString *)format, ...
{
    if ([self isFatalEnabled]) {
        va_list va;
        va_start(va, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:va];
        va_end(va);
        [_instance fatal:string];
    }
}

- (void)fatalWithError:(NSError *)error format:(NSString *)format, ...
{
    if ([self isFatalEnabled]) {
        va_list va;
        va_start(va, format);
        NSString *string = [[NSString alloc] initWithFormat:format arguments:va];
        va_end(va);
        [_instance fatalWithError:error message:string];
    }
}

#pragma mark - Private Functions

- (BOOL)hasLoggingWithLogLevel:(SFALogLevel)logLevel {
    return (_instance != nil && _instance.logLevel & logLevel);
}

@end
