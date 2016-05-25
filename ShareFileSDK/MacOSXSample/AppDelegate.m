#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.sampleCode = [GenericSampleCode new];
    [self performSelectorInBackground:@selector(runSampleOnThread) withObject:nil];
}

- (void)runSampleOnThread {
    @autoreleasepool
    {
        [self.sampleCode runSample];
    }
}

@end
