//
//  SubscribersViewController.h
//  vkapp
//
//  Created by sim on 29.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "SubscribersCustomCell.h"
#import "FriendsMessageSendViewController.h"
#import "StringHighlighter.h"
@interface SubscribersViewController : NSViewController{
    
    __weak IBOutlet NSClipView *subscribersClipView;
    __weak IBOutlet NSScrollView *subscribersScrollView;
    __weak IBOutlet NSButton *selectAll;
    NSMutableArray *subscribersData;
    __weak IBOutlet NSSearchField *searchBar;
    __weak IBOutlet NSTableView *subscribersList;
    __weak IBOutlet NSButton *subscribersCountInline;
    __weak IBOutlet NSButton *subscribersFilterOffline;
    __weak IBOutlet NSButton *subscribersFilterOnline;
    __weak IBOutlet NSButton *subscribersFilterActive;
    __weak IBOutlet NSButton *womenFilter;
    __weak IBOutlet NSButton *menFilter;
    __weak IBOutlet NSButton *goUp;
    __weak IBOutlet NSButton *goDown;
    int offsetLoadSubscribers;
    NSInteger offsetCounter;
    NSMutableArray *selectedUsers;
    __weak IBOutlet NSPopUpButton *friendsListPopup;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    NSMutableArray *foundData;
    NSMutableArray *subscribersDataCopy;
    __weak IBOutlet NSButton *subscribersTotalCount;
   
}
@property (nonatomic) appInfo *app;
@property (strong) IBOutlet NSArrayController *arrayController;
@property (nonatomic) NSMutableArray *value;
@property (nonatomic) StringHighlighter *stringHighlighter;
@end
