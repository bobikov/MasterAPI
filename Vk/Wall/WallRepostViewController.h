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

    __weak IBOutlet NSTableView *groupsList1;
    __weak IBOutlet NSTableView *groupsList2;
    __weak IBOutlet NSButton *countGroups;
    __weak IBOutlet NSPopUpButton *groupsPopupList;
    __weak IBOutlet NSButton *addSeletedObjects;
    __weak IBOutlet NSButton *countGroups2;
    __weak IBOutlet NSSearchField *searchBar1;
    __weak IBOutlet NSSearchField *searchBar2;
    __weak IBOutlet NSPopUpButton *repostUserGroups;
    __weak IBOutlet NSButton *removeRepostGroup;
    __weak IBOutlet NSButton *addRepostGroup;
    __weak IBOutlet NSButton *saveRepostGroup;
    
    NSMutableArray *groupsPopupData, *selectedGroups,  *groupsData1Copy, *groupsData2Copy, *selectedObjects, *itemsToSaveInSelectedRepostGroup, *itemsToRemoveInSelectedRepostGroup, *groupsData2, *groupsData1;
    NSString *groupToRespostTo;

}
@property(nonatomic)appInfo *app;
@property(nonatomic)groupsHandler *groupsHandle;
@end
