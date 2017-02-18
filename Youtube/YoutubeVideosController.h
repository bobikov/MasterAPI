//
//  YoutubeVideosController.h
//  MasterAPI
//
//  Created by sim on 14.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YoutubeClient.h"
#import "YoutubeRWData.h"
#import "appInfo.h"
@interface YoutubeVideosController : NSViewController{
    
    __weak IBOutlet NSButton *AddToPlaylistsButton;
    __weak IBOutlet NSTableView *loadedItemsList;

    __weak IBOutlet NSScrollView *loadedItemsListScroll;
    __weak IBOutlet NSScrollView *subscriptionsListScroll;
    __weak IBOutlet NSClipView *subscriptionsListClip;
    __weak IBOutlet NSButton *addToSocialsButton;
    __weak IBOutlet NSTableView *subscriptionsList;
    __weak IBOutlet NSClipView *loadedItemsListClip;
    NSMutableArray *subscriptionsData;
    NSMutableArray *loadedItemsData;
    NSMutableArray *subscriptionsDataCopy;
    NSString *subsPageToken;
    NSString *itemsPageToken;
    NSString *videoVkURL;
    NSDictionary *videoVkData;
    NSDictionary *dataForPlayer;
    NSString *playlistID;
    BOOL playlistLoaded;
    int subsOffsetCounter;
    __weak IBOutlet NSScrollView *subscriptionsScroll;
    __weak IBOutlet NSClipView *subscriptionsClip;
    __weak IBOutlet NSSearchField *searchSubscriptionsBar;
    NSInteger lastAction;
    NSString *pageToken;
    NSString *channel;
    NSDictionary *queryParams;
    __weak IBOutlet NSSegmentedControl *VideosSearchSourceSelector;
    __weak IBOutlet NSSearchField *videosSearchBar;
    __weak IBOutlet NSSegmentedControl *subscriptionsSearchSelector;
    BOOL loadSubscriptions;
    
}
@property(nonatomic)YoutubeClient *youtubeClient;
@property(nonatomic)YoutubeRWData *youtubeRWData;
@property(nonatomic)appInfo *app;
@end
