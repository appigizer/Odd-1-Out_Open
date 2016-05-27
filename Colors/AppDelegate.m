//
//  AppDelegate.m
//  Colors
//
//  Created by Surjeet Singh on 29/02/16.
//  Copyright © 2016 marijuanaincstudios. All rights reserved.
//

#import "AppDelegate.h"
#import "iRate.h"
@import GoogleMobileAds;
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <KSToastView.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize {
  [iRate sharedInstance].appStoreID = 1090333342; //Put your app id here
#if DEBUG
    [iRate sharedInstance].previewMode = YES;
#endif
  [KSToastView ks_setAppearanceOffsetBottom:30.0f];
  
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  ///Add your own runtime script in BuildPhase to enable Crashlytics. 
  [Fabric with:@[[Crashlytics class]]];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
}

- (void)didInitialize:(BOOL)status
{
//  [Chartboost cacheRewardedVideo:@"Pankaj"];
//  [Chartboost setAutoCacheAds:true];
}

//- (BOOL)shouldDisplayRewardedVideo:(CBLocation)location
//{
//  return true;
//}
//
//- (void)didDisplayRewardedVideo:(CBLocation)location
//{
//  
//}
//
//- (void)didCacheRewardedVideo:(CBLocation)location
//{
//  
//}
//
//- (void)didFailToLoadRewardedVideo:(CBLocation)location
//                         withError:(CBLoadError)error
//{
//  
//}

@end
