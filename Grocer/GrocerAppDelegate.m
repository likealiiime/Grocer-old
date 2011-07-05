//
//  GrocerAppDelegate.m
//  Grocer
//
//  Created by Sherród Faulks on 2/21/11.
//  Copyright 2011 Soft Illuminations, Inc. All rights reserved.
//

#import "GrocerAppDelegate.h"

@implementation GrocerAppDelegate

@synthesize window=_window;
@synthesize navigationController=_navigationController;

@synthesize db=_db;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _db = [[FMDatabase alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"Grocer" ofType:@"db"]];
   
    if (![self.db open]) {
        NSLog(@"Could not open db.");
        abort();
    }
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
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
    NSLog(@"DID ENTER BACKGROUND");
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"WILL ENTER FOREGROUND");
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"DID BECOME ACTIVE");
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

- (void)dealloc
{
    [self.db close];
    
    [_window release];
    [_navigationController release];
    [self.db release];
    [super dealloc];
}

@end
