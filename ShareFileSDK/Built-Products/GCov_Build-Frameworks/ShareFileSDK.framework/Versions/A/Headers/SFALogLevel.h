/**
 * SFALogLevel NS_OPTIONS with NSUInteger values.
 */
typedef NS_OPTIONS (NSUInteger, SFALogLevel) {
    /**
     * Option value for log level None.
     */
    SFALogLevelNone = 0x0,
    /**
     * Option value for log level Trace.
     */
    SFALogLevelTrace = 0x1,
    /**
     * Option value for log level Debug.
     */
    SFALogLevelDebug = 0x2,
    /**
     * Option value for log level Info.
     */
    SFALogLevelInfo = 0x4,
    /**
     * Option value for log level Warn.
     */
    SFALogLevelWarn = 0x8,
    /**
     * Option value for log level Error.
     */
    SFALogLevelError = 0x10,
    /**
     * Option value for log level Fatal.
     */
    SFALogLevelFatal = 0x20
};
