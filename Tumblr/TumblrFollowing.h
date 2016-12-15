//
//  TumblrFollowing.h
//  MasterAPI
//
//  Created by sim on 09.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TumblrClient.h"
@interface TumblrFollowing : NSViewController{
    
    __weak IBOutlet NSTableView *followingList;
    NSMutableArray *followingData;
    __weak IBOutlet NSProgressIndicator *progressLoad;
    __weak IBOutlet NSButton *loadedCount;
    __weak IBOutlet NSButton *totalCount;
    int offsetCounter;
    __weak IBOutlet NSScrollView *followingListScroll;
    __weak IBOutlet NSClipView *followingListClip;
    int followingOffset;
}
@property(nonatomic)TumblrClient *tumblrClient;
@end
