//
//  PlinkServerManager.m
//  Plink
//
//  Created by iskander on 10/2/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import "Defs.h"
#import "ServerManager.h"
#import "DocumentManager.h"



@implementation ServerManager

//SRWebSocket *_webSocket;
//NSMutableArray *_messages;


NSString* sessionCookie;

-(void) openServerChannel:(NSString*) token withDeviceID:(NSData*) device completionHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error)) handler{

    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ISREMOTE?REMOTE:LOCAL,@"auth"]];
    
    NSString *deviceToken = [device description];
	deviceToken = [deviceToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"dev str: %@",deviceToken);
    NSString *postString = [NSString stringWithFormat:@"token=%@&pushId=%@&type=%@",token, deviceToken, @"ios"];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:sessionCookie forHTTPHeaderField:@"Cookie"];
    [urlRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
        
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)r;
        NSDictionary *fields = [HTTPResponse allHeaderFields];
        sessionCookie = [fields valueForKey:@"Set-Cookie"]; // It is your cookie
        handler(r,d,e);
    }];
}

-(void) addConversation:(PlinkConversation*) conversation withUsers:(NSArray*)users complationhandler:(void (^)(NSString* conversationID)) handler;
{
    NSOperationQueue* queue = [[NSOperationQueue alloc]init];
    
    NSError* err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:users options:NSJSONWritingPrettyPrinted error:&err];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",ISREMOTE?REMOTE:LOCAL,@"conversations",@"open"]];
    
    NSString *postString = [NSString stringWithFormat:@"title=%@&users=%@",[conversation name], jsonString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:sessionCookie forHTTPHeaderField:@"Cookie"];
    [urlRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error)
     {
         // Check if status is :200
         if (error == nil)
         {
             NSString* conversationID = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             handler(conversationID);
         }
         else {
             NSLog(@"error: %@ response: %@ data: %@", error, response, data);
         }
     }];
}

- (void) loadConversations: (void (^)(NSDictionary* remote))handler
{

    NSMutableDictionary* conversations = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSOperationQueue* queue = [[NSOperationQueue alloc]init];
    

//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:users options:NSJSONWritingPrettyPrinted error:&err];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",ISREMOTE?REMOTE:LOCAL,@"conversations",@"list"]];
    
//    NSString *postString = [NSString stringWithFormat:@"title=%@&users=%@",[conversation name], jsonString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    
    [urlRequest setHTTPMethod:@"GET"];
//    [urlRequest setValue:sessionCookie forHTTPHeaderField:@"Cookie"];
//    [urlRequest setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    [urlRequest setValue:sessionCookie forHTTPHeaderField:@"Cookie"];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error)
     {
         // Check if status is :200
         if (error == nil)
         {
             NSError* err;
//             id, title, users, last
             NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:&err];
             
             for(NSDictionary* c in jsonArray)
             {
//                 NSLog(@"c: %@",c);
                 [conversations setObject:c
                                   forKey:[c objectForKey:@"id"]];
             }
             handler(conversations);
//             NSLog(@"Dictionary from servers: %@ :",conversations);
         }
         else {
             NSLog(@"error: %@ response: %@ data: %@", error, response, data);
         }
     }];
}

-(void) addMessage:(PlinkMessage*) message toConversationId:(NSString*) conversationID complationhandler:(void (^)(void)) handler
{
    
    NSMutableData *postData = [[NSMutableData alloc] init];
    NSOperationQueue* queue = [[NSOperationQueue alloc]init];    
    NSString *fileName = message.image;
    //Prepare data for file
    NSString *boundary = @"AaB03x";
    
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@\"\r\n", fileName]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    NSData* dataImg = [NSData dataWithContentsOfFile:[DocumentManager filePath:fileName]];
    // Add Media Data
    [postData appendData:[NSData dataWithData:dataImg]];
    
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",ISREMOTE?REMOTE:LOCAL,@"send",conversationID]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];

    
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postData length]] forHTTPHeaderField:@"Content-Length"];
    [urlRequest setValue:@"multipart/form-data; boundary=AaB03x" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:sessionCookie forHTTPHeaderField:@"Cookie"];
    [urlRequest setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error == nil)
         {
             handler();
             NSLog(@"addMessage response: %@ data: %@", response, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
         }
         else {
             NSLog(@"addMessage error: %@ response: %@ data: %@", error, response, data);
         }
     }];
    
}

-(void) openEventChannel
{
//    [self _reconnect];
}

//- (void)_reconnect;
//{
//    _webSocket.delegate = nil;
//    [_webSocket close];
//    
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",@"http://192.168.145.1:9000",@"events"]];
//    NSMutableURLRequest *webSocketReq = [[NSMutableURLRequest alloc] initWithURL:url];
//    [webSocketReq setHTTPMethod:@"GET"];
//    [webSocketReq setValue:sessionCookie forHTTPHeaderField:@"Cookie"];
//    
//    NSLog(@"WebSocket URL: %@", url);
//    NSLog(@"WebSocket Cookie:\n%@", sessionCookie);
//    _webSocket = [[SRWebSocket alloc] initWithURLRequest:webSocketReq];
//    _webSocket.delegate = self;
//    
//    [_webSocket open];
//    
//}
//
//- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
//{
//    NSLog(@"Websocket Connected");
//}
//
//- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
//{
//    NSLog(@":( Websocket Failed With Error %@", error);
//    _webSocket = nil;
//}
//
//- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
//{
//    NSLog(@"Received \"%@\"", message);
////    [_messages addObject:[[TCMessage alloc] initWithMessage:message fromMe:NO]];
//}
//
//- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
//{
//    NSLog(@"WebSocket closed");
//    _webSocket = nil;
//}

@end
