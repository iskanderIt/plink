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
#import "PlinkNotification.h"
#import "PlinkRoomController.h"

#import "FBFriendController.h"
#import "DocumentManager.h"
#import "ContactManager.h"

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
    
    [self.view addSubview:spinner];    
    [spinner startAnimating];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear, queue");
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear, queue: %@", self.queue);

    if(self.queue != nil)
    {
        [self performSegueWithIdentifier:@"OpenRoomByConversationID" sender:self.queue];
    }
}

-(void) syncConversationAndMessages:(PlinkNotification*) notification;
{
    NSLog(@"Start Sync Notification");
    
    self.cm = [ConversationManager new];
    self.sm = [ServerManager new];
    
    
    [self.cm loadConversations];
    // key: id obj: PlinkConversation
    NSDictionary* local = [self.cm conversations];
    // key: string id obj: Dictionary
    [self.sm loadConversations:^(NSDictionary *remote) {
        for(NSString* key in remote)
        {
            id item = [remote objectForKey:key];
            NSString* cID = [item objectForKey:@"id"];
            if([local objectForKey:cID] == nil){
                PlinkConversation* newC = [PlinkConversation new];
                
                newC.id = cID;
                newC.name = [item objectForKey:@"title"];
                newC.lastupdate = [item objectForKey:@"last"];
                newC.image = @"default";
                
                [self.cm addConversation:newC];
                [self.cm addParticipants:cID participants:[item objectForKey:@"users"]];
                
                PlinkMessage* msg = [PlinkMessage new];
                msg.cid = notification.cid;
                msg.image = notification.img;
                msg.id = notification.mid;
                msg.contactId = notification.uid;
                msg.isMine = NO;
                
                [self.cm addMessage:msg];
                // apri la stanza del messaggio
                [self performSegueWithIdentifier:@"OpenRoomByConversationID" sender:self];
                
            };
        }
        

        [self.tableView  beginUpdates];
        [self.tableView  insertRowsAtIndexPaths:[self.cm getConversationsAsIndexPaths]
                               withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView  endUpdates];
        
        [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                         withObject:nil
                                      waitUntilDone:NO];
        
        //        [self.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
        
        NSLog(@"End Sync Notification");
    }];
}

- (void) syncConversation
{
    NSLog(@"Start Sync");
    
    self.cm = [ConversationManager new];
    self.sm = [ServerManager new];

    
    [self.cm loadConversations];
    // key: id obj: PlinkConversation
    NSDictionary* local = [self.cm conversations];
    // key: string id obj: Dictionary
    [self.sm loadConversations:^(NSDictionary *remote) {
            for(NSString* key in remote)
            {
                id item = [remote objectForKey:key];
                NSString* cID = [item objectForKey:@"id"];
                if([local objectForKey:cID] == nil){
                    PlinkConversation* newC = [PlinkConversation new];
        
                    newC.id = cID;
                    newC.name = [item objectForKey:@"title"];
                    newC.lastupdate = [item objectForKey:@"last"];
                    newC.image = @"default";
        
                    [self.cm addConversation:newC];
                    [self.cm addParticipants:cID participants:[item objectForKey:@"users"]];
                };
            }
        
        [self.tableView  beginUpdates];
        [self.tableView  insertRowsAtIndexPaths:[self.cm getConversationsAsIndexPaths]
                               withRowAnimation:UITableViewRowAnimationNone];

        [self.tableView  endUpdates];
        
        [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                         withObject:nil
                                      waitUntilDone:NO];
        
//        [self.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:NO];
        
        NSLog(@"End Sync");
    }];
}
- (void) createConversation:(PlinkConversation *)obj partecipants:(NSArray *) ps
{
    if(obj == nil)
        return;
    
    if( ps == nil)
        return;
    
    if (self.cm == nil)
    {
        self.cm = [ConversationManager new];
    }
    id cm = self.cm;
    [self.sm addConversation:obj withUsers:ps complationhandler:^(NSString* conversationID) {
        obj.id = conversationID;
        obj.image = obj.image == nil ? [ContactManager getContactImageById:[ps objectAtIndex:0]] : obj.image;
        
        [cm addConversation:obj];
        [cm addParticipants:obj.id participants:ps];
    }];
}

//- (void) addParticipants:(NSArray *) participants
//{
//    if (self.cm == nil){
//        self.cm = [ConversationManager new];
//    }
//    
//    if(self.conversationId == NULL)
//    {
//        NSLog(@"Creating Conversation");
//        
//        PlinkConversation* c = [PlinkConversation new];
//        c.name = self.conversationName;
//        c.id =  CFBridgingRelease(CFUUIDCreateString(NULL,CFUUIDCreate(NULL)));
//        [self.cm addConversation:c];
//        self.conversationId = c.id;
//    }
//    
//    NSLog([NSString stringWithFormat:@"Room Add Participants - CM:%@",[self cm]]);
//    [[self cm] addParticipants:self.conversationId participants:participants];
//}

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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.   
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    
    PlinkConversation* conversation = ([[self cm] getConversationAtIndex:indexPath.row]);
    
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
    
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        [spinner stopAnimating];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"PrepareForSegue: %@ sender: %@", [segue identifier], sender);
//    Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"OpenRoomByConversationID"])
    {
        PlinkRoomController *rc = [segue destinationViewController];
        
        if([sender isMemberOfClass:[PlinkNotification class]])
        {
            PlinkNotification *source = (PlinkNotification *) sender;
            rc.conversationId = source.cid;
//            rc.conversationName = source.name.text;
            
        }else{
            PlinkConversationCell *source = (PlinkConversationCell *) sender;
            rc.conversationId = source.conversationID;
//            rc.conversationName = source.name.text;
        }
        
        self.queue = nil;
            

//        NSLog([NSString stringWithFormat:@"Opening Room With ID: %@",source.conversationID]);
    }
}
-(void) addMessageFromRemoteNotification:(NSDictionary*) payload
{
// payload:
//    {
//        "aps" : {
//            "alert" : "You got your emails.",
//            "badge" : 9,
//            "sound" : "bingbong.aiff"
//        },
//        "data" : {
//                  "cid" : "conversation id",
//                  "mid" : "message id",
//                  "uid" : "user id",
//                  "img" : "image remote path",
//                  },
//    }

//    NSString *alertValue = [[payload valueForKey:@"aps"] valueForKey:@"alert"];
    
    PlinkRoomController* rc = [PlinkRoomController new];
    PlinkMessage* msg = [PlinkMessage new];
    
    msg.cid = [[payload valueForKey:@"data"] valueForKey:@"cid"];
    msg.id = [[payload valueForKey:@"data"] valueForKey:@"mid"];
    msg.image = [[payload valueForKey:@"data"] valueForKey:@"img"];
    msg.contactId = [[payload valueForKey:@"data"] valueForKey:@"img"];

    [rc receivePushMessage:msg];
}

-(void) addConversationInQueue:(PlinkNotification*) notification
{
    self.queue = notification;
}

@end
