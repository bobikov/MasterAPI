//
//  TwitterFriends.h
//  MasterAPI
//
//  Created by sim on 11.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TwitterClient.h"
@interface TwitterFriends : NSViewController{
    
    __weak IBOutlet NSProgressIndicator *progressLoad;
    __weak IBOutlet NSTableView *friendsList;
    NSMutableArray *friendsListData;
    NSMutableArray *friendsListDataCopy;
    __weak IBOutlet NSButton *loadedCount;
    __weak IBOutlet NSButton *totalCount;
    int offsetCounter;
    __weak IBOutlet NSSearchField *searchBar;
    
}
@property(nonatomic)TwitterClient *twitterClient;
@end
