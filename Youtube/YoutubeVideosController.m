    //
//  YoutubeVideosController.m
//  MasterAPI
//
//  Created by sim on 14.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "YoutubeVideosController.h"
#import "YoutubeVideosCustomCell.h"
#import "YoutubeSubscriptionsCustomCell.h"
#import "YoutubeVideoPlayerController.h"
#import "YoutubeVideosAddToSocialsController.h"
#import "YoutubeAddToPlaylistController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface YoutubeVideosController ()<NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate>

@end

@implementation YoutubeVideosController

- (void)viewDidLoad {
    [super viewDidLoad];
    subscriptionsList.delegate=self;
    loadedItemsList.delegate=self;
    searchSubscriptionsBar.delegate=self;
    subscriptionsList.dataSource=self;
    loadedItemsList.dataSource=self;
    loadedItemsData = [[NSMutableArray alloc]init];
    subscriptionsData = [[NSMutableArray alloc]init];
    _youtubeClient = [[YoutubeClient alloc]initWithTokensFromCoreData];
    _youtubeRWData = [[YoutubeRWData alloc]init];
    videosSearchBar.delegate=self;
    [[subscriptionsScroll contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
//     [self loadSubscriptions:NO];
    [self loadSubscriptionsFromData];
    
}
- (void)viewDidAppear{
   
}
- (void)viewDidScroll:(NSNotification *)notification{
    if([notification.object isEqual:loadedItemsListClip]){
        NSInteger scrollOrigin = [[loadedItemsListScroll contentView]bounds].origin.y+NSMaxY([loadedItemsListScroll visibleRect]);
        //    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
        NSInteger boundsHeight = loadedItemsList.bounds.size.height;
        //    NSInteger frameHeight = subscribersList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            //Refresh here
            //         NSLog(@"The end of table");
            if(pageToken!=nil){
                if(lastAction==0){
                    [self loadVideos:YES];
                }
                else if(lastAction==1){
                    [self loadLiveBroadcasts:@{@"part":@"snippet", @"eventType":@"live", @"type":@"video", @"maxResults":@50} offset:YES];
                }
                else if(lastAction==3){
                    [self globalVideosSearch:YES string:[videosSearchBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
                }
                else if(lastAction==2){
                    [self loadLikedVideos:YES];
                }
            }
        }
        //        NSLog(@"%ld", scrollOrigin);
        //        NSLog(@"%ld", boundsHeight);
        //    NSLog(@"%fld", frameHeight-300);
        //
    }else if([notification.object isEqual:subscriptionsClip]){
        NSInteger scrollOrigin = [[subscriptionsScroll contentView]bounds].origin.y+NSMaxY([subscriptionsScroll visibleRect]);
        //    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
        NSInteger boundsHeight = subscriptionsList.bounds.size.height;
        //    NSInteger frameHeight = subscribersList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            if(loadSubscriptions){
                [self loadSubscriptions:YES];
            }
        }
    }
    
}

- (IBAction)likedButtonAction:(id)sender {
    
    [self loadLikedVideos:NO];

}
- (void)loadLikedVideos:(BOOL)offset{
    lastAction = 2;

    if(playlistID){
        if((pageToken && offset) || (pageToken && !offset) || (!pageToken && !offset) ) {
            if(offset){
                queryParams = @{@"playlistId":playlistID, @"part":@"snippet", @"maxResults":@50, @"pageToken":pageToken};
            }else{
                [loadedItemsData removeAllObjects];
                queryParams = @{@"playlistId":playlistID, @"part":@"snippet", @"maxResults":@50};
            }
            [_youtubeClient APIRequest:@"playlistItems" query:queryParams handler:^(NSData *data) {
                NSDictionary *getVideosResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                pageToken = getVideosResp[@"nextPageToken"] && getVideosResp[@"nextPageToken"] !=nil? getVideosResp[@"nextPageToken"] : nil ;
                for(NSDictionary *i in getVideosResp[@"items"]){
                    NSString *thumb = i[@"snippet"][@"thumbnails"][@"default"][@"url"]!=nil ? i[@"snippet"][@"thumbnails"][@"default"][@"url"] : @"";
                    [loadedItemsData addObject:@{@"title":i[@"snippet"][@"title"], @"publishedAt":[NSString stringWithFormat:@"%@", i[@"snippet"][@"publishedAt"]], @"thumb":thumb, @"video_id":i[@"snippet"][@"resourceId"][@"videoId"]}];
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [loadedItemsList reloadData];
                });
            }];
        }

    }else{
        [loadedItemsData removeAllObjects];
        [_youtubeClient APIRequest:@"channels" query:@{@"part":@"snippet,contentDetails", @"mine":@"true", @"maxResults":@50} handler:^(NSData *data) {
            if(data){
                NSDictionary *channelsResp  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", channelsResp);
                playlistID = channelsResp[@"items"][0][@"contentDetails"][@"relatedPlaylists"][@"likes"];
                [_youtubeClient APIRequest:@"playlistItems" query:@{@"playlistId":playlistID, @"part":@"snippet", @"maxResults":@50} handler:^(NSData *data) {
                    NSDictionary *getVideosResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    pageToken = getVideosResp[@"nextPageToken"] && getVideosResp[@"nextPageToken"] !=nil? getVideosResp[@"nextPageToken"] : nil ;
                    for(NSDictionary *i in getVideosResp[@"items"]){
                        NSString *thumb = i[@"snippet"][@"thumbnails"][@"default"][@"url"]!=nil ? i[@"snippet"][@"thumbnails"][@"default"][@"url"] : @"";
                        [loadedItemsData addObject:@{@"title":i[@"snippet"][@"title"], @"publishedAt":[NSString stringWithFormat:@"%@", i[@"snippet"][@"publishedAt"]], @"thumb":thumb, @"video_id":i[@"snippet"][@"resourceId"][@"videoId"]}];
                        
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [loadedItemsList reloadData];
                    });
                }];
            }
        }];
    }
}
- (void)channels{
    [_youtubeClient APIRequest:@"channels" query:@{@"part":@"snippet,contentDetails", @"mine":@"true", @"maxResults":@50} handler:^(NSData *data) {
        if(data){
            NSDictionary *channelsResp  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", channelsResp);
        }
        
    }];
}
- (IBAction)loadMinePlaylists:(id)sender {
    [loadedItemsData removeAllObjects];
    playlistLoaded=YES;
    [_youtubeClient APIRequest:@"playlists" query:@{@"part":@"snippet", @"mine":@"true", @"maxResults":@50} handler:^(NSData *data) {
        NSDictionary *playlistsMineResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *i in playlistsMineResp[@"items"]){
            [loadedItemsData addObject:@{@"title":i[@"snippet"][@"title"], @"thumb":i[@"snippet"][@"thumbnails"][@"default"][@"url"], @"publishedAt":[NSString stringWithFormat:@"%@", i[@"snippet"][@"publishedAt"]], @"playlist_id":i[@"id"]}];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadedItemsList reloadData];
        });
    }];
}

