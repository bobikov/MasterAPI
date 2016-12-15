//
//  GroupInvitesViewController.h
//  vkapp
//
//  Created by sim on 14.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "GroupInvitesCustomCell.h"
#import "StringHighlighter.h"
@interface GroupInvitesViewController : NSViewController{
    NSMutableArray  *GroupInvitesData;
    NSMutableArray  *GroupInvitesDataFiltered;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    __weak IBOutlet NSButton *groupInvitesCountTotal;
    __weak IBOutlet NSButton *groupInvitesCountOffset;
    __weak IBOutlet NSButton *groupInvitesSearchCount;
    __weak IBOutlet NSTableView *groupInvitesList;
    __weak IBOutlet NSClipView *groupInvitesClipView;
    __weak IBOutlet NSScrollView *groupInvitesScrollView;
    __weak IBOutlet NSSearchField *groupInvitesSearchBar;
    NSInteger groupInvitesOffset;
    NSInteger offsetCounter;
    NSMutableArray *foundData;
    NSMutableArray *tempData;
    BOOL foundDataByFilter;
   
    __weak IBOutlet NSButton *filterEvent;
//    __weak IBOutlet NSButton *filterPage;
    __weak IBOutlet NSButton *filterGroup;
    BOOL filterData;
}
@property(nonatomic)appInfo *app;
@property(nonatomic)StringHighlighter *stringHighlighter;

@end
