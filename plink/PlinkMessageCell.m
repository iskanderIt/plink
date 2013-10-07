//
//  PlinkMessageCell.m
//  Plink
//
//  Created by iskander on 10/1/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import "PlinkMessageCell.h"

@implementation PlinkMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
   NSLog(@"initWithStyle");
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void) prepareForReuse
{
//    [self setNeedsDisplay];
//    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSLog(@"layoutSubviews");
//    self.picture.frame = CGRectMake(0,0,5,5);
}

@end
