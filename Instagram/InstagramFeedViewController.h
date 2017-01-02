//
//  InstagramFeedViewController.h
//  MasterAPI
//
//  Created by sim on 01.01.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InstagramClient.h"
@interface InstagramFeedViewController : NSViewController{
    __weak IBOutlet NSButton *totalCountTitle;
    __weak IBOutlet NSButton *loadedCountTitle;
    __weak IBOutlet NSTableView *postsList;
    __weak IBOutlet NSScrollView *postsListScroll;
    NSMutableArray *mediaURLS;
    __weak IBOutlet NSClipView *postsListClip;
    NSMutableArray *postsData;
    InstagramClient *instaClient;
    NSString *cursor;
}

@end
