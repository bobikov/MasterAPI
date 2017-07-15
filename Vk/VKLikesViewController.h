//
//  VKLikesViewController.h
//  MasterAPI
//
//  Created by sim on 14/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "ViewController.h"
#import "appInfo.h"
@interface VKLikesViewController : ViewController{
    
    __weak IBOutlet NSButton *dismiss;
    __weak IBOutlet NSTableView *likedUsersList;
    
    NSMutableArray
        *usersListData,
        *usersIDs;
    


    appInfo *app;
    __weak IBOutlet NSProgressIndicator *progress;
}

@property(nonatomic)NSDictionary *receivedData;
@end
