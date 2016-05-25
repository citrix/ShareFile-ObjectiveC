#import "NSMutableArray+sfapi.h"

@implementation NSMutableArray (sfapi)

// First in first out.
- (id)dequeue {
    if ([self count] == 0) {
        return nil;
    }
    id headObject = [self objectAtIndex:0];
    if (headObject != nil) {
        [self removeObjectAtIndex:0];
    }
    return headObject;
}

// Add to the tail of the queue
- (void)enqueue:(id)anObject {
    [self addObject:anObject];
}

@end
