//
//  YoutubeVideosAddToSocialsController.h
//  MasterAPI
//
//  Created by sim on 15.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface YoutubeVideosAddToSocialsController : NSViewController{
    NSMutableArray *videosListData;
    NSMutableArray *albumsListData;
    __weak IBOutlet NSButton *addToAlbumButton;
    __weak IBOutlet NSTableView *selectedVideosList;
    __weak IBOutlet NSTableView *selectedAlbumsList;
    
    NSString *targetAlbumOwner;
}
@property(nonatomic, readwrite)NSArray *receivedData;



@property(nonatomic, readwrite)appInfo *app;
@end
