//
//  YoutubeSubscriptions.m
//  MasterAPI
//
//  Created by sim on 12.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "YoutubeSubscriptions.h"
#import "YoutubeSubscriptionsCustomCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface YoutubeSubscriptions ()<NSTableViewDelegate, NSTableViewDataSource>

@end

@implementation YoutubeSubscriptions

- (void)viewDidLoad {
    [super viewDidLoad];
    subscriptionsList.delegate=self;
    subscriptionsList.dataSource=self;
    subscriptionsData = [[NSMutableArray alloc]init];
    _youtubeClient = [[YoutubeClient alloc]initWithTokensFromCoreData];
    _youtubeRWData = [[YoutubeRWData alloc]init];
    [[subscriptionsScroll contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
//    [self loadSubscriptions:NO];
    [self loadSubscriptionsFromData];
    offsetCounter = 0;
}
-(void)viewDidAppear{
    
}
-(void)viewDidScroll:(NSNotification *)notification{
    if([notification.object isEqual:subscriptionsClip]){
        NSInteger scrollOrigin = [[subscriptionsScroll contentView]bounds].origin.y+NSMaxY([subscriptionsScroll visibleRect]);
        //    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
        NSInteger boundsHeight = subscriptionsList.bounds.size.height;
        //    NSInteger frameHeight = subscribersList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            //Refresh here
            //         NSLog(@"The end of table");
            if([[_youtubeRWData readSubscriptions] count] == 0 && pageToken!=nil){
                [self loadSubscriptions:YES];
            }
        }
        //        NSLog(@"%ld", scrollOrigin);
        //        NSLog(@"%ld", boundsHeight);
        //    NSLog(@"%fld", frameHeight-300);
        //
    }
}
- (IBAction)saveSubscriptions:(id)sender {
    if([[_youtubeRWData readSubscriptions]count] >0){
        [_youtubeRWData removeAllSubscriptions];
        [_youtubeRWData saveSubscriptions:subscriptionsData];
    }else{
         [_youtubeRWData saveSubscriptions:subscriptionsData];
    }
   
}
- (IBAction)reloadSubscriptions:(id)sender {
    
    [self loadSubscriptions:NO];
    
}
- (IBAction)removeSubscriptions:(id)sender {
    [_youtubeRWData removeAllSubscriptions];
    
}
- (IBAction)showVideos:(id)sender {
    NSView *parentCell = [sender superview];
    NSInteger row = [subscriptionsList rowForView:parentCell];
//    NSLog(@"%@", subscriptionsData[row][@"title"]);
    NSString *channel =subscriptionsData[row][@"id"];
    [_youtubeClient APIRequest:@"channels" query:@{@"part":@"contentDetails", @"id":channel} handler:^(NSData *data) {
        NSDictionary *searchResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        [_youtubeClient APIRequest:@"playlistItems" query:@{@"playlistId":searchResp[@"items"][0][@"contentDetails"][@"relatedPlaylists"][@"uploads"], @"part":@"snippet"} handler:^(NSData *data) {
            NSDictionary *getVideosResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

                    if(searchResp[@"error"]){
                        if ([searchResp[@"error"][@"code"]intValue]==401){
                            [_youtubeClient refreshToken:^(NSData *data){
                                NSDictionary *refreshTokenResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                //                    NSLog(@"%@", refreshTokenResponse);
            
                                [_youtubeRWData updateYoutubeToken:refreshTokenResponse];
                                _youtubeClient = [[YoutubeClient alloc]initWithTokensFromCoreData];
            
                            }];
                        }
                    }
                    else{
                            NSLog(@"%@", getVideosResp);
                    }
        }];

    }];
}
-(void)loadSubscriptions:(BOOL)offset{
    [progressLoad startAnimation:self];
    NSDictionary *queryParams;
    
    
    if(offset && pageToken){
        queryParams = @{@"part":@"snippet", @"mine":@"true",  @"maxResults":@50, @"pageToken":pageToken};
      
    }
    else{
        queryParams = @{@"part":@"snippet", @"mine":@"true",  @"maxResults":@50};
        [subscriptionsData removeAllObjects];
        offsetCounter=0;
    }
    [_youtubeClient APIRequest:@"subscriptions" query:queryParams handler:^(NSData *data){
        NSDictionary *getSubsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(getSubsResponse[@"error"]){
            if ([getSubsResponse[@"error"][@"code"]intValue]==401){
                [_youtubeClient refreshToken:^(NSData *data){
                    NSDictionary *refreshTokenResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                    NSLog(@"%@", refreshTokenResponse);
                    
                    [_youtubeRWData updateYoutubeToken:refreshTokenResponse];
                    _youtubeClient = [[YoutubeClient alloc]initWithTokensFromCoreData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [subscriptionsList reloadData];
                        [progressLoad stopAnimation:self];
                        
                    });
                }];
            }else{
                NSLog(@"%@", getSubsResponse[@"error"]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressLoad stopAnimation:self];
                    
                });
            }
        }else{
//            NSLog(@"%@", getSubsResponse);
            dispatch_async(dispatch_get_main_queue(), ^{
               totalCount.title = [NSString stringWithFormat:@"%@", getSubsResponse[@"pageInfo"][@"totalResults"]];
            });
            pageToken = getSubsResponse[@"nextPageToken"] && getSubsResponse[@"nextPageToken"] !=nil? getSubsResponse[@"nextPageToken"] : nil ;
//            if((pageToken && offset) || (pageToken && !offset) || (!pageToken && !offset)){
                for(NSDictionary *i in getSubsResponse[@"items"]){
                    NSString *thumb_def=i[@"snippet"][@"thumbnails"][@"default"][@"url"];
                    NSString *thumb_med=i[@"snippet"][@"thumbnails"][@"medium"][@"url"];
                    NSString *thumb_high=i[@"snippet"][@"thumbnails"][@"high"][@"url"];
                    NSString *subId=i[@"snippet"][@"resourceId"][@"channelId"];
                    NSString *stitle=i[@"snippet"][@"title"];
                    NSString *desc=i[@"snippet"][@"description"];
                    NSString *publishedDate=i[@"snippet"][@"publishedAt"];
                    [subscriptionsData addObject:@{@"id":subId, @"title":stitle, @"thumb_def":thumb_def, @"desc":desc, @"publishedAt":publishedDate, @"thumb_med":thumb_med, @"thumb_high":thumb_high}];
                    offsetCounter++;
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressLoad stopAnimation:self];
                    loadedCount.title = [NSString stringWithFormat:@"%i", offsetCounter];
                    [subscriptionsList reloadData];
                });
