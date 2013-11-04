//
//  AppDelegate.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "UIWindow+Animation.h"


@implementation AppDelegate

@synthesize networkStatus;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Flurry startSession:@"4YTN2NG6MYJDVT9F6P7M"];
    /// ****************************************************************************
    [Parse setApplicationId:@"6glczDK1p4HX3JVuupVvX09zE1TywJRs3Xr2NYXg" clientKey:@"CdsYZN5y9Tuum2IlHhvipft0rWItCON6JoXeqYJL"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    //[PFFacebookUtils initializeWithApplicationId:@"217295185096733"];
    [PFFacebookUtils initializeFacebook];
    // ****************************************************************************
    [TestFlight takeOff:@"d2f2ed31-a333-476b-b821-aa259759a131"];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveEventually];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    if ([PFUser currentUser]) {
        [self showMainViewController];
    }
    else {
        [self showLoginViewController];
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    [self handlePush:launchOptions];


    return YES;
}

- (void)handlePush:(NSDictionary *)launchOptions {
    // If the app was launched in response to a push notification, we'll handle the payload here
    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotificationPayload) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:@"the app was launched in response to a push notification" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    [PFPush storeDeviceToken:newDeviceToken];
    // Subscribe to the global broadcast channel.
    [PFPush subscribeToChannelInBackground:@""];
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
    [[PFInstallation currentInstallation] addUniqueObject:@"" forKey:@"channel"];
    if ([PFUser currentUser]) {
        // Make sure they are subscribed to their private push channel
        NSString *privateChannelName = [[PFUser currentUser] objectId];
        
        
        //NSLog(@"Subscribing user to %@", privateChannelName);
        
        if (privateChannelName && privateChannelName.length > 0) {
            NSLog(@"Subscribing user to %@", privateChannelName);
            [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:@"channels"];
        }
    }
    [[PFInstallation currentInstallation] saveEventually];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	if ([error code] != 3010) { // 3010 is for the iPhone Simulator
        NSLog(@"Application failed to register for push notifications: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:@"didReceiveRemoteNotification" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
    [alert show];
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    
    
    //[PF_FBSession.activeSession handleDidBecomeActive];
    
    
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
        [[PFInstallation currentInstallation] saveEventually];
    }
}

- (BOOL)isParseReachable {
    return self.networkStatus != NotReachable;
}


// ****************************************************************************
// App switching methods to support Facebook Single Sign-On
// ****************************************************************************

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [PFFacebookUtils handleOpenURL:url];
}


#pragma mark - Root View Controller

- (void)showLoginViewController
{
    UIViewController *controller = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateInitialViewController];
    [self.window setRootViewController:controller animated:YES];
}

- (void)showMainViewController
{
    UIViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
    [self.window setRootViewController:controller animated:YES];
}


#pragma mark - Convenience Methods

+ (AppDelegate *)delegate
{
    return (id)[UIApplication sharedApplication].delegate;
}

@end
