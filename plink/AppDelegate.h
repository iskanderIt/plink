//
//  AppDelegate.h
//  Plink
//
//  Created by iskander on 9/10/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlinkConversationController.h"
#import "PlinkLoginController.h"
#import "ServerManager.h"
#import "PlinkNotification.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) UINavigationController* navController;
@property (nonatomic, strong) PlinkLoginController *loginController;
@property (nonatomic, strong) PlinkConversationController *conversationController;
@property (nonatomic, strong) UIStoryboard *storyboard;

@property (nonatomic, strong) ServerManager *serverManager;

@property (nonatomic, strong) NSString* identityName;
@property (nonatomic, strong) NSString* identityId;
@property (nonatomic)         NSData* deviceID;

@property (nonatomic)         PlinkNotification* notification;

- (void) openSession;



@end

