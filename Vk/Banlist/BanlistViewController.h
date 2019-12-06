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
#import "SYFlatButton+ButtonsStyle.h"
#import <NSColor-HexString/NSColor+HexString.h>
@interface BanlistViewController : NSViewController{
    
    __weak IBOutlet NSTableView *banList;
    __weak IBOutlet NSClipView *banListClipView;
    __weak IBOutlet NSScrollView *banListScrollView;
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
    
    NSMutableArray
        *banlistDataCopy,
        *selectedUsers,
        *foundData,
        *banlistData;

    
    BOOL searchMode;
    
    BOOL loading;
    
    NSInteger
        totalCountBanned,
        offsetLoadBanlist;
 
}
@property (strong) IBOutlet NSArrayController *arrayController;
@property (nonatomic) NSMutableArray *value;
@property(nonatomic) appInfo *app;
@property(nonatomic) StringHighlighter *stringHighlighter;

@end
