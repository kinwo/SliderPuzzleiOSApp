//
//  SPAppDelegate.m
//  SliderPuzzle
//
//  Created by HENRY CHAN on 9/01/2014.
//  Copyright (c) 2014 Kinwo.net. All rights reserved.
//

#import "SPZAppDelegate.h"
#import "TestFlight.h"
#import "SPZConstants.h"
#import <Instabug/Instabug.h>
#import "GAI.h"

@implementation SPZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [TestFlight takeOff:TESTFLIGHT_ID];
    
    [self initializeInstabug];
    
    [self initializeGA];
    
    // status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    return YES;
}

- (void)initializeGA
{
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = NO;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 60;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelWarning];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:GA_TRACKING_ID];
}

- (void)initializeInstabug
{
    [Instabug startWithToken:@"ac74ae75d26571b645acdf09b58a292a" captureSource:IBGCaptureSourceUIKit invocationEvent:IBGInvocationEventNone];

    [Instabug setButtonsFontColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0]];
    [Instabug setButtonsColor:[UIColor colorWithRed:(56/255.0) green:(55/255.0) blue:(55/255.0) alpha:1.0]];
    [Instabug setHeaderFontColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0]];
    [Instabug setHeaderColor:[UIColor colorWithRed:(46/255.0) green:(45/255.0) blue:(45/255.0) alpha:1.0]];
    [Instabug setTextFontColor:[UIColor colorWithRed:(82/255.0) green:(83/255.0) blue:(83/255.0) alpha:1.0]];
    [Instabug setTextBackgroundColor:[UIColor colorWithRed:(249/255.0) green:(249/255.0) blue:(249/255.0) alpha:1.0]];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    // clear badges
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
