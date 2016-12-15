//
//  TumblrPosts.h
//  MasterAPI
//
//  Created by sim on 09.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TumblrClient.h"
@interface TumblrPosts : NSViewController{
    
    __weak IBOutlet NSTextField *ownerField;
    __weak IBOutlet NSTextField *countField;
    NSFileManager *manager;
    dispatch_semaphore_t semaphore;
    __weak IBOutlet NSProgressIndicator *progressDownloadBar;
    NSMutableArray *postsData;
    NSMutableArray *postsDataCopy;
    __weak IBOutlet NSScrollView *postsListScroll;
    __weak IBOutlet NSClipView *postsListClip;
    __weak IBOutlet NSTableView *PostsList;
    int offsetLoadPosts;
    NSString *ownerBlog;
    NSMutableArray *altSizeImages;
    BOOL searchByTagMode;
    int indexCurrentPhoto;
    __weak IBOutlet NSSearchField *searchByTagBar;
    NSString *selectedDirectoryPath;
    NSString *fileName;
}
@property(nonatomic)TumblrClient *tumblrClient;
@property(strong) NSWindowController *myWindowContr;
@property (nonatomic, strong)NSURLSession *backgroundSession;
@end
