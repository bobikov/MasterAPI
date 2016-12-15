//
//  AudioPlaylist.h
//  vkapp
//
//  Created by sim on 05.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "CustomAudioPlayerCell.h"

@interface AudioPlaylist : NSViewController{
    NSMutableArray *playListData;
    NSMutableArray *playListDataCopy;
    __weak IBOutlet NSTableView *playList;
   
  
    __weak IBOutlet NSScrollView *audioScrollView;
    __weak IBOutlet NSScroller *vScroller;
     int offsetLoadPlylist;
    NSArray *_topLevelItems;
    NSMutableArray *myAlbumsData;
    NSMutableDictionary *_childrenDictionary;
    __weak IBOutlet NSOutlineView *outlineAudioPlayer;
    BOOL searchActive;
    __weak IBOutlet NSSearchField *searchAudioBar;
    int offsetStep;
    BOOL albumLoaded;
    __weak IBOutlet NSClipView *playlistClip;
}
@property(nonatomic)appInfo *app;
@end
