//
//  PlinkConversationCell.m
//  Plink
//
//  Created by iskander on 9/17/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import "PlinkConversationCell.h"

@implementation PlinkConversationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) prepareForReuse
{
    self.picture = nil;
    self.conversationID = nil;
}

@end
