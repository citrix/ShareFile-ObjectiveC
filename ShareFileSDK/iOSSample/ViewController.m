#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self performSelectorInBackground:@selector(runSampleOnThread) withObject:nil];
}

- (void)runSampleOnThread {
    @autoreleasepool
    {
        [((AppDelegate *)[UIApplication sharedApplication].delegate).sampleCode runSample];
    }
}

@end
