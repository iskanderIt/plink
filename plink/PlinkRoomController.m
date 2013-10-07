//
//  PlinkRoomController.m
//  Plink
//
//  Created by iskander on 9/12/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//


#import "PlinkRoomController.h"
#import "PlinkMessage.h"
#import "PlinkMessageCell.h"
#import "DocumentManager.h"
#import "ContactManager.h"
#import "PlinkServerManager.h"
#import "AppDelegate.h"


@interface PlinkRoomController ()

@end

@implementation PlinkRoomController
@synthesize centerButton;

BOOL _newMedia;
BOOL _isMe = NO;
CGFloat SCREEN_WIDTH;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select what to Plink! from"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:@"Camera", @"Library", nil];

    SCREEN_WIDTH = CGRectGetWidth(self.view.bounds);
    
    self.tabBarController.delegate = self;
    self.cm = [ConversationManager new];
    self.title = self.conversationName;
   
     [self addCenterButtonWithImage:[UIImage imageNamed:@"plink.png"]
                     highlightImage:[UIImage imageNamed:@"plink.png"]
                             target:self
                             action:@selector(showActionButtonTapped:)];
    
    UIColor *bg = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    [self.tableView setBackgroundColor:bg];
    
    
    NSLog(@"View Did Load Room Controller");
}

- (void) viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
        
    if(self.conversationId != NULL && [self.conversationId length] > 0 ){
        NSLog([NSString stringWithFormat:@"Loading Conversation %@",self.conversationId]);
        
        [self.cm loadParticipants:self.conversationId];
        [self.cm loadMessages:self.conversationId];
        
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) showActionButtonTapped:(id)sender{
    [[self actionSheet] showInView:self.view];
}

-(void) viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        NSLog(@"Back Pressed");
    }
    [super viewWillDisappear:animated];
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
    
    AppDelegate* app = [UIApplication sharedApplication].delegate;
    [app.serverManager addConversation:obj withUsers:ps complationhandler:^(NSString* conversationID) {
        obj.id = conversationID;
        obj.image = obj.image == nil ? [ContactManager getContactImageById:[ps objectAtIndex:0]] : obj.image;
        
        self.conversationId = obj.id;
        
        [[self cm] addConversation:obj];
        [[self cm] addParticipants:obj.id participants:ps];
    }];
}

- (void) addParticipants:(NSArray *) participants
{
    if (self.cm == nil){
        self.cm = [ConversationManager new];
    }
    
    if(self.conversationId == NULL)
    {
        NSLog(@"Creating Conversation");
        
        PlinkConversation* c = [PlinkConversation new];
        c.name = self.conversationName;
        c.id =  CFBridgingRelease(CFUUIDCreateString(NULL,CFUUIDCreate(NULL)));
        [self.cm addConversation:c];
        self.conversationId = c.id; 
    }
    
    NSLog([NSString stringWithFormat:@"Room Add Participants - CM:%@",[self cm]]);    
    [[self cm] addParticipants:self.conversationId participants:participants];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //Get the name of the current pressed button
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"Camera"]) {
       
//        [self useCamera:actionSheet];
        _isMe = NO;
        [self useLibrary:actionSheet];
    }
    if  ([buttonTitle isEqualToString:@"Library"]) {
        _isMe = YES;
        [self useLibrary:actionSheet];
    }
}

- (void) useCamera:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
//        NSLog(@"Camera");
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
        _newMedia = YES;
    }
}

- (void) useLibrary:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
//        NSLog(@"Library");
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
        _newMedia = NO;
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
//        _imageView.image = image;
        
            PlinkMessage *msg = [PlinkMessage new];
            msg.image = [self procImg:image scaledToSize:CGSizeMake(240,240)];
            AppDelegate* app = [UIApplication sharedApplication].delegate;
            msg.contactId = app.identityId;
            msg.isMine = _isMe;
            msg.cid = self.conversationId;
        
            msg.Height = image.size.height;
            msg.Width = image.size.width;
        
            [app.serverManager addMessage:msg
                         toConversationId:self.conversationId
                        complationhandler:^(void)
        {
            [[self cm] addMessage:self.conversationId message:msg];
            if (_newMedia)
                UIImageWriteToSavedPhotosAlbum([UIImage imageNamed:msg.image],
                                               self,
                                               @selector(image:finishedSavingWithError:contextInfo:),
                                               nil);
        }];
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
    
}

- (void) postMessage:(PlinkMessage *) msg
{
    [[self cm] addMessage:_conversationId message:msg];
    
    int count = [[self cm] getConversazionLen:_conversationId];
    
    NSIndexPath *last = [NSIndexPath indexPathForRow:(count -1) inSection:0];
//    NSLog([NSString stringWithFormat:@"Section: %d Row: %d",last.section, last.row]);
    
    [self.tableView scrollToRowAtIndexPath:last atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
//    NSLog(@"Message From Library Sent");
//    NSLog([NSString stringWithFormat:@"%@", self.tableView]);
    
}

- (NSString*) procImg:(UIImage *) image scaledToSize:(CGSize)newSize;
{
//    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1);
//    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationHigh);
//    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    UIImage* newImage = image;
    
    NSString* fileName = [NSString stringWithFormat:@"%d.jpeg",newImage.hash];
    NSString* imagePath = [DocumentManager filePath:fileName];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: imagePath ] == NO)
    {
        NSData* data = UIImageJPEGRepresentation(newImage,0);
        [data writeToFile:imagePath atomically:YES];
    }
    return fileName;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // data not ready?
    return [[self cm] getConversazionLen:_conversationId] > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self cm] getConversazionLen:_conversationId];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 240;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlinkMessage* message = [[self cm] getMessage:_conversationId message:indexPath.row];
    NSString* CellIdentifier = (message.isMine)? @"OwnMessage" : @"OtherMessage";
    
    PlinkMessageCell *cell = (PlinkMessageCell* )[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [self configureCustomCell:cell withCellIdentifier:CellIdentifier withMessage:message];
    
    return cell;
}

- (void) configureCustomCell:(PlinkMessageCell *) cell withCellIdentifier:(NSString *)CellIdentifier withMessage:(PlinkMessage*) message
{
    if (cell == nil) {
        cell = [[PlinkMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        // here create cell layout
        /*
         photo = [[UIImageView alloc] initWithFrame:CGRectMake(225.0, 0.0, 80.0, 45.0)];
         photo.tag = PHOTO_TAG;
         photo.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
         [cell.contentView addSubview:photo];
         */
    }

    UIImage *img = [DocumentManager getImage:message.image];
    
    [[cell name] setText:[ContactManager getContactNameById:message.contactId ]];
    [[cell picture] setImage:img];
    [cell setAutoresizingMask:UIViewAutoresizingNone];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

// Create a custom UIButton and add it to the center of our tab bar
- (void)addCenterButtonWithImage:(UIImage *)buttonImage highlightImage:(UIImage *)highlightImage target:(id)target action:(SEL)action
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
//    NSLog([NSString stringWithFormat:@"Heights - img: %d bar: %d", buttonImage.size.height, self.tabBar.frame.size.height]);
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0) {
        button.center = self.tabBar.center;
    } else {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabBar addSubview:button];
    self.centerButton = button;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    NSLog(@"TabBarPressed");
    if(self.tabBarController.selectedIndex != 2){
        [self performSelector:@selector(doNotHighlight:) withObject:centerButton afterDelay:0];
    }
}

@end
