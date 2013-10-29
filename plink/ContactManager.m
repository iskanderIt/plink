//
//  ContactManager.c
//  Plink
//
//  Created by iskander on 9/11/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//
#import <FacebookSDK/FacebookSDK.h>

#include "ContactManager.h"
#include "PlinkContact.h"
#import "DocumentManager.h"


@implementation ContactManager

ABAddressBookRef* addressBook = NULL;
CFErrorRef* error = NULL;

static int ID_FIELD = 0;
static int NAME_FIELD = 1;
static int IMAGE_FIELD = 2;
static int PHONE_FIELD = 3;

- (id)init
{
    self = [super init];
    
    self.illegalChars =@[
                         @"(",
                         @")",
                         @"-",
                         @" "
                         ];
    
    self.numbersArray = [NSMutableArray new];
    self.jsonArray = [NSMutableArray arrayWithObjects:@"No contacts yet",nil];
    self.jsonData = [NSMutableData new];
        
    [self testOrCreateContactsDb];
    
    return self;
}

-(void) testOrCreateContactsDb
{
    _databasePath = [DocumentManager filePath: @"contacts.db"];

    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if ([filemgr fileExistsAtPath: _databasePath ] == NO)
    {
        const char *dbpath = [_databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS CONTACTS (ID TEXT PRIMARY KEY, NAME TEXT, IMAGE TEXT, PHONE TEXT)";
            
            if (sqlite3_exec(_contactDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                NSLog(@"Failed to create table");
            }
            sqlite3_close(_contactDB);
        } else {
            NSLog(@"Failed to open/create database");
        }
    }
}

- (void) emptyContactsDb
{
        sqlite3_stmt    *statement;
        const char *dbpath = [_databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
        {
            NSString *insertSQL = @"DELETE FROM CONTACTS";
            
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(_contactDB, insert_stmt,
                               -1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                NSLog(@"Contacts deleted");
            } else {
                NSLog(@"Failed to delete contacts");
            }
            sqlite3_finalize(statement);
            sqlite3_close(_contactDB);
        }
}

- (void) loadContacts
{
    const char *dbpath = [_databasePath UTF8String];
    sqlite3_stmt    *statement;
    NSMutableArray *contacts = [NSMutableArray new];

    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        NSString *querySQL = @"SELECT ID, NAME, IMAGE, PHONE FROM CONTACTS";
        
        const char *query_stmt = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(_contactDB,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                
                PlinkContact *contact = [PlinkContact new];
                
                contact.fid = [[NSString alloc]
                                  initWithUTF8String:
                                  (const char *) sqlite3_column_text(
                                                                     statement, ID_FIELD)];
                contact.nameLabel = [[NSString alloc]
                                     initWithUTF8String:
                                     (const char *) sqlite3_column_text(
                                                                        statement, NAME_FIELD)];
//                NSString *imageField = [[NSString alloc]
//                                     initWithUTF8String:
//                                     (const char *) sqlite3_column_text(
//                                                                        statement, IMAGE_FIELD)];
                contact.phoneNumber = [[NSString alloc]
                                        initWithUTF8String:
                                       (const char *) sqlite3_column_text(statement, PHONE_FIELD)];
                NSLog([NSString stringWithFormat:@"Contact( %@ ,%@, %@ )",contact.fid, contact.nameLabel, contact.phoneNumber]);
                
                [contacts addObject:contact];
                
            } 
            sqlite3_finalize(statement);
        }else{

            NSLog([NSString stringWithFormat:@"Prepare Query Code: %s", sqlite3_errmsg(_contactDB)]);
        }
        sqlite3_close(_contactDB);
    }else{
        NSLog([NSString stringWithFormat:@"Error Opening DB Code: %s", sqlite3_errmsg(_contactDB)]);
    }
    self.Contacts = contacts;
    [self propagateContacts];
}

- (void) propagateContacts
{
    [self.tableView reloadData];
}

- (void) regenerateContacts
{
    [self emptyContactsDb];
    
    for(int i = 0; i < [self.Contacts count]; i++)
    {
        [self addContact:[self.Contacts objectAtIndex:i]];
    }
}

- (void) addContact:(PlinkContact *) obj
{
    sqlite3_stmt    *statement;
    const char *dbpath = [_databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &_contactDB) == SQLITE_OK)
    {
        
        NSString *insertSQL = [NSString stringWithFormat: 
                               @"INSERT INTO CONTACTS (id, name, image, phone) VALUES (\"%@\", \"%@\", \"%@\", \"%@\")",
                               obj.fid, obj.nameLabel, obj.nameLabel,  obj.phoneNumber];
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(_contactDB, insert_stmt,
                           -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Contact added");
        } else {
            NSLog(@"Failed to add contact");
        }
        sqlite3_finalize(statement);
        sqlite3_close(_contactDB);
    }
}

