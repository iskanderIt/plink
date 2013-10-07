//
//  PlinkMessage.m
//  Plink
//
//  Created by iskander on 9/14/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import "PlinkMessage.h"

@implementation PlinkMessage

- (PlinkMessage *) init;
{
    self = [super init];
    self.id = CFBridgingRelease(CFUUIDCreateString(NULL,CFUUIDCreate(NULL)));
    return self;
}


//-(void) setHeight:(int)newValue
//{
//    NSLog(@"setHeight");
//    self.Height = newValue;;
//}
//
//-(void) setWdth:(int)newValue
//{
//    NSLog(@"setWidth");
//    self.Width = newValue;
//    
//}

@end
