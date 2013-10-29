//
//  ContactManager.h
//  Plink
//
//  Created by iskander on 9/11/13.
//  Copyright (c) 2013 iSkander Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "sqlite3.h"
#import "PlinkContact.h"

@interface ContactManager : NSObject 

@property (nonatomic, strong) UIActivityIndicatorView *loader;
@property (nonatomic, strong) NSArray *illegalChars;
@property (nonatomic, strong) NSMutableArray *numbersArray;
@property (nonatomic, strong) NSMutableData *jsonData;
@property (nonatomic, strong) NSMutableArray *jsonArray;
@property (nonatomic, strong) NSArray *Contacts;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSString *databasePath;
@property (nonatomic) sqlite3 *contactDB;

- (NSArray *) getContactsNumberArray;
- (NSArray *) filterContactsByPhoneNumberArray:(NSArray*) filter;

- (void) propagateContacts;
- (void) loadContacts;
- (void) loadContactsFromServer:(NSString*)url;
- (void) addContact:(PlinkContact*) obj;
- (void) regenerateContacts;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

+ (NSString *) getContactNameById: (NSString *) contactId;
+ (NSString *) getContactImageById: (NSString *) contactId;
@end

