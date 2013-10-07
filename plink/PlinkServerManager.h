//
//  PlinkServerManager.h
//  Plink
//
//  Created by iskander on 10/2/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlinkConversation.h"
#import "PlinkMessage.h"


@interface PlinkServerManager : NSObject

-(void) addConversation:(PlinkConversation*) conversation withUsers:(NSArray*)users complationhandler:(void (^)(NSString*)) handler;
-(void) addMessage:(PlinkMessage*) message toConversationId:(NSString*) conversationID complationhandler:(void (^)(void)) handler;
-(void) openServerChannel:(NSString*) token completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error)) handler;


-(void) openEventChannel;
@end