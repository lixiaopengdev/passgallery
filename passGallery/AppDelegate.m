//
//  AppDelegate.m
//  passGallery
//
//  Created by zhuang chaoxiao on 15/9/6.
//  Copyright (c) 2015年 zhuang chaoxiao. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "PassWordViewController.h"
#import "RFRateMe.h"
#import "FirstViewController.h"
#import <GoogleMobileAds/GADMobileAds.h>
@interface AppDelegate () <GADFullScreenContentDelegate>
@property(nonatomic, strong)GADAppOpenAd *appOpenAd;
@end

@implementation AppDelegate


-(BOOL)showAdv
{
    NSUserDefaults * def = [NSUserDefaults standardUserDefaults];
    NSDate * now = [NSDate date];
    
    NSDate * advDate = [def objectForKey:ADV_BUYED];
    
    if( [now timeIntervalSinceDate:advDate] > 0  || !advDate)
    {
        return YES;
    }
    
    return NO;
}

-(void)changeRootVC
{   FirstViewController *firstVc=[[FirstViewController alloc]init];
     MainViewController * vc = [[MainViewController alloc]initWithRootViewController:firstVc];
     self.window.rootViewController = vc;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    PassWordViewController * vc = [[PassWordViewController alloc]initWithNibName:@"PassWordViewController" bundle:nil];
   
    self.window.rootViewController = vc;
    vc.passType = PASSWORD_CHECK;
    
    //

    //
    [RFRateMe showRateAlertAfterTimesOpened:5];
    //
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    PassWordViewController * vc = [[PassWordViewController alloc]initWithNibName:@"PassWordViewController" bundle:nil];
    vc.passType = PASSWORD_ANY_VIEW_CHECK;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.window.rootViewController presentViewController:vc animated:YES completion:nil];
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
    [self tryPrensentAD];
    
}

- (void)tryPrensentAD
{
    if (self.appOpenAd) {
        UIViewController *rootViewController = self.window.rootViewController;
        if (rootViewController.presentedViewController) {
            
            [self.appOpenAd presentFromRootViewController:rootViewController.presentedViewController];
        } else {
            [self.appOpenAd presentFromRootViewController:rootViewController];
        }

    } else {
        [self requestAppOpenAd];
    }
}

- (void)requestAppOpenAd
{
    self.appOpenAd = nil;
    [GADAppOpenAd loadWithAdUnitID:@"ca-app-pub-7962668156781439/4341861226" request:[GADRequest request] orientation:UIInterfaceOrientationPortrait completionHandler:^(GADAppOpenAd * _Nullable appOpenAd, NSError * _Nullable error) {
        if (error) {
            return;
        }
        self.appOpenAd = appOpenAd;
        self.appOpenAd.fullScreenContentDelegate = self;

    }];
}

- (void)adDidDismissFullScreenContent:(id<GADFullScreenPresentingAd>)ad {
    [self requestAppOpenAd];
}

- (void)ad:(id<GADFullScreenPresentingAd>)ad didFailToPresentFullScreenContentWithError:(NSError *)error
{
    [self requestAppOpenAd];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
