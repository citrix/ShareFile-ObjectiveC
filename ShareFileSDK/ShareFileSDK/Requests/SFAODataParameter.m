#import "NSString+sfapi.h"

@implementation SFAODataParameter

- (instancetype)initWithKey:(NSString *)aKey value:(NSString *)val encodeValue:(BOOL)encodeVal {
    self = [super init];
    if (self) {
        self.key = aKey;
        self.value = val;
        self.encodeValue = encodeVal;
    }
    return self;
}

- (instancetype)initWithValue:(NSString *)val encodeValue:(BOOL)encodeVal {
    self = [super init];
    if (self) {
        self.key = nil;
        self.value = val;
        self.encodeValue = encodeVal;
    }
    return self;
}

- (instancetype)initWithKey:(NSString *)key value:(NSString *)val {
    self = [super init];
    if (self) {
        self.key = key;
        self.value = val;
        self.encodeValue = NO;
    }
    return self;
}

- (NSString *)toStringForUri {
    NSString *retVal;
    BOOL isNullOrEmptyKey = !self.key || self.key.length == 0;
    if (isNullOrEmptyKey && self.encodeValue) {
        retVal = [self.value escapeString];
    }
    else if (isNullOrEmptyKey && !self.encodeValue) {
        retVal = self.value;
    }
    else {
        retVal = [NSString stringWithFormat:@"%@=%@", [self.key escapeString], [self.value escapeString]];
    }
    return retVal;
}

- (NSString *)description {
    if (!self.key) {
        return self.value;
    }
    else {
        return [NSString stringWithFormat:@"%@=%@", self.key, self.value];
    }
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SFAODataParameter *obj = (SFAODataParameter *)object;
    if (self.key && self.key.length) {
        return [obj.key isEqualToString:self.key];
    }
    else {
        return [obj.value isEqualToString:self.value];
    }
}

- (NSUInteger)hash {
    if (self.key.length > 0) {
        return [self.key hash];
    }
    else {
        return [self.value hash];
    }
}

@end
