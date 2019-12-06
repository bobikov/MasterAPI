//
//  FavoritesGroupsController.h
//  vkapp
//
//  Created by sim on 24.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface FavoritesGroupsController : NSViewController{
    __weak IBOutlet NSButton *sendMessage;
    __weak IBOutlet NSButton *deleteFromFaves;
  
    __weak IBOutlet NSTableView *favesGroupsList;
    NSMutableArray *favesGroupsData;
    NSMutableArray *favesGroupsDataCopy;
     NSMutableArray *favesGroupsDataCopySearch;
    __weak IBOutlet NSSearchField *searchBar;
    __weak IBOutlet NSButton *filterDeactivated;
    __weak IBOutlet NSButton *countLoaded;
    __weak IBOutlet NSButton *addToGroups;
    __weak IBOutlet NSButton *filterActive;
    __weak IBOutlet NSButton *searchCount;
    __weak IBOutlet NSProgressIndicator *progressSpin;
  
    NSDictionary *receiverDataForMessage;
    NSMutableArray *favesGroupsTemp;
    NSMutableArray *selectedGroups;
    __weak IBOutlet NSClipView *favesGroupsClipView;
    __weak IBOutlet NSScrollView *favesGroupsScrollView;
    NSInteger offsetLoadFaveGroups;
    NSInteger offsetCounter;
    NSString *extURL;
    NSMutableArray *favesGroupsDataTemp;
    NSMutableArray *groupDataById;
    BOOL loading;
    BOOL loadFromUserGroup;
    __weak IBOutlet NSPopUpButton *favesUserGroups;
    __weak IBOutlet NSPopUpButton *userFavesGroupsPrefs;
    NSManagedObjectContext *moc;
    NSString *userFavesNewGroupName;
    NSMutableArray *restoredUserIDs;
    __weak IBOutlet NSButton *loadedCount;
    __weak IBOutlet NSButton *totalCount;
    NSString *groupName;
    NSString *deactivated;
    //                        NSString *groupId;
    NSString *desc;
    NSString *photo;
    NSString *url;
    NSString *linkId;
    NSString *groupId;
    //                        NSString *screenName;
    //                        NSString *status;
    //                        NSString *site;
    //                        NSString *city;
    //                        NSString *country
}
@property(nonatomic, readwrite)appInfo *app;
@end
