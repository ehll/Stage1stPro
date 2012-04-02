//
//  AppDelegate.m
//  Stage1stPro
//
//  Created by Suen Gabriel on 3/23/12.
//  Copyright (c) 2012 Gabriel Studio. All rights reserved.
//

#import "AppDelegate.h"
#import "QuartzCore/QuartzCore.h"
#import "ASIFormDataRequest.h"
#import "TitleViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize nvc = _nvc;

- (void)dealloc
{
    [_nvc release];
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor blackColor];
    TitleViewController *tvc = [[TitleViewController alloc] init];
    self.nvc = [[[UINavigationController alloc] initWithRootViewController:tvc] autorelease];
    self.nvc.view.layer.cornerRadius = 5.0;
    [tvc release];
    self.nvc.navigationBar.barStyle = UIBarStyleBlack;
    [self.window addSubview:self.nvc.view];
    [self.window makeKeyAndVisible];
    
    //send a request to server to get the cookie
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://bbs.saraba1st.com/2b/m/login.php"]];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"userid"] forKey:@"pwuser"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"userpw"] forKey:@"pwpwd"];
    [request setPostValue:@"0" forKey:@"lgt"];
    /*
    [request setCompletionBlock:^{
        NSLog(@"%@", [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding]);
    }];
    */
    [request startAsynchronous];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