- (IBAction)showPlaylistsByChannel:(id)sender {
    playlistLoaded=YES;
    [loadedItemsData removeAllObjects];
    NSView *parentCell = [sender superview];
    NSInteger row = [subscriptionsList rowForView:parentCell];
//    NSLog(@"%@", subscriptionsData[row][@"id"]);
    channel =subscriptionsData[row][@"id"];
    [_youtubeClient APIRequest:@"playlists" query:@{@"part":@"snippet", @"channelId":channel} handler:^(NSData *data) {
        if(data){
            NSDictionary *playResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", playResp);
                    for(NSDictionary *i in playResp[@"items"]){
                        [loadedItemsData addObject:@{@"title":i[@"snippet"][@"title"], @"publishedAt":[NSString stringWithFormat:@"%@", i[@"snippet"][@"publishedAt"]], @"thumb":i[@"snippet"][@"thumbnails"][@"default"][@"url"], @"playlist_id":i[@"id"]}];
                    }
            dispatch_async(dispatch_get_main_queue(), ^{
                            [loadedItemsList reloadData];
            });
        }
    }];
    
}
- (IBAction)showLivesOfChannel:(id)sender {
    playlistLoaded=NO;
    [loadedItemsData removeAllObjects];
    NSView *parentCell = [sender superview];
    NSInteger row = [subscriptionsList rowForView:parentCell];
    //    NSLog(@"%@", subscriptionsData[row][@"id"]);
    channel =subscriptionsData[row][@"id"];
    lastAction=2;
    [self loadLiveBroadcasts:@{@"part":@"snippet", @"eventType":@"live", @"type":@"video", @"maxResults":@50,  @"channelId":channel} offset:NO];
   
}
- (IBAction)showLiveBroadcasts:(id)sender {
    playlistLoaded=NO;
     lastAction = 1;
    [self loadLiveBroadcasts:@{@"part":@"snippet", @"eventType":@"live", @"type":@"video", @"maxResults":@50} offset:NO];
   
}
- (void)loadLiveBroadcasts:(NSDictionary*)query offset:(BOOL)offset{
    
    if(offset){
        queryParams = lastAction==1 ? @{@"part":@"snippet", @"eventType":@"live", @"type":@"video", @"maxResults":@50, @"pageToken":pageToken} : @{@"part":@"snippet", @"eventType":@"live", @"type":@"video", @"maxResults":@50, @"channelId":channel, @"pageToken":pageToken};
        
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            if([loadedItemsData count]>0){
                [loadedItemsList removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [loadedItemsData count])] withAnimation:NSTableViewAnimationEffectNone];
            }
        });
        queryParams = lastAction==1 ? @{@"part":@"snippet", @"eventType":@"live", @"type":@"video", @"maxResults":@50}
      : @{@"part":@"snippet", @"eventType":@"live", @"type":@"video", @"maxResults":@50,  @"channelId":channel};
        //        offsetCounter=0;
        [loadedItemsData removeAllObjects];
    }
    [_youtubeClient APIRequest:@"search" query:queryParams handler:^(NSData *data) {
        NSDictionary *lbrdsResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(lbrdsResp[@"error"] && [lbrdsResp[@"error"][@"code"]intValue]==401){
            [_youtubeClient refreshToken:^(NSData *data) {
                NSDictionary *refreshTokenResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                //                    NSLog(@"%@", refreshTokenResponse);
                
                [_youtubeRWData updateYoutubeToken:refreshTokenResponse];
                _youtubeClient = [[YoutubeClient alloc] initWithTokensFromCoreData];
            }];
        }else{
//                        NSLog(@"%@", lbrdsResp);
          
             pageToken = lbrdsResp[@"nextPageToken"] && lbrdsResp[@"nextPageToken"] !=nil? lbrdsResp[@"nextPageToken"] : nil ;
            for(NSDictionary *i in lbrdsResp[@"items"]){
                 NSString *onAir =  i[@"snippet"][@"liveBroadcastContent"] && ![i[@"snippet"][@"liveBroadcastContent"] isEqual:@"none"] ? i[@"snippet"][@"liveBroadcastContent"] : @"";
                NSString *desc = i[@"snippet"][@"description"] &&  i[@"snippet"][@"description"]!=nil ? i[@"snippet"][@"description"] : @"";
//                NSLog(@"%@",  onAir);
                
                [loadedItemsData addObject:@{@"title":i[@"snippet"][@"title"], @"publishedAt":[NSString stringWithFormat:@"%@", i[@"snippet"][@"publishedAt"]], @"thumb":i[@"snippet"][@"thumbnails"][@"default"][@"url"], @"video_id":i[@"id"][@"videoId"], @"live":onAir, @"desc":desc}];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadedItemsList reloadData];
            });
            
        }
        
    }];
