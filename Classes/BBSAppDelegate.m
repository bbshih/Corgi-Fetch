//
//  YTVAppDelegate.m
//  CorgiFetch
//
//  Created by Billy Shih on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BBSAppDelegate.h"
#import "ZUUIRevealController.h"
#import "BBSLeftNavTableViewController.h"
#import "BBSVideoTableViewController.h"
#import "BBSPhotoFGalleryViewController.h"
#import "BBSPhotoStore.h"
#import "CorgiFetchSHKConfigurator.h"
#import "SHKConfiguration.h"
#import "SHKFacebook.h"
#import "SHK.h"
#import "Reachability.h"
#import "Appirater.h"
#import "BBSinappPurchase.h"
#import "IGConnect.h"

@implementation BBSAppDelegate

@synthesize window = _window;
@synthesize internetWorking;
@synthesize instagram;

#define INSTAGRAM_APP_ID @"680814f6c6cf4aa9b4831e776c0113e7"
#define kAPP_VERSION @"1.1.0"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Override point for customization after application launch.
    
    // Determine purchase status
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self setPremium:[defaults boolForKey:@"isPremiumPurchased"]];
    
    // Checks what version the user has and updates it if they have a new version and clears any old/non-working items.
    [self setVersion:[defaults objectForKey:@"appVersion"]];
    
    if (![[self version] isEqualToString:kAPP_VERSION]) {
        // Reset items that were saved that won't work in the new version
        // 1.1.0 update - removed old sort types since I removed flickr as the primary photo source
        [defaults setObject:@"corgi" forKey:@"sortType"];
        [defaults setObject:@"corgi" forKey:@"fetchSortType"];
        
        // Update app version to newest
        [defaults setObject:kAPP_VERSION forKey:@"appVersion"];
        [self setVersion:kAPP_VERSION];
    }
    
    // Setup app rating prompt
    [Appirater setAppId:@"EMF25B864Z.com.billyshih.corgifetch"];
    [Appirater setDaysUntilPrompt:3];
    [Appirater setUsesUntilPrompt:3];
    
    // Setup instagram SDK
    self.instagram = [[Instagram alloc] initWithClientId:INSTAGRAM_APP_ID
                                                delegate:nil];
    
//    YTVVideoTableViewController *tvc = [[YTVVideoTableViewController alloc] init];
//    UINavigationController *videoNavController = [[UINavigationController alloc] initWithRootViewController:tvc];
//    
    BBSPhotoFGalleryViewController *pvc = [[BBSPhotoFGalleryViewController alloc] initWithPhotoSource:[BBSPhotoStore sharedStore]];
    [pvc setBeginsInThumbnailView:YES];
    UINavigationController *photoNavController = [[UINavigationController alloc] initWithRootViewController:pvc];

    BBSLeftNavTableViewController *onvc = [[BBSLeftNavTableViewController alloc] init];
    
    // Need this so that the button can target the correct view controller in the Photo Gallery
    
    ZUUIRevealController *revealController = [[ZUUIRevealController alloc] initWithFrontViewController:photoNavController rearViewController:onvc];
    [revealController setWantsFullScreenLayout: YES];
    
    [onvc setRevealController:revealController];
    
    [[self window] setRootViewController:revealController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];

    DefaultSHKConfigurator *configurator = [[CorgiFetchSHKConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [Reachability reachabilityWithHostName: @"www.apple.com"];
    [hostReachable startNotifier];
    
    [Appirater appLaunched:YES];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    BOOL success = [[BBSPhotoStore sharedStore] saveChanges];
    if (success) {
        NSLog(@"Saved all of the Photos");
    } else {
        NSLog(@"Could not save any of the Photos");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}

-(void) checkNetworkStatus:(NSNotification *)notice
{
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Problem connecting" message:@"Your WiFi or cellular connection doesn't seem to be working. Please try fixing your connection and reopen the application." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [errorAlert show];
            internetWorking = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            internetWorking = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            internetWorking = YES;
            break;
        }
    }
    
    // Checks if can connect to host, but if internet is already not reachable, doesn't do anything so that only 1 message shows up
    if (internetStatus != NotReachable) {
        NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
        switch (hostStatus)
        {
            case NotReachable:
            {
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Problem connecting" message:@"Internet doesn't seem to be working. Please try again later." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [errorAlert show];
                
                break;
            }
            case ReachableViaWiFi:
            {
                internetWorking = YES;
                break;
            }
            case ReachableViaWWAN:
            {
                internetWorking = YES;
                break;
            }
        }
    }
}

#pragma mark ShareKit Facebook Single Sign-On methods

- (BOOL)handleOpenURL:(NSURL*)url
{
    NSString* scheme = [url scheme];
    NSString* prefix = [NSString stringWithFormat:@"fb%@", SHKCONFIG(facebookAppId)];
    if ([scheme hasPrefix:prefix])
        return [SHKFacebook handleOpenURL:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[url absoluteString] isEqualToString:@"ig680814f6c6cf4aa9b4831e776c0113e7"]) {
        return [self.instagram handleOpenURL:url];
    }
    return [self handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[url absoluteString] isEqualToString:@"ig680814f6c6cf4aa9b4831e776c0113e7"]) {
        return [self.instagram handleOpenURL:url];
    }
    return [self handleOpenURL:url];
}
                         
@end
