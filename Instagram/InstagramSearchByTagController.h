//
//  InstagramSearchByTagController.h
//  MasterAPI
//
//  Created by sim on 16.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InstagramClient.h"
@interface InstagramSearchByTagController : NSViewController{
    __weak IBOutlet NSButton *totalCountTitle;
    __weak IBOutlet NSButton *loadedCountTitle;
    __weak IBOutlet NSSearchField *searchField;
    __weak IBOutlet NSScrollView *postsListScroll;
    __weak IBOutlet NSClipView *postsListClip;
     InstagramClient *instaClient;
    __weak IBOutlet NSTableView *postsList;
    NSMutableArray *postsData;
    NSString *endCursor;
     NSMutableArray *mediaURLS;
      NSMenu *cellMenu ;
}

@end
