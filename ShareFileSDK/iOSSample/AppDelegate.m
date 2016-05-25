#import "AppDelegate.h"

static NSString *kBackgroundSessionIdentifierKey = @"backgroundSessionIdentifier";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.sampleCode = [GenericSampleCode new];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *identifier = [userDefaults objectForKey:kBackgroundSessionIdentifierKey];
    if (identifier) {
        SFAClient *client = self.sampleCode.client;
        SFABackgroundSessionManager *bgSessionManager = client.backgroundSessionManager;
        SFABackgroundSessionConfiguration *config = bgSessionManager.configurationForNewBackgroundSession;
        config.identifier = identifier;
        bgSessionManager.configurationForNewBackgroundSession = config;
        NSURLSession *session = bgSessionManager.backgroundSession;
        if (!session) {
            NSLog(@"Unable to create session.");
        }
        else {
            [userDefaults removeObjectForKey:kBackgroundSessionIdentifierKey];
            [userDefaults synchronize];
        }
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    SFAClient *client = self.sampleCode.client;
    SFABackgroundSessionManager *bgSessionManager = client.backgroundSessionManager;
    if (bgSessionManager.hasBackgroundSession) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *identifier = bgSessionManager.backgroundSession.configuration.identifier;
        [userDefaults setObject:identifier forKey:kBackgroundSessionIdentifierKey];
        [userDefaults synchronize];
        NSLog(@"App Terminating, and successfully saved identifier:%@", identifier);
    }
    else {
        NSLog(@"App Terminating, but no background session.");
    }
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    SFAClient *client = self.sampleCode.client;
    SFABackgroundSessionManager *bgSessionManager = client.backgroundSessionManager;
    if (bgSessionManager.hasBackgroundSession) {
        if (![bgSessionManager.backgroundSession.configuration.identifier isEqualToString:identifier]) {
            NSLog(@"Event for Unexpected URLSession, with identifier:%@", identifier);
            return;
        }
        else {
            [bgSessionManager setCompletionHandlerForCurrentBackgroundSession:completionHandler];
        }
    }
    else {
        SFABackgroundSessionConfiguration *config = bgSessionManager.configurationForNewBackgroundSession;
        config.identifier = identifier;
        bgSessionManager.configurationForNewBackgroundSession = config;
        [bgSessionManager setupBackgroundSessionWithCompletionHandler:completionHandler];
        NSURLSession *session = bgSessionManager.backgroundSession;
        if (!session) {
            NSLog(@"Unable to create session.");
            return;
        }
    }
    NSLog(@"Handled handleEventsForBackgroundURLSession Successfully.");
}

@end
