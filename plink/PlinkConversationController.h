//
//  ViewController.h
//  Plink
//
//  Created by iskander on 9/10/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "ConversationManager.h"
#import "FBFriendController.h"


@interface PlinkConversationController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) FBFriendController *contactManager;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic,strong) ConversationManager* cm;
@property (nonatomic) NSString* conversationID;
@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *conversations;

-(void) viewDidAppear:(BOOL)animated;
-(void) viewReady;
@end
