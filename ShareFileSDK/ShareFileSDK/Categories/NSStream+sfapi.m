#import "NSStream+sfapi.h"

@implementation NSStream (sfapi)

+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    assert((inputStreamPtr != NULL) || (outputStreamPtr != NULL));
    
    readStream = NULL;
    writeStream = NULL;
    
    CFStreamCreateBoundPair(NULL, ((inputStreamPtr != nil) ? &readStream : NULL), ((outputStreamPtr != nil) ? &writeStream : NULL), (CFIndex)bufferSize);
    
    if (inputStreamPtr != NULL) {
        *inputStreamPtr = CFBridgingRelease(readStream);
    }
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = CFBridgingRelease(writeStream);
    }
}

@end
