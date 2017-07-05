//
//  GroupsViewController.h
//  vkapp
//
//  Created by sim on 14.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "GroupsCustomCellView.h"
#import "groupsHandler.h"
@interface GroupsViewController : NSViewController{
    NSMutableArray *groupsData;
    
    __weak IBOutlet NSButton *outOfGroup;
    __weak IBOutlet NSSearchField *searchGroupBar;
    __weak IBOutlet NSTableView *groupsList;
    __weak IBOutlet NSButton *sendMessageToGroup;
    __weak IBOutlet NSButton *totalCountGroups;
    __weak IBOutlet NSButton *loadedCountGroups;
    __weak IBOutlet NSScrollView *groupsListScrollView;
    __weak IBOutlet NSClipView *groupsListClipView;
    NSMutableArray *foundData;
    NSInteger offsetLoadGroups;
    NSInteger offsetCounter;
    NSMutableArray *tempData;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    __weak IBOutlet NSButton *searchCountResults;
    NSIndexSet *rows;
    __weak IBOutlet NSButton *filterActive;
    __weak IBOutlet NSButton *filterDeactivated;
    NSMutableArray *groupsDataCopy;
    __weak IBOutlet NSSearchField *searchBar;
    BOOL reloaded;
    NSManagedObjectContext *moc;
}
@property (nonatomic) appInfo *app;
@property (strong) IBOutlet NSArrayController *arrayController;
@property(nonatomic)NSMutableArray *value;
@property(nonatomic)groupsHandler *groupsHandle;
@end
