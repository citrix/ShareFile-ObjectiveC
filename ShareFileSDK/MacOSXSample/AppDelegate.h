#import <Cocoa/Cocoa.h>
#import "GenericSampleCode.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) GenericSampleCode *sampleCode;

@end
