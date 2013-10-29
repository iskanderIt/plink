//
//  MessageManager.m
//  Plink
//
//  Created by iskander on 9/15/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import "ConversationManager.h"
#import "PlinkConversation.h"
#import "DocumentManager.h"

@implementation ConversationManager

static int ID_FIELD = 0;
static int NAME_FIELD = 1;
static int IMAGE_FIELD = 2;
static int LAST_FIELD = 3;

static int MESSAGE_ID_FIELD = 0;
static int MESSAGE_CID_FIELD = 1;
static int MESSAGE_SENDER_FIELD = 2;
static int MESSAGE_IMAGE_FIELD =3;
static int MESSAGE_DATETIME_FIELD = 4;
static int MESSAGE_ISMINE_FIELD = 5;
static int MESSAGE_HEIGHT_FIELD = 6;
static int MESSAGE_WIDTH_FIELD = 7;


-(id)init
{
    self = [super init];
    
    [self testOrCreateConversationsDb];
    [self testOrCreateMessagesDb];
    [self testOrCreateParticipantsDb];
    
    return self;
}
 
-(void) testOrCreateConversationsDb
{
    // Build the path to the database file
    _conversationPath = [DocumentManager filePath: @"conversations.db"];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _conversationPath ] == NO)
    {
        const char *dbpath = [_conversationPath UTF8String];
        
        if (sqlite3_open(dbpath, &_conversationDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS CONVERSATIONS (ID TEXT, NAME TEXT, IMAGE TEXT, LASTUPDATE TEXT)";
            
            if (sqlite3_exec(_conversationDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            sqlite3_close(_conversationDB);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}

-(void) testOrCreateParticipantsDb
{
    // Build the path to the database file
    _participantPath = [DocumentManager filePath: @"participants.db"];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _participantPath ] == NO)
    {
        const char *dbpath = [_participantPath UTF8String];
        
        if (sqlite3_open(dbpath, &_participantDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS PARTICIPANTS (CONVERSATION TEXT, PARTICIPANT TEXT)";
            
            if (sqlite3_exec(_participantDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            sqlite3_close(_participantDB);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}

-(void) testOrCreateMessagesDb
{   
    // Build the path to the database file
    _messagePath = [DocumentManager filePath: @"messages.db"];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _messagePath ] == NO)
    {
        const char *dbpath = [_messagePath UTF8String];
        
        if (sqlite3_open(dbpath, &_messageDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS MESSAGES (ID TEXT, CONVERSATION TEXT, SENDER TEXT, IMAGE TEXT, DATETIME TEXT, ISMINE INTEGER, HEIGHT INTEGER, WIDTH INTEGER)";
            
            if (sqlite3_exec(_messageDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            sqlite3_close(_messageDB);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}

- (void) addConversation:(PlinkConversation *) obj
{
    NSLog(@"Add conversation: %@ (%@)", obj.name, obj.id);
    
    sqlite3_stmt    *statement;
    const char *dbpath = [_conversationPath UTF8String];
    
    if (sqlite3_open(dbpath, &_conversationDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO CONVERSATIONS (id, name, image, lastupdate) VALUES (\"%@\", \"%@\", \"%@\", \"%@\")",
                               obj.id, obj.name, obj.image, obj.lastupdate ];
        
//        NSLog(insertSQL);
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_conversationDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Conversation added: %@", obj);
        } else {
            NSLog(@"Failed to add conversation");
            NSLog(@"%s", sqlite3_errmsg(_conversationDB));
        }
        sqlite3_finalize(statement);
        sqlite3_close(_conversationDB);
        
        [[self conversations] setObject:obj forKey:obj.id];
    }
}
-(PlinkConversation*) getConversationAtIndex:(int)index
{
    NSEnumerator* e = [self.conversations objectEnumerator];
    id value;
    int i = 0;
    while(value = [e nextObject]){
        if(i > index)
            return nil;
        
        if(index == i)
            return value;
        i++;
    }
    return nil;
}
- (void) addParticipant: (NSString *) conversationID participant:(NSString *) p
{
//    NSLog([NSString stringWithFormat:@"Add participant: %@", p]);
    
    sqlite3_stmt *statement;
    const char *dbpath = [_participantPath UTF8String];
    
    if (sqlite3_open(dbpath, &_participantDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO PARTICIPANTS (conversation, participant) VALUES (\"%@\", \"%@\")",
                               conversationID, p];
        
//        NSLog(insertSQL);
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_participantDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Participant added");
        } else {
            NSLog(@"Failed to add participant");
//            NSLog([NSString stringWithFormat:@"%s", sqlite3_errmsg(_participantDB)]);
        }
        sqlite3_finalize(statement);
        sqlite3_close(_participantDB);
    }
}
- (void) addParticipants: (NSString *) conversationID participants:(NSArray *) ps
{
    for(int i = 0; i < [ps count]; i++)
    {
        [self addParticipant:conversationID participant:[ps objectAtIndex:i]];
    }
}

- (void) loadParticipants:(NSString *) conversationID
{
    self.participants = [[NSMutableArray alloc] initWithCapacity:0];
    
    const char *dbpath = [_participantPath UTF8String];
    sqlite3_stmt    *statement;
    
    NSLog(@"Reading sqlite db -> load Participants");
    
    if (sqlite3_open(dbpath, &_participantDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT PARTICIPANT FROM PARTICIPANTS WHERE CONVERSATION = \"%@\"", conversationID];
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_participantDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                
                NSString * participant = [[NSString alloc]
                                         initWithUTF8String:
                                         (const char *) sqlite3_column_text(
                                                                            statement, 0)];
                
//                NSLog([NSString stringWithFormat:@"Participant( %@ )",participant]);
                
                [self.participants addObject:participant];
                
            }
            sqlite3_finalize(statement);
        }else{
            
//            NSLog([NSString stringWithFormat:@"Error loading participant: %s", sqlite3_errmsg(_participantDB)]);
        }
        sqlite3_close(_participantDB);
    }else{
        NSLog(@"Error Opening DB Code: %s", sqlite3_errmsg(_participantDB));
    }
}
-(NSArray*) getConversationsAsIndexPaths
{
    NSMutableArray* indexs = [[NSMutableArray alloc] initWithCapacity:0];
    NSEnumerator* e = [[self conversations] objectEnumerator];
    id item;
    int i = 0;
    while(item = [e nextObject]){
//        NSLog(@"AsIndexPath (obj, section, row) = (%@,%d,%d)", item, 0, i);
        [indexs addObject:[NSIndexPath indexPathForRow:i++ inSection:0]];
    }
    return indexs;
}

- (void) addMessage:(PlinkMessage *) msg
{
//    NSLog([NSString stringWithFormat:@"Add message: %@ %@ %@", msg.contactId, conversationID, msg.image]);
    
    
    sqlite3_stmt    *statement;
    const char *dbpath = [_messagePath UTF8String];
    
    if (sqlite3_open(dbpath, &_messageDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO MESSAGES (id, conversation, sender, image, datetime, ismine, height, width) VALUES (\"%@\",\"%@\", \"%@\", \"%@\", \"data_toset\", %d, %d, %d)",
                               msg.id, msg.cid, msg.contactId, msg.image, msg.isMine?1:0, msg.Height, msg.Width];
        NSLog(insertSQL);
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_messageDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Message added");
        } else {
            NSLog(@"Failed to add message");
//            NSLog([NSString stringWithFormat:@"%s", sqlite3_errmsg(_messageDB) ]);
        }
        sqlite3_finalize(statement);
        sqlite3_close(_messageDB);
        [self.messages addObject:msg];
    }
//        [self propagateMessages];
}

- (void) loadConversations
{
    
    self.conversations = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    const char *dbpath = [_conversationPath UTF8String];
    sqlite3_stmt    *statement;
    
    NSLog(@"Reading sqlite db -> load Conversations");
    
    if (sqlite3_open(dbpath, &_conversationDB) == SQLITE_OK)
    {
        NSString *querySQL = @"SELECT ID, NAME, IMAGE, LASTUPDATE FROM CONVERSATIONS";
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_conversationDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                
                PlinkConversation *conversation = [PlinkConversation new];
                
                conversation.id = [[NSString alloc]
                                   initWithUTF8String:
                                   (const char *) sqlite3_column_text(
                                                                      statement, ID_FIELD)];
                conversation.name = [[NSString alloc]
                                     initWithUTF8String:
                                     (const char *) sqlite3_column_text(
                                                                        statement, NAME_FIELD)];
                conversation.image = [[NSString alloc]
                                     initWithUTF8String:
                                     (const char *) sqlite3_column_text(
                                                                        statement, IMAGE_FIELD)];
                //                NSString *imageField = [[NSString alloc]
                //                                     initWithUTF8String:
                //                                     (const char *) sqlite3_column_text(
                //                                                                        statement, IMAGE_FIELD)];
//                conversation.lastupdate = [[NSString alloc]
//                                       initWithUTF8String:
//                                       (const char *) sqlite3_column_text(statement, LAST_FIELD)];
//                
//                NSLog([NSString stringWithFormat:@"Found Conversation( %@ ,%@, %@, %@ )",conversation.id, conversation.name, conversation.image, conversation.lastupdate]);
                
                NSLog(@"Loading conversation (id, name, users): (%@,%@) forKey:%@",conversation.id,conversation.name,conversation.id);
                [self.conversations setObject:conversation
                                       forKey:conversation.id];
                
            }
            sqlite3_finalize(statement);
        }else{
            
            NSLog(@"Error loading conversations: %s", sqlite3_errmsg(_conversationDB));
        }
        sqlite3_close(_conversationDB);
    }else{
        NSLog(@"Error Opening DB Code: %s", sqlite3_errmsg(_conversationDB));
    }
}

- (int)  getConversazionLen:(NSString*) conversationID
{
    return [[self messages]count];
}

- (void) loadMessages: (NSString*) conversationID
{
    
    const char *dbpath = [_messagePath UTF8String];
    sqlite3_stmt    *statement;
    
    self.messages = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (sqlite3_open(dbpath, &_messageDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT ID, CONVERSATION, SENDER, IMAGE, DATETIME, ISMINE, HEIGHT, WIDTH FROM MESSAGES WHERE CONVERSATION = \"%@\"", conversationID];
//        NSLog([NSString stringWithFormat:@"loadMessages from %@",conversationID]);
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_messageDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            self.messages = [[NSMutableArray alloc] initWithCapacity:0];
            
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                
                PlinkMessage *message = [PlinkMessage new];
                message.id = [[NSString alloc]
                              initWithUTF8String:
                              (const char *) sqlite3_column_text(
                                                                 statement, MESSAGE_ID_FIELD)];
                message.cid = [[NSString alloc]
                              initWithUTF8String:
                              (const char *) sqlite3_column_text(
                                                                 statement, MESSAGE_CID_FIELD)];
                message.contactId = [[NSString alloc]
                                     initWithUTF8String:
                                     (const char *) sqlite3_column_text(
                                                                        statement, MESSAGE_SENDER_FIELD)];
                message.image =  [[NSString alloc]
                                  initWithUTF8String:
                                  (const char *) sqlite3_column_text(
                                                                     statement, MESSAGE_IMAGE_FIELD)];
                message.lastUpdate = [[NSString alloc]
                                           initWithUTF8String:
                                           (const char *) sqlite3_column_text(statement, MESSAGE_DATETIME_FIELD)];
                message.isMine = sqlite3_column_int(statement, MESSAGE_ISMINE_FIELD) > 0 ? YES : NO;
                message.Height = sqlite3_column_int(statement, MESSAGE_HEIGHT_FIELD);
                message.Width = sqlite3_column_int(statement, MESSAGE_WIDTH_FIELD);
                
                [[self messages] addObject:message];
                
            }
            sqlite3_finalize(statement);
        }else{
            
            NSLog(@"Error loading messages: %s", sqlite3_errmsg(_messageDB));
        }
        sqlite3_close(_messageDB);
    }else{
        NSLog(@"Error Opening DB Code: %s", sqlite3_errmsg(_conversationDB));
    }
}

- (PlinkMessage *) getMessage:(NSString *)conversationID message:(int)index
{
    [self loadMessages:conversationID];
    //    [self propagateContacts];
    return [[self messages] objectAtIndex:index];
}


@end
