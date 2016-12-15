//
//  removePostsViewController.h
//  vkapp
//
//  Created by sim on 15.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface removePostsViewController : NSViewController{
    
    __weak IBOutlet NSPopUpButton *groupsPopupList;
    __weak IBOutlet NSTextField *count;
    __weak IBOutlet NSButton *remove;
    __weak IBOutlet NSButton *stop;
    NSMutableArray *groupsPopupData;
    NSString *groupsFromPostsRemove;
    NSInteger totalCountPosts;
     NSInteger CountPosts;
    NSInteger offset;
    NSString *url;
    
}
@property (nonatomic)appInfo *app;
@end
