//
//  PlinkConversationCell.h
//  Plink
//
//  Created by iskander on 9/17/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlinkConversationCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UILabel* name;
@property (nonatomic, strong) IBOutlet  UILabel* lastupdate;
@property (nonatomic, strong) IBOutlet  UIImageView* picture;
@property (nonatomic, strong) NSString* conversationID;


-(void) prepareForReuse;

@end
