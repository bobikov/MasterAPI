//
//  SidebarOutlineViewController.h
//  vkapp
//
//  Created by sim on 21.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "Menulist.h"
#import "keyHandler.h"
#import "TwitterRWData.h"
#import "YoutubeRWData.h"
#import "TumblrRWData.h"
@interface SidebarOutlineViewController : NSViewController{
    NSMutableArray *menuItems;
    __weak IBOutlet NSOutlineView *OutlineSidebar;

    NSString *currentSelectorName;
    NSArray *_topLevelItems;
    NSViewController *_currentContentViewController;
    NSMutableDictionary *_childrenDictionary;
    BOOL loaded;
}
//@property (copy)NSMutableArray *menuItems;

@property(nonatomic)keyHandler *VKKeyHandler;
@property(nonatomic)TwitterRWData *twitterRWD;
@property(nonatomic)YoutubeRWData *youtubeRWD;
@property(nonatomic)TumblrRWData *tumblrRWD;
@end