//

}
- (void)searchFieldDidStartSearching:(NSSearchField *)sender{
    if(sender == searchSubscriptionsBar){
       
        switch (subscriptionsSearchSelector.selectedSegment) {
            case 0:
                 [self loadSearchSubscriptionsList];
                break;
            case 1:
                [self subscriptionsGlobalSearch];
                break;
            default:
                break;
        }
    }else{
        switch (VideosSearchSourceSelector.selectedSegment) {
            case 0:
                [self globalVideosSearch:NO string:[videosSearchBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
                break;
            case 1:
                
                break;
            case 2:
                
                break;
            default:
                break;
        }
    }
}
- (void)searchFieldDidEndSearching:(NSSearchField *)sender{
    if(sender == searchSubscriptionsBar){
        subscriptionsData = subscriptionsDataCopy;
        [subscriptionsList reloadData];
    }
}
- (void)globalVideosSearch:(BOOL)offset string:(id)string{
    lastAction=3;
    if(offset){
        queryParams = @{@"part":@"snippet",  @"type":@"video", @"q":string, @"maxResults":@50, @"pageToken":pageToken};
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            if([loadedItemsData count]>0){
                [loadedItemsList removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [loadedItemsData count])] withAnimation:NSTableViewAnimationEffectNone];
            }
        });
        queryParams = @{@"part":@"snippet",  @"type":@"video", @"q":string, @"maxResults":@50};
        [loadedItemsData removeAllObjects];
    }
    [_youtubeClient APIRequest:@"search" query:queryParams handler:^(NSData *data) {
        if (data){
            NSDictionary *globalSearchResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            NSLog(@"%@", globalSearchResp);
            if(globalSearchResp[@"error"]){
                if ([globalSearchResp[@"error"][@"code"]intValue]==401){
                    [_youtubeClient refreshToken:^(NSData *data){
                        NSDictionary *refreshTokenResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        //                    NSLog(@"%@", refreshTokenResponse);
                        
                        [_youtubeRWData updateYoutubeToken:refreshTokenResponse];
                        _youtubeClient = [[YoutubeClient alloc] initWithTokensFromCoreData];
                        
                    }];
                }else{
                    NSLog(@"%@", globalSearchResp[@"error"]);
                }
            }
            else{
                if((pageToken && offset) || (pageToken && !offset) || (!pageToken && !offset) ) {
                    pageToken = globalSearchResp[@"nextPageToken"] && globalSearchResp[@"nextPageToken"] !=nil? globalSearchResp[@"nextPageToken"] : nil ;
                    for(NSDictionary *i in globalSearchResp[@"items"]){
                        NSString *onAir =  i[@"snippet"][@"liveBroadcastContent"] && [i[@"snippet"][@"liveBroadcastContent"] isEqual:@"none"]? i[@"snippet"][@"liveBroadcastContent"]  : @"";
                        NSLog(@"%@", i[@"snippet"][@"liveBroadcastContent"]);
                        NSString *desc = i[@"snippet"][@"description"] &&  i[@"snippet"][@"description"]!=nil ? i[@"snippet"][@"description"] : @"";
                        NSMutableDictionary *object = [[NSMutableDictionary alloc]initWithObjects:@[i[@"snippet"][@"title"],[NSString stringWithFormat:@"%@", i[@"snippet"][@"publishedAt"]],i[@"snippet"][@"thumbnails"][@"default"][@"url"],i[@"id"][@"videoId"], desc, onAir] forKeys:@[@"title",@"publishedAt",@"thumb",@"video_id",@"desc",@"live"]];
//                        [loadedItemsData addObject:@{@"title":i[@"snippet"][@"title"], @"publishedAt":[NSString stringWithFormat:@"%@", i[@"snippet"][@"publishedAt"]], @"thumb":i[@"snippet"][@"thumbnails"][@"default"][@"url"], @"video_id":i[@"id"][@"videoId"], @"desc":desc, @"live":onAir}];
                        [loadedItemsData addObject:object];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [loadedItemsList reloadData];
                    });
//
                }
            }
        }
    }];
}
- (void)subscriptionsGlobalSearch{
    subscriptionsDataCopy = [[NSMutableArray alloc]initWithArray:subscriptionsData];
    [subscriptionsData removeAllObjects];
    NSString *searchString = [searchSubscriptionsBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    [_youtubeClient APIRequest:@"search" query:@{@"part":@"snippet", @"type":@"channel", @"maxResults":@50, @"q":searchString}
    handler:^(NSData *data) {
        if(data){
            NSDictionary *subsGSearchResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(subsGSearchResp[@"error"] && [subsGSearchResp[@"error"][@"code"]intValue]==401){
                [_youtubeClient refreshToken:^(NSData *data) {
                    NSDictionary *refreshTokenResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    //                    NSLog(@"%@", refreshTokenResponse);
                    
                    [_youtubeRWData updateYoutubeToken:refreshTokenResponse];
                    _youtubeClient = [[YoutubeClient alloc] initWithTokensFromCoreData];
                }];
            }else{
                //            NSLog(@"%@", lbrdsResp);
                
//                pageToken = subsGSearchResp[@"nextPageToken"] && subsGSearchResp[@"nextPageToken"] !=nil? subsGSearchResp[@"nextPageToken"] : nil ;
                for(NSDictionary *i in subsGSearchResp[@"items"]){
                    [subscriptionsData addObject:@{@"title":i[@"snippet"][@"title"], @"thumb_def":i[@"snippet"][@"thumbnails"][@"default"][@"url"], @"id":i[@"id"][@"channelId"]}];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([subscriptionsData count]>0){
                        [subscriptionsList reloadData];
                    }
                });
                
            }
        }
    }];
   
    
    
}
- (void)loadSearchSubscriptionsList{
    
    NSInteger counter=0;
    NSMutableArray *SubscriptionsDataTemp=[[NSMutableArray alloc]init];
    subscriptionsDataCopy = [[NSMutableArray alloc]initWithArray:subscriptionsData];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchSubscriptionsBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
    [SubscriptionsDataTemp removeAllObjects];
    for(NSDictionary *i in subscriptionsData){
        
        NSArray *found = [regex matchesInString:i[@"title"]  options:0 range:NSMakeRange(0, [i[@"title"] length])];
        if([found count]>0 && ![searchSubscriptionsBar.stringValue isEqual:@""]){
            counter++;
            [SubscriptionsDataTemp addObject:i];
        }
        
    }
    //     NSLog(@"Start search %@", banlistDataTemp);
    if([SubscriptionsDataTemp count]>0){
        subscriptionsData = SubscriptionsDataTemp;
        [subscriptionsList reloadData];
    }
    
}
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"YoutubePlayerSegue"]){
        YoutubeVideoPlayerController *controller = (YoutubeVideoPlayerController *)segue.destinationController;
        NSView *parentCell = [sender superview];
        NSInteger row = [loadedItemsList rowForView:parentCell];
        dataForPlayer = loadedItemsData[row];
//        NSLog(@"%@", dataForPlayer);
        controller.receivedData=dataForPlayer;
    }
    else if([segue.identifier isEqualToString:@"YoutubeAddToSocialsSegue"]){
        YoutubeVideosAddToSocialsController *controller = (YoutubeVideosAddToSocialsController*)segue.destinationController;
//        NSView *parentCell = [sender superview];
//        NSInteger row = loadedItemsData[row];
//        controller.receivedData=dataForSocials;
        NSIndexSet *rows = [loadedItemsList selectedRowIndexes];
        NSArray *objects = [loadedItemsData objectsAtIndexes:rows];
        controller.receivedData = objects;
    }
    else if([segue.identifier isEqualToString:@"AddToPlaylistsSegue"]){
        YoutubeAddToPlaylistController *controller = (YoutubeAddToPlaylistController*)segue.destinationController;
        NSIndexSet *rows = [loadedItemsList selectedRowIndexes];
        NSArray *objects = [loadedItemsData objectsAtIndexes:rows];
        controller.receivedData = objects;
    }
}
- (IBAction)openPlaylist:(id)sender {
    playlistLoaded=NO;
    NSView *parentCell = [sender superview];
    NSInteger row = [loadedItemsList rowForView:parentCell];
//    NSLog(@"%@", subscriptionsData[row][@"id"]);
    NSString *playlist = loadedItemsData[row][@"playlist_id"];
//    NSLog(@"%@", playlist);
//    [loadedItemsData removeAllObjects];
    [_youtubeClient APIRequest:@"playlistItems" query:@{@"playlistId":playlist, @"part":@"snippet", @"maxResults":@50} handler:^(NSData *data) {
        NSDictionary *getVideosResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        for(NSDictionary *i in getVideosResp[@"items"]){
            NSString *thumb = i[@"snippet"][@"thumbnails"][@"default"][@"url"]!=nil ? i[@"snippet"][@"thumbnails"][@"default"][@"url"] : @"";
            [loadedItemsData addObject:@{@"title":i[@"snippet"][@"title"], @"publishedAt":[NSString stringWithFormat:@"%@", i[@"snippet"][@"publishedAt"]], @"thumb":thumb, @"video_id":i[@"snippet"][@"resourceId"][@"videoId"]}];

        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadedItemsList reloadData];
        });
    }];
}

