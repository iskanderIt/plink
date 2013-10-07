//
//  PlinkMessage.h
//  Plink
//
//  Created by iskander on 9/14/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlinkMessage : NSObject

@property (nonatomic, strong) NSString* id;
@property (nonatomic, strong) NSString* cid;
@property (nonatomic, strong) NSString* image;
@property (nonatomic, strong) NSString* contactId;
@property (nonatomic, strong) NSString* lastUpdate;
@property (nonatomic) BOOL isMine;

@property (nonatomic)         int       Height;
@property (nonatomic)         int       Width;

- (PlinkMessage *) init;

//-(void) setHeight:(int)newValue;
//-(void) setWdth:(int)newValue;

@end
