//
//  PlinkRoomController.h
//  Plink
//
//  Created by iskander on 9/12/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ConversationManager.h"
#import "PlinkMessage.h"

@interface PlinkRoomController : UIViewController
    <UIActionSheetDelegate,
    UITableViewDelegate,
    UITableViewDataSource,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UITabBarControllerDelegate>

@property (nonatomic, strong) UIActionSheet* actionSheet;
@property (nonatomic, strong) IBOutlet UIButton* showAction;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITabBar *tabBar;
@property (nonatomic, weak)   IBOutlet UIButton *centerButton;

- (IBAction)  showActionButtonTapped:(id)sender;
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView;
- (void)      actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)      addCenterButtonWithImage:(UIImage *)buttonImage highlightImage:(UIImage *)highlightImage target:(id)target action:(SEL)action;

- (void)      postMessage:(PlinkMessage *) message;
- (void)      receivePushMessage:(PlinkMessage*) message;




@property (nonatomic, strong) ConversationManager* cm;
@property (nonatomic, strong) NSString* conversationId;
@property (nonatomic, strong) NSString* conversationName;




@end
