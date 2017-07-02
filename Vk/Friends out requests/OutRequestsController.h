//
//  OutRequestsController.h
//  vkapp
//
//  Created by sim on 29.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "OutRequestsCustomCell.h"
#import "StringHighlighter.h"
@interface OutRequestsController : NSViewController{
    NSMutableArray *outRequestsData;
    NSInteger offsetRequests;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    __weak IBOutlet NSButton *sendMessage;
    __weak IBOutlet NSButton *addToFriends;
    __weak IBOutlet NSButton *addToBan;
    __weak IBOutlet NSButton *unsubscribe;
    __weak IBOutlet NSTableView *outRequestsList;
    __weak IBOutlet NSClipView *outRequestsClipView;
    __weak IBOutlet NSScrollView *outRequestsScrollView;
    NSMutableArray *selectedUsers;
    __weak IBOutlet NSButton *loadedCount;
    __weak IBOutlet NSButton *totalCount;
    __weak IBOutlet NSButton *filterActive;
    __weak IBOutlet NSButton *filterOnline;
    __weak IBOutlet NSButton *filterOffline;
    __weak IBOutlet NSButton *filterMen;
    __weak IBOutlet NSButton *filterWomen;
    NSMutableDictionary *cachedImage;
    NSMutableDictionary *cachedStatus;
    int counter;
    BOOL loading;
    NSString *city;
    NSString *status;
    NSString *bdate;
    NSString *online;
    NSString *firstName;
    NSString *lastName;
    NSString *fullName;
    NSString *countryName;
    NSString *last_seen;
    NSString *sex;
    NSString *books;
    NSString *site;
    NSString *mobilePhone;
    //NSString *phone;
    NSString *photoBig;
    NSString *photo;
    NSString *about;
    NSString *verified;
    NSString *music;
    NSString *schools;
    NSString *education;
    NSString *quotes;
    NSString *relation;
    NSString *domain;
    NSString *templateLateTime2;
    NSString *templateLateTime1;
    NSDateFormatter *formatter;
}


@property (nonatomic) appInfo *app;
@property (nonatomic) StringHighlighter *stringHighlighter;
@end
