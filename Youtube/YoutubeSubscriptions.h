//
//  YoutubeSubscriptions.h
//  MasterAPI
//
//  Created by sim on 12.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YoutubeClient.h"
@interface YoutubeSubscriptions : NSViewController{
    
    __weak IBOutlet NSTableView *subscriptionsList;
    __weak IBOutlet NSProgressIndicator *progressLoad;
    NSMutableArray *subscriptionsData;
    __weak IBOutlet NSScrollView *subscriptionsScroll;
    __weak IBOutlet NSClipView *subscriptionsClip;
    NSString *pageToken;
    __weak IBOutlet NSButton *totalCount;
    __weak IBOutlet NSButton *loadedCount;
    int offsetCounter;
    
}
@property(nonatomic)YoutubeClient *youtubeClient;
@property(nonatomic)YoutubeRWData *youtubeRWData;
@end
