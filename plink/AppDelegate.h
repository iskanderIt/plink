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
#import "PlinkServerManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) UINavigationController* navController;
@property (nonatomic, strong) PlinkLoginController *loginController;
@property (nonatomic, strong) PlinkConversationController *conversationController;
@property (nonatomic, strong) UIStoryboard *storyboard;

@property (nonatomic, strong) PlinkServerManager *serverManager;

@property (nonatomic, strong) NSString* identityName;
@property (nonatomic, strong) NSString* identityId;

- (void) openSession;



@end

