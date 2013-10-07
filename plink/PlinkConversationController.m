//
//  ViewController.m
//  Plink
//
//  Created by iskander on 9/10/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "PlinkConversationController.h"
#import "PlinkConversationCell.h"
#import "PlinkConversation.h"
#import "PlinkRoomController.h"

#import "FBFriendController.h"
#import "DocumentManager.h"

@interface PlinkConversationController ()

@end

@implementation PlinkConversationController

@synthesize spinner;
@synthesize contactManager;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"Conv Controller View Did Load Fuck");
    
    spinner =  [[UIActivityIndicatorView alloc]
                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(160, 240);
    spinner.hidesWhenStopped = YES;
    
    UIBarButtonItem *newConversationButton = [[UIBarButtonItem alloc] initWithTitle:@"New"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(selectContacts)];
    self.navigationItem.rightBarButtonItem = newConversationButton;
    
    UIColor *bg = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    [self.tableView setBackgroundColor:bg];

}

- (void) viewReady
{
    self.cm = [ConversationManager new];
    self.cm.loader = spinner;
    [self.view addSubview:spinner];
    
    [self.cm loadConversations];
// manca l'update della grafica '
//   https://developer.apple.com/library/ios/documentation/userexperience/conceptual/tableview_iphone/ManageInsertDeleteRow/ManageInsertDeleteRow.html 
    [self.tableView reloadData];
}

- (void) selectContacts
{
    if (!self.contactManager) {
        self.contactManager = [[FBFriendController new] initWithNavController:self.navigationController];
    }
    [self.contactManager selectContacts];
}

- (void) viewDidUnload
{
    [self.contactManager releaseAll];
}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"Conv Controller View Did Appear");
//    NSLog([NSString stringWithFormat:@"%@",[self cm] ]);
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self cm] conversations] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlinkConversationCellId";
    PlinkConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = (PlinkConversationCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    PlinkConversation* conversation = ([[[self cm] conversations] objectAtIndex:indexPath.row]);
    
    if(conversation != NULL){
//        nameLabel.text = [NSString stringWithFormat:@"%@",conversation.name];
        cell.conversationID = conversation.id;
        cell.name.text = [NSString stringWithFormat:@"%@",conversation.name];
        cell.picture.image = [DocumentManager getImage:conversation.image];

    }else{
//        nameLabel.text = @"No conversations yet";
        cell.name.text = @"No conversations yet";
    }    
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    NSLog([NSString stringWithFormat:@"PrepareForSegue: %@", [segue identifier]]);
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"OpenRoomByConversationID"])
    {
        PlinkConversationCell *source = (PlinkConversationCell *) sender;
        // Get reference to the destination view controller
        PlinkRoomController *rc = [segue destinationViewController];
        rc.conversationId = source.conversationID;
        rc.conversationName = source.name.text;
//        NSLog([NSString stringWithFormat:@"Opening Room With ID: %@",source.conversationID]);
    }
}
@end
