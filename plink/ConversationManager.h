//
//  MessageManager.h
//  Plink
//
//  Created by iskander on 9/15/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlinkConversation.h"
#import "PlinkMessage.h"
#import "sqlite3.h"

@interface ConversationManager : NSObject

@property (nonatomic, strong) UIActivityIndicatorView *loader;

@property (nonatomic, strong) NSString *conversationPath;
@property (nonatomic, strong) NSString *participantPath;
@property (nonatomic, strong) NSString *messagePath;

@property (nonatomic) sqlite3 *conversationDB;
@property (nonatomic) sqlite3 *participantDB;
@property (nonatomic) sqlite3 *messageDB;

@property (nonatomic,strong) NSMutableArray* conversations;
@property (nonatomic,strong) NSMutableArray* participants;
@property (nonatomic,strong) NSMutableArray* messages;

- (void) addConversation:(PlinkConversation *) obj;
- (void) loadConversations;
- (int)  getConversazionLen:(NSString *) conversationID;

- (void) addParticipant: (NSString *) conversationID participant:(NSString *) p;
- (void) addParticipants: (NSString *) conversationID participants:(NSArray *) ps;
- (void) loadParticipants:(NSString *) conversationID;
- (void) loadMessages:(NSString *) conversationID;

- (void) loadMessages:(NSString *) conversationID;
- (void) addMessage: (NSString *) conversationID message:(PlinkMessage *) msg;
- (PlinkMessage *) getMessage:(NSString *)conversationID message:(int)index;


@end
