//
//  FBFriendManager.h
//  Plink
//
//  Created by iskander on 9/17/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FBFriendController : UIViewController<FBFriendPickerDelegate>

@property (strong, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (strong, nonatomic) UINavigationController *nav;
@property (strong, nonatomic) NSArray* selectedFriends;

- (void) addConversation:(NSString *) conversationName;
- (void) selectContacts;
- (void) releaseAll;
- (FBFriendController *) initWithNavController:(UINavigationController *)navigator;

@end
