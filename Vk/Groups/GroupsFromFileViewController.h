//
//  GroupsFromFileViewController.h
//  vkapp
//
//  Created by sim on 16.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "groupsHandler.h"
#import "GroupsFromFileCustomCell.h"
@interface GroupsFromFileViewController : NSViewController{
    
    __weak IBOutlet NSTableView *membershipGroupsList;
    NSMutableArray *membershipGroupsData;
    NSMutableArray *membershipGroupsDataCopy;
    __weak IBOutlet NSSearchField *searchBar;
    NSManagedObjectContext *moc;
}
@property (strong) IBOutlet NSArrayController *arrayController;
@property (nonatomic)groupsHandler *groupsHandle;
@property (nonatomic)NSDictionary *recivedData;
@end
