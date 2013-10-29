//
//  PlinkLoginController.h
//  Plink
//
//  Created by iskander on 9/17/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlinkLoginController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *loginButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)loginButtonTapped:(id)sender;

@end
