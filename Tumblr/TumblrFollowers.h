//
//  TumblrFollowers.h
//  MasterAPI
//
//  Created by sim on 09.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TumblrClient.h"
@interface TumblrFollowers : NSViewController{
    
    
    __weak IBOutlet NSTableView *followersList;
    NSMutableArray *followersData;
    __weak IBOutlet NSProgressIndicator *progressLoad;
}
@property (nonatomic)TumblrClient *tumblrClient;
@end
