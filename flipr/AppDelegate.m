//
//  AppDelegate.m
//  flipr
//
//  Created by Michael Rizkalla on 1/17/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "VideoTableViewController.h"

@interface AppDelegate ()

- (void)updateRootVC;

@property (nonatomic, strong) LoginViewController *loginVC;
@property (nonatomic, strong) UINavigationController *videoNVC;
@property (nonatomic, strong) UIViewController *currentVC;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Parse setApplicationId:@"mztyxvPOS0v0qP6bslsRnAZMiM4WcCwCpwNOszU8"
                  clientKey:@"4jRkxwJCfG9GdGWArOu8GS9QdoknQBfCjLbKRnh8"];
    
    [PFTwitterUtils initializeWithConsumerKey:@"U5IXd4U7LsuyTcSkiecuSw"
                               consumerSecret:@"TQNYZskYkd7uLUqHp2SdHtU6tT8tRQ4HKjKNHGkQE"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController = self.currentVC;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRootVC) name:PFLogInSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRootVC) name:UserDidLogoutNotification object:nil];
    
    [self.window makeKeyAndVisible];
    
    return YES;
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Private methods

- (UIViewController *)currentVC {
    if ([PFUser currentUser]) {
        NSLog(@"Current user exists...");
        return self.videoNVC;
    } else {
        NSLog(@"No current user, fire up a log in view...");
        return self.loginVC;
    }
}

- (UINavigationController *)videoNVC {
    if (!_videoNVC) {
        VideoTableViewController *videoTableVC = [[VideoTableViewController alloc] init];
        _videoNVC = [[UINavigationController alloc] initWithRootViewController:videoTableVC];
    }
    
    return _videoNVC;
}

- (LoginViewController *)loginVC {
    if (!_loginVC) {
        NSLog(@"Allocating loginVC...");
        _loginVC = [[LoginViewController alloc] init];
        NSLog(@"Allocated! %@", _loginVC);
    }
    
    return _loginVC;
}

- (void)updateRootVC {
    self.window.rootViewController = self.currentVC;
}

@end
