//
//  ShowMediaPosts.h
//  MasterAPI
//
//  Created by sim on 14.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InstagramClient.h"
@interface ShowMediaPosts : NSViewController{
    
    __weak IBOutlet NSButton *totalCountTitle;
    __weak IBOutlet NSButton *loadedCountTitle;
    __weak IBOutlet NSSearchField *searchField;
    __weak IBOutlet NSTableView *mediaPostsList;
    __weak IBOutlet NSScrollView *mediaPostsScroll;
    __weak IBOutlet NSClipView *mediaPostsClip;
    NSMutableArray *postsData;
    InstagramClient *instaClient;
    NSString *postID;
    NSMutableArray *mediaURLS;
    NSMenu *cellMenu ;
    NSString *startCursor;
    NSMutableArray *sliderData;
    
}
@property(retain,strong)NSWindowController *sliderWindowContr;
@end