-(NSArray *) getContactsNumberArray
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
        
    for(int i=0; i < nPeople; i++){
        ABRecordRef ref = CFArrayGetValueAtIndex( allPeople, i );
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        
        if(ABMultiValueGetCount(phoneNumbers) > 0){
            NSString *phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
            
            int len = [self.illegalChars count];
            for(int j = 0; j < len; j++){
                phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:self.illegalChars[j] withString:@""];
            }
            [[self numbersArray] addObject: phoneNumber];
            
//            NSLog([NSString stringWithFormat:@"Number: %@", phoneNumber]);
        }
    }
//    NSLog([NSString stringWithFormat:@"Numbers to send: %@", self.toSendNumbers]);
    return [self numbersArray];
}

-(NSArray *) filterContactsByPhoneNumberArray:(NSArray*) filter
{   
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef arrayOfAllPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    NSArray* people = (__bridge NSArray*) arrayOfAllPeople; 
    NSMutableArray *contacts = [NSMutableArray new];
       
    for(int i = 0; i < [people count]; i++)
    {
        PlinkContact* contact = [PlinkContact new];
        ABRecordRef person = (__bridge ABRecordRef)[people objectAtIndex:i];
        
        contact.nameLabel = [NSString stringWithFormat:@"%@ %@",
                             (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty)),
                             (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty))];      
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSString* phoneNumber = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
        int len = [self.illegalChars count];
        for(int j = 0; j < len; j++){
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:self.illegalChars[j] withString:@""];
        }
        contact.phoneNumber = phoneNumber;
        if(ABPersonHasImageData(person))
        {
            contact.image = [[UIImage alloc] initWithData:(__bridge NSData *)(ABPersonCopyImageData(person))];
        }
        
        [contacts addObject:contact];
    }

    NSPredicate* containsNumberPredicate = [NSPredicate predicateWithFormat:@"SELF IN %@", filter];
    NSPredicate* predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary* bindings)
    {
        PlinkContact *person = (PlinkContact*)record;
        return [containsNumberPredicate evaluateWithObject:person.phoneNumber];
    }];
    
    return [contacts filteredArrayUsingPredicate:predicate];
}

-(void)loadContactsFromServer:(NSString *)url
{
    if(url == NULL)
        return;
    
    NSArray* strArray = [self getContactsNumberArray];
    
    if(strArray == NULL)
        return;
    
    NSError *error;
    // convert strArray into Json Format
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:strArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //    NSLog(@"jsonData as string:\n%@", resultAsString);
    
    NSString *post = [NSString stringWithFormat:@"&numbers=%@", resultAsString];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d",[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Current-Type"];
    [request setHTTPBody:postData];
    NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    
    if(conn)
    {
        NSLog(@"Connection Successful");
        [self.loader startAnimating];
    }
    else
    {
        NSLog(@"Connection could not be made");
        NSLog([NSString stringWithFormat:@"error: %@", error]);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [[self jsonData] setLength:0];
    [self.loader stopAnimating];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.jsonData appendData:data];
    //NSLog([NSString stringWithFormat:@"Data: %@", data]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[[self jsonData]  length]);
    NSString *str;
    NSError *error;
    
    if(![[self jsonData]  length] == 0)
    {
        str = [[NSString alloc] initWithData:[self jsonData] encoding:NSUTF8StringEncoding];
        self.jsonArray = [NSJSONSerialization JSONObjectWithData:self.jsonData options:NSJSONWritingPrettyPrinted error:&error];
        self.Contacts = [self filterContactsByPhoneNumberArray:self.jsonArray];
        [self regenerateContacts];
        
    }else{
//        str = [NSString stringWithFormat:@"[\"%@\"]",@"3402247913"];
//        self.receivedArray = [NSArray arrayWithObjects:@"3402247913",nil];
    }
    
    [self propagateContacts];
}

+ (NSString *) getContactImageById: (NSString *) contactId
{
//    NSString id = contactId;
    

    NSString* fileName = [NSString stringWithFormat:@"%@.jpeg",contactId];
    NSString* imagePath = [DocumentManager filePath:fileName];
    NSFileManager *filemgr = [NSFileManager defaultManager];

    if ([filemgr fileExistsAtPath: imagePath ] == NO)
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", contactId]];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        NSData* jpeg = UIImageJPEGRepresentation(image,0);
        [jpeg writeToFile:imagePath atomically:YES];
    }
    return fileName;
}

+ (NSString *) getContactNameById: (NSString *) contactId
{
    //    NSString id = contactId;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@", contactId]];
    NSError *error;
    NSDictionary *info = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:NSJSONReadingMutableContainers error:&error];
    
//    NSLog([NSString stringWithFormat:@"%@",[info objectForKey:@"name"]]);
    
    return [info objectForKey:@"name"];
}

@end