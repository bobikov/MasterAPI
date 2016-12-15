//
//  FollowsViewController.h
//  MasterAPI
//
//  Created by sim on 04.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InstagramClient.h"
@interface FollowsViewController : NSViewController{
    
    __weak IBOutlet NSTableView *followsList;
    NSMutableArray *followListData;
    InstagramClient *instaClient;
}

@end
