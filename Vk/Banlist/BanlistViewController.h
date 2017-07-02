//
//  BanlistViewController.h
//  vkapp
//
//  Created by sim on 01.06.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "BanlistCustomCell.h"
#import "StringHighlighter.h"
@interface BanlistViewController : NSViewController{
    
    __weak IBOutlet NSTableView *banList;
    NSMutableArray *banlistData;
    NSMutableArray *foundData;
    __weak IBOutlet NSClipView *banListClipView;
    __weak IBOutlet NSScrollView *banListScrollView;
    NSInteger offsetLoadBanlist;
    NSInteger offsetCounter;

    __weak IBOutlet NSPopUpButton *dateFilterOptionsPopup;
    __weak IBOutlet NSButton *countBanned;
    
   
    __weak IBOutlet NSButton *banlistStatBut;
    __weak IBOutlet NSButton *totalCount;
    __weak IBOutlet NSButton *loadedCount;
    __weak IBOutlet NSSearchField *searchBar;
    __weak IBOutlet NSButton *filterWomen;
    __weak IBOutlet NSButton *filterMen;
    __weak IBOutlet NSButton *filterOffline;
    __weak IBOutlet NSButton *filterOnline;
    __weak IBOutlet NSButton *filterActive;
    __weak IBOutlet NSButton *filterInUserBlacklist;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    NSMutableArray *banlistDataCopy ;
    NSMutableArray *selectedUsers;
    BOOL searchMode;
    BOOL loading;
    NSInteger totalCountBanned;
    NSMutableDictionary *cachedImage;
    NSMutableDictionary *cachedStatus;
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
    // NSString *phone;
    NSString *photoBig;
    NSString *photo;
    NSString *about;
    NSString *music;
    NSString *schools;
    NSString *education;
    NSString *quotes;
    NSString *deactivated;
    NSString *relation;
    NSString *domain;
   
}
@property (strong) IBOutlet NSArrayController *arrayController;
@property (nonatomic)NSMutableArray *value;
@property(nonatomic)appInfo *app;
@property(nonatomic)StringHighlighter *stringHighlighter;
@end
