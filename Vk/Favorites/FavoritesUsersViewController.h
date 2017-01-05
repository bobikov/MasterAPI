//
//  FavoritesUsersViewController.h
//  vkapp
//
//  Created by sim on 24.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "StringHighlighter.h"
@interface FavoritesUsersViewController : NSViewController{
    
    __weak IBOutlet NSButton *sendMessage;
    __weak IBOutlet NSButton *deleteFromFaves;
    __weak IBOutlet NSButton *addToBun;
    __weak IBOutlet NSTableView *favesUsersList;
    NSMutableArray *favesUsersData;
    NSMutableArray *favesUsersDataCopy;
    __weak IBOutlet NSSearchField *searchBar;
    __weak IBOutlet NSButton *filterActive;
    __weak IBOutlet NSButton *filterOnline;
    __weak IBOutlet NSButton *filterOffline;
    __weak IBOutlet NSButton *filterWomen;
    __weak IBOutlet NSButton *filterMen;
    __weak IBOutlet NSButton *searchCount;
    NSMutableArray *selectedUsers;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    NSDictionary *receiverDataForMessage;
    NSMutableArray *favesUsersTemp;
    __weak IBOutlet NSClipView *favesClipView;
    __weak IBOutlet NSScrollView *favesScrollView;
    NSInteger offsetLoadFaveUsers;
    NSInteger offsetCounter;
    __weak IBOutlet NSButton *showFavesUsersStatBut;
    StringHighlighter *stringHighlighter;
}
@property(nonatomic, readwrite)appInfo *app;
@end
