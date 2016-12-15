//
//  YoutubeAddToPlaylistController.h
//  MasterAPI
//
//  Created by sim on 07.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YoutubeClient.h"
#import "YoutubeRWData.h"
@interface YoutubeAddToPlaylistController : NSViewController{
    
    NSMutableArray *videosListData;
    NSMutableArray *playlistsData;
    __weak IBOutlet NSTableView *videosList;
    __weak IBOutlet NSTableView *playlistsList;
    
}
@property(nonatomic)YoutubeClient *youtubeClient;
@property(nonatomic)YoutubeRWData *youtubeRWData;
@property(nonatomic, readwrite)NSArray *receivedData;

@end
