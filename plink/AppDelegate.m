//
//  AppDelegate.m
//  Plink
//
//  Created by iskander on 9/10/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ServerManager.h"
#import "PlinkNotification.h"

@implementation AppDelegate

@synthesize storyboard;
@synthesize loginController;
@synthesize navController;
@synthesize conversationController;
@synthesize notification;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   	// Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    // Override point for customization after application launch.
    self.serverManager = [ServerManager new];
    self.storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.conversationController = [storyboard instantiateViewControllerWithIdentifier:@"ConversationControllerID"];   
    self.navController = [[UINavigationController alloc]
                          initWithRootViewController:self.conversationController];
    
    // set notification model
    self.notification = nil;
    if([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil)
    {
        NSDictionary* n = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        self.notification = [PlinkNotification new];
        self.notification.mid = [n valueForKey:@"mid"];
        self.notification.cid = [n valueForKey:@"cid"];
        self.notification.uid = [n valueForKey:@"uid"];
        self.notification.img = [n valueForKey:@"img"];
    }
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    NSLog(@"Received notification: %@", userInfo);
    
     self.notification = [PlinkNotification new];
     self.notification.mid = [userInfo valueForKey:@"mid"];
     self.notification.cid = [userInfo valueForKey:@"cid"];
     self.notification.uid = [userInfo valueForKey:@"uid"];
     self.notification.img = [userInfo valueForKey:@"img"];
    
//    [[self conversationController] syncConversationAndMessages:last];
//    NSLog(@"Received notification: %@", remote);
    
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"devToken=%@",deviceToken);

    self.deviceID = deviceToken;
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        // Yes, so just open the session (this won't display any UX).
        [self openSession];
    } else {
        // No, display the login page.
        [self showLoginView:NO];
    }
    
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
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
    
    // We need to properly handle activation of the application with regards to Facebook Login
    // (e.g., returning from iOS 6.0 Login Dialog or from fast app switching).
    NSLog(@"App - BecomeActive");
    [FBSession.activeSession handleDidBecomeActive];
    // quanto tappo su una notifica ricevo il payload della notifica, poi viene lanciato becomeactive.
    // Letta una notifica bsogna toglierla dal centro notifiche
    
    if(self.notification != nil)
    {
        //
//        if([[self.navController topViewController] isKindOfClass:[PlinkConversationController class]])
//        {
//            
//        }else{
//        
//        }
      
        NSArray* popped = [self.navController popToRootViewControllerAnimated:YES];
        NSLog(@"stack popped %lu",(unsigned long)[popped count] );
        PlinkConversationController *topViewController = (PlinkConversationController *) [self.navController topViewController];
        [topViewController setQueue:self.notification];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)showLoginView:(BOOL)animated
{
        PlinkConversationController *topViewController = (PlinkConversationController *) [self.navController topViewController];
        loginController = [storyboard instantiateViewControllerWithIdentifier:@"LoginControllerID"];
        [topViewController presentViewController:loginController animated:animated completion:nil];
}

- (void)openSession
{
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
    
}

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{   
    switch (state) {
        case FBSessionStateOpen: {
            
                NSLog(@"sessionStateChanged is FBSessionStateOpen %d", state);
            
                [[FBRequest requestForMe] startWithCompletionHandler:
                 ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *err) {

                     [[self serverManager] openServerChannel:[[session accessTokenData] accessToken]
                                                withDeviceID:[self deviceID]
                                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                             if (error == nil)
                             {                               
                                 if (!err) {
                                     self.identityId = user.id;
                                     self.identityName = user.name;
                                     
                                     if(loginController != NULL)
                                         [loginController dismissViewControllerAnimated:YES  completion:nil];
                                     
                                     loginController = nil;
                                     
                                     NSLog(@" finish requestForMe");
                                     if(self.notification != nil)
                                     {
                                         [[self conversationController] syncConversationAndMessages:self.notification];
                                     }else{
                                         [[self conversationController] syncConversation];
                                     }
                                     
                                 } else {
                                     NSLog(@"error2: %@", err);
                                 }
                             }
                             else {
                                 NSLog(@"error: %@ response: %@ data: %@", error, response, data);
                             } }];
                     }];                     
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            NSLog(@"sessionStateChanged is FBSessionStateClosedLoginFailed or FBSessionStateClosed %d", state);
            [loginController dismissViewControllerAnimated:YES  completion:nil];
            loginController = nil;
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            [self showLoginView:YES];
            break;
        default:
            NSLog(@"sessionStateChanged is other %d", state);
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

@end
