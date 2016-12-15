//
//  WallRepostViewController.h
//  vkapp
//
//  Created by sim on 11.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "groupsHandler.h"
@interface WallRepostViewController : NSViewController{
    NSMutableArray *groupsData1;
    NSMutableArray *groupsData2;
    __weak IBOutlet NSTableView *groupsList1;
    __weak IBOutlet NSTableView *groupsList2;
    __weak IBOutlet NSButton *countGroups;
    __weak IBOutlet NSPopUpButton *groupsPopupList;
    NSMutableArray *groupsPopupData;
    NSString *groupToRespostTo;
    __weak IBOutlet NSButton *addSeletedObjects;
    NSMutableArray *selectedObjects;
    __weak IBOutlet NSButton *countGroups2;
    __weak IBOutlet NSSearchField *searchBar1;
    __weak IBOutlet NSSearchField *searchBar2;
    NSMutableArray *selectedGroups;
    NSMutableArray *groupsData1Copy;
    NSMutableArray *groupsData2Copy;
    __weak IBOutlet NSPopUpButton *repostUserGroups;
    __weak IBOutlet NSButton *removeRepostGroup;
    __weak IBOutlet NSButton *addRepostGroup;
    __weak IBOutlet NSButton *saveRepostGroup;
    NSMutableArray *itemsToSaveInSelectedRepostGroup;
    NSMutableArray *itemsToRemoveInSelectedRepostGroup;
}
@property(nonatomic)appInfo *app;
@property(nonatomic)groupsHandler *groupsHandle;
@end
