//
//  PlinkMessageCell.h
//  Plink
//
//  Created by iskander on 10/1/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlinkMessageCell : UITableViewCell

@property (nonatomic, strong) IBOutlet  UILabel* name;
@property (nonatomic, strong) IBOutlet  UILabel* lastupdate;
@property (nonatomic, strong) IBOutlet  UIImageView* picture;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
