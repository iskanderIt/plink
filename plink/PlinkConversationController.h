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
#import "ServerManager.h"
#import "FBFriendController.h"
#import "PlinkNotification.h"


@interface PlinkConversationController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) FBFriendController *contactManager;
@property (nonatomic, strong) ConversationManager* cm;
@property (nonatomic, strong) ServerManager* sm;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) PlinkNotification* queue;

-(void)     addConversationInQueue:(PlinkNotification*) notification;
-(void)     syncConversation;
-(void)     syncConversationAndMessages:(PlinkNotification*) notification;
-(void)     createConversation:(PlinkConversation *)obj partecipants:(NSArray *) ps;

-(void)     addMessageFromRemoteNotification:(NSDictionary*) payload;
//- (void)      addParticipants:(NSArray *) participants;
@end