- (IBAction)loadVideosByChannel:(id)sender {
  
    NSView *parentCell = [sender superview];
    NSInteger row = [subscriptionsList rowForView:parentCell];
    NSLog(@"%@", subscriptionsData[row][@"id"]);
    channel =subscriptionsData[row][@"id"];
    [self loadVideos:NO];
}
- (void)loadVideos:(BOOL)offset {
    playlistLoaded=NO;
//    [loadedItemsData removeAllObjects];
    lastAction = 0;
//    offset ? nil :  [loadedItemsData removeAllObjects];
    [_youtubeClient APIRequest:@"channels" query:@{@"part":@"contentDetails", @"maxResults":@50, @"id":channel} handler:^(NSData *data) {
        if(data){
            NSDictionary *searchResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(searchResp[@"error"]){
                if ([searchResp[@"error"][@"code"]intValue]==401){
                    [_youtubeClient refreshToken:^(NSData *data){
                        NSDictionary *refreshTokenResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        //                    NSLog(@"%@", refreshTokenResponse);
                        
                        [_youtubeRWData updateYoutubeToken:refreshTokenResponse];
                        _youtubeClient = [[YoutubeClient alloc] initWithTokensFromCoreData];
                        
                    }];
                }else{
                    NSLog(@"%@", searchResp[@"error"]);
                }
            }
            else{
                if((pageToken && offset) || (pageToken && !offset) || (!pageToken && !offset) ) {
                    if(offset){
                        queryParams = @{@"playlistId":searchResp[@"items"][0][@"contentDetails"][@"relatedPlaylists"][@"uploads"], @"part":@"snippet,contentDetails", @"maxResults":@50, @"pageToken":pageToken};
                        
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if([loadedItemsData count]>0){
                                [loadedItemsList removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [loadedItemsData count])] withAnimation:NSTableViewAnimationEffectNone];
                            }
                        });
                        
                        queryParams = @{@"playlistId":searchResp[@"items"][0][@"contentDetails"][@"relatedPlaylists"][@"uploads"], @"part":@"snippet", @"maxResults":@50};
                        [loadedItemsData removeAllObjects];
                        //        offsetCounter=0;
                    }
                    
                    [_youtubeClient APIRequest:@"playlistItems" query:queryParams handler:^(NSData *data) {
                        if(data){
                            NSDictionary *getVideosResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                                            NSLog(@"%@", getVideosResp);
                            pageToken = getVideosResp[@"nextPageToken"] && getVideosResp[@"nextPageToken"] !=nil? getVideosResp[@"nextPageToken"] : nil ;
                            
                            for(NSDictionary *i in getVideosResp[@"items"]){
                                NSMutableDictionary *object = [[NSMutableDictionary alloc]initWithObjects:@[i[@"snippet"][@"title"],[NSString stringWithFormat:@"%@", i[@"snippet"][@"publishedAt"]],i[@"snippet"][@"thumbnails"][@"default"][@"url"],i[@"snippet"][@"resourceId"][@"videoId"],i[@"snippet"][@"description"] && i[@"snippet"][@"description"]!=nil?i[@"snippet"][@"description"]:@""] forKeys:@[@"title",@"publishedAt",@"thumb",@"video_id",@"desc"]];
//                                [loadedItemsData addObject:@{@"title":i[@"snippet"][@"title"], @"publishedAt":[NSString stringWithFormat:@"%@", i[@"snippet"][@"publishedAt"]], @"thumb":i[@"snippet"][@"thumbnails"][@"default"][@"url"], @"video_id":i[@"snippet"][@"resourceId"][@"videoId"], @"desc":i[@"snippet"][@"description"] && i[@"snippet"][@"description"]!=nil?i[@"snippet"][@"description"]:@""}];
                                [loadedItemsData addObject:object];
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [loadedItemsList reloadData];
                            });
                            
                            //}else{
                            //NSLog(@"All videos loaded");
                            //}
                        }
                    }];
                }
                
            }
        }
        
    }];
}
- (void)loadSubscriptions:(BOOL)offset{
    
    
    if(offset){
        queryParams = @{@"part":@"snippet", @"mine":@"true",  @"maxResults":@50, @"pageToken":subsPageToken};
        
    }
    else{
        queryParams = @{@"part":@"snippet", @"mine":@"true",  @"maxResults":@50};
        [subscriptionsData removeAllObjects];
        subsOffsetCounter=0;
    }
    [_youtubeClient APIRequest:@"subscriptions" query:queryParams handler:^(NSData *data){
        NSDictionary *getSubsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(getSubsResponse[@"error"]){
            if ([getSubsResponse[@"error"][@"code"]intValue]==401){
                [_youtubeClient refreshToken:^(NSData *data){
                    NSDictionary *refreshTokenResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    //NSLog(@"%@", refreshTokenResponse);
                    
                    [_youtubeRWData updateYoutubeToken:refreshTokenResponse];
                    _youtubeClient = [[YoutubeClient alloc]initWithTokensFromCoreData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [subscriptionsList reloadData];
//                        [progressLoad stopAnimation:self];
                        
                    });
                }];
            }else{
                NSLog(@"%@", getSubsResponse[@"error"]);
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [progressLoad stopAnimation:self];
                    
                });
            }
        }else{
            //            NSLog(@"%@", getSubsResponse);
            dispatch_async(dispatch_get_main_queue(), ^{
//                totalCount.title = [NSString stringWithFormat:@"%@", getSubsResponse[@"pageInfo"][@"totalResults"]];
            });
            subsPageToken = getSubsResponse[@"nextPageToken"];
            for(NSDictionary *i in getSubsResponse[@"items"]){
                [subscriptionsData addObject:@{@"id":i[@"snippet"][@"resourceId"][@"channelId"], @"title":i[@"snippet"][@"title"], @"thumb_def":i[@"snippet"][@"thumbnails"][@"default"][@"url"], @"desc":i[@"snippet"][@"description"], @"publishedAt":i[@"snippet"][@"publishedAt"]}];
                subsOffsetCounter++;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
//                [progressLoad stopAnimation:self];
//                loadedCount.title = [NSString stringWithFormat:@"%i", subsOffsetCounter];
                [subscriptionsList reloadData];
            });
        }
    }];

}
- (void)loadSubscriptionsFromData{
    if([[_youtubeRWData readSubscriptions] count]>0){
        subscriptionsData = [_youtubeRWData readSubscriptions];
        [subscriptionsList reloadData];
        loadSubscriptions = NO;

        //        NSLog(@"%@", subscriptionsData);
    }else{
        NSLog(@"Data is nil or something bad");
         loadSubscriptions = YES;
        [self loadSubscriptions:NO];
    }
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSIndexSet *rows = [loadedItemsList selectedRowIndexes];
//    videoVkData = loadedItemsData[row];
    if([rows count]>0){
        [addToSocialsButton setEnabled:YES];
        [AddToPlaylistsButton setEnabled:YES];
    }else{
        [addToSocialsButton setEnabled:NO];
         [AddToPlaylistsButton setEnabled:NO];
    }
   
    
    
}



- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if(tableView == subscriptionsList){
        return [subscriptionsData count];
    }else if(tableView == loadedItemsList){
        return [loadedItemsData count];
    }
    return 0;
}
- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if(tableView == subscriptionsList){
        YoutubeSubscriptionsCustomCell *cell = [[YoutubeSubscriptionsCustomCell alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.gtitle.stringValue = subscriptionsData[row][@"title"];
        cell.photo.wantsLayer=YES;
        cell.photo.layer.masksToBounds=YES;
        cell.photo.layer.cornerRadius=40/2;
//      
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:subscriptionsData[row][@"thumb_def"]]];
//            NSImageRep *rep = [[image representations] objectAtIndex:0];
//            NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
//            image.size=imageSize;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [cell.photo setImage:image];
//            });
//        });
        [cell.photo sd_setImageWithURL:[NSURL URLWithString:subscriptionsData[row][@"thumb_def"]] placeholderImage:nil options:SDWebImageRefreshCached completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            NSImageRep *rep = [[image representations] objectAtIndex:0];
            NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
            image.size=imageSize;
            [cell.photo setImage:image];
        }];
        return cell;
    }else if(tableView == loadedItemsList){
        YoutubeVideosCustomCell *cell = [[YoutubeVideosCustomCell alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.vtitle.stringValue = loadedItemsData[row][@"title"];
        cell.publishedDate.stringValue = loadedItemsData[row][@"publishedAt"];
//        cell.desc.stringValue=loadedItemsData[row][@"desc"];
//        cell.duration.stringValue=loadedItemsData[row][@"duration"];
        if(loadedItemsData[row][@"live"] && [loadedItemsData[row][@"live"] isEqual:@"live"]){
            cell.onAir.hidden=NO;
            
        }else{
            cell.onAir.hidden=YES;
        }
        if (playlistLoaded){
            cell.playButton.hidden=YES;
            cell.openPlaylistButton.hidden=NO;
        }else{
            cell.playButton.hidden=NO;
            cell.openPlaylistButton.hidden=YES;
        }
        if(![loadedItemsData[row][@"thumb"] isEqual:@""]){
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:loadedItemsData[row][@"thumb"]]];
//                NSImageRep *rep = [[image representations] objectAtIndex:0];
//                NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
//                image.size=imageSize;
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [cell.thumb setImage:image];
//                });
//            });
            [cell.thumb sd_setImageWithURL:[NSURL URLWithString:loadedItemsData[row][@"thumb"]] placeholderImage:nil options:SDWebImageRefreshCached completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                NSImageRep *rep = [[image representations] objectAtIndex:0];
                NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
                image.size=imageSize;
                [cell.thumb setImage:image];
            }] ;
        }
        
        return cell;
    }
    return nil;
}
@end
