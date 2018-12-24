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
#import <SBJson/SBJson5.h>
#import <SYFlatButton/SYFlatButton.h>
#import "CDataHandler.h"
@interface FavoritesUsersViewController : NSViewController{
    
    __weak IBOutlet NSButton *sendMessage;
    __weak IBOutlet NSButton *deleteFromFaves;
    __weak IBOutlet NSButton *addToBun;
    __weak IBOutlet NSTableView *favesUsersList;
    __weak IBOutlet NSSearchField *searchBar;
    __weak IBOutlet NSButton *filterActive;
    __weak IBOutlet NSButton *filterOnline;
    __weak IBOutlet NSButton *filterOffline;
    __weak IBOutlet NSButton *filterWomen;
    __weak IBOutlet NSButton *filterMen;
    __weak IBOutlet NSButton *searchCount;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    __weak IBOutlet NSClipView *favesClipView;
    __weak IBOutlet NSScrollView *favesScrollView;
    __weak IBOutlet NSButton *showFavesUsersStatBut;
    __weak IBOutlet NSPopUpButton *favesUserGroups;
    __weak IBOutlet NSPopUpButton *userFavesGroupsPrefs;
    __weak IBOutlet NSButton *loadedCount;
    __weak IBOutlet NSButton *totalCountLabel;
    CDataHandler *CDHandle;
    StringHighlighter *stringHighlighter;
    NSInteger offsetLoadFaveUsers,offsetCounter,totalCount;
    NSDictionary *receiverDataForMessage;
    NSMutableArray *favesUsersData,*favesUsersDataCopy,*favesUsersTemp,*selectedUsers,*restoredUserIDs;
    NSManagedObjectContext *moc;
    NSString *userFavesNewGroupName;
    
   
    BOOL loading,loadFromUserGroup;
   
}

@property(nonatomic, readwrite)appInfo *app;
@end
