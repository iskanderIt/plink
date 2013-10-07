//
//  FBFriendManager.m
//  Plink
//
//  Created by iskander on 9/17/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//
#import <FacebookSDK/FacebookSDK.h>
#import "FBFriendController.h"
#import "PlinkRoomController.h"

@implementation FBFriendController

@synthesize friendPickerController;
@synthesize nav;
@synthesize selectedFriends = _selectedFriends;

- (FBFriendController *) init
{
    self = [super init];
    self.friendPickerController = nil;
    return self;
}

- (FBFriendController *) initWithNavController:(UINavigationController *)navigator
{
    self.nav = navigator;
    return self;
}

- (void) selectContacts
{
    if(self.friendPickerController == nil)
    {
        self.friendPickerController = [[FBFriendPickerViewController alloc]
                                       initWithNibName:nil bundle:nil];
        self.friendPickerController.title = @"Select friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    [self.nav pushViewController:self.friendPickerController
              animated:true];

}


- (void) friendPickerViewControllerSelectionDidChange:
(FBFriendPickerViewController *)friendPicker
{
    self.selectedFriends = friendPicker.selection;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        [self addConversation:[[alertView textFieldAtIndex:0] text] ];
    }
}

- (void)facebookViewControllerDoneWasPressed:(id)sender
{

    UIAlertView *alertView = NULL;
    int sizeRoom = [self.selectedFriends count];
       
    if(sizeRoom == 1)
    {
       [self addConversation:[[self.selectedFriends objectAtIndex:0] name]];
    }else
    {
        alertView = [[UIAlertView alloc] initWithTitle:@"Titolo" message:@"Inserisci un nome:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
    }
}

- (void) addConversation:(NSString *) conversationName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    PlinkRoomController *roomController = [storyboard instantiateViewControllerWithIdentifier:@"PlinkRoomId"];
   
    NSMutableArray* friends = [[NSMutableArray alloc] initWithCapacity:0];
    for(int i = 0; i < [self.selectedFriends count]; i++)
    {
        id<FBGraphUser> f = [self.selectedFriends objectAtIndex:i];
        [friends addObject:[f id]];
    }
    
    PlinkConversation* c = [PlinkConversation new];
    c.name = conversationName;
    
    [roomController createConversation:c partecipants:friends];

    [self.nav popViewControllerAnimated:YES];
}

- (void) releaseAll
{
    friendPickerController = nil;
    friendPickerController.delegate = nil;
}

@end
