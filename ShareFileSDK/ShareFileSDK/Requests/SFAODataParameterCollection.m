@interface SFAODataParameterCollection ()

@property (nonatomic, strong) NSMutableSet *innerSet;

@end

@implementation SFAODataParameterCollection

- (NSMutableSet *)innerSet {
    if (!_innerSet) {
        _innerSet = [NSMutableSet new];
    }
    return _innerSet;
}

- (NSString *)toStringForUri {
    NSMutableString *retString = [NSMutableString new];
    if (self.count) {
        for (SFAODataParameter *parameter in self.innerSet) {
            [retString appendFormat:@"%@,", [parameter toStringForUri]];
        }
    }
    if (retString.length > 0) {
        return [retString substringToIndex:retString.length - 1];
    }
    else {
        return [retString copy];
    }
}

- (NSString *)description {
    NSMutableString *retString = [NSMutableString new];
    if (self.count) {
        for (SFAODataParameter *parameter in self.innerSet) {
            [retString appendFormat:@"%@,", parameter];
        }
    }
    if (retString.length > 0) {
        return [retString substringToIndex:retString.length - 1];
    }
    else {
        return [retString copy];
    }
}

- (void)addOrUpdateObject:(SFAODataParameter *)parameter {
    if ([self containsObject:parameter]) {
        [self removeObject:parameter];
    }
    [self.innerSet addObject:parameter];
}

- (void)removeObject:(SFAODataParameter *)parameter {
    [self.innerSet removeObject:parameter];
}

- (BOOL)containsObject:(SFAODataParameter *)parameter {
    return [self.innerSet containsObject:parameter];
}

- (NSUInteger)count {
    return self.innerSet.count;
}

- (id <NSFastEnumeration> )collectionAsFastEnumrable {
    return [self.innerSet copy];
}

@end