//            }else{
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [progressLoad stopAnimation:self];
////                    loadedCount.title = [NSString stringWithFormat:@"%i", offsetCounter];
////                    [subscriptionsList reloadData];
//                });
//                NSLog(@"All pages done");
//            }
        }
    }];
}
-(void)loadSubscriptionsFromData{
    if([[_youtubeRWData readSubscriptions] count]>0){
        subscriptionsData = [_youtubeRWData readSubscriptions];
        totalCount.title = [NSString stringWithFormat:@"%li", [subscriptionsData count]];
        loadedCount.title = [NSString stringWithFormat:@"%li", [subscriptionsData count]];
        [subscriptionsList reloadData];
//        NSLog(@"%@", subscriptionsData);
    }else{
        NSLog(@"Data is nil or something bad");
          [self loadSubscriptions:NO];
    }
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [subscriptionsData count];
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    YoutubeSubscriptionsCustomCell *cell = [[YoutubeSubscriptionsCustomCell alloc]init];
    cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.desc.stringValue = subscriptionsData[row][@"desc"];
    cell.gtitle.stringValue = subscriptionsData[row][@"title"];
    cell.publishedDate.stringValue = subscriptionsData[row][@"publishedAt"];
//    cell.chId.stringValue = subscriptionsData[row][@"id"];
    cell.photo.wantsLayer=YES;
    cell.photo.layer.masksToBounds=YES;
    cell.photo.layer.cornerRadius=64/2;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:subscriptionsData[row][@"thumb_def"]]];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [cell.photo setImage:image];
//        });
//    });
    [cell.photo sd_setImageWithURL:[NSURL URLWithString:subscriptionsData[row][@"thumb_def"]] placeholderImage:nil options:SDWebImageRefreshCached];
    return cell;
}
@end
