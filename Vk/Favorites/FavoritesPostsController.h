//
//  FavoritesPostsController.h
//  MasterAPI
//
//  Created by sim on 23/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"

@interface FavoritesPostsController : NSViewController{
    NSMutableArray *postsData;
    
    __weak IBOutlet NSTableView *postsList;
    
    
}
@property appInfo *app;
@end
