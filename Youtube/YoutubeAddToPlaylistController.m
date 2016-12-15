//
//  YoutubeAddToPlaylistController.m
//  MasterAPI
//
//  Created by sim on 07.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "YoutubeAddToPlaylistController.h"
#import "YoutubeVideosCustomCell.h"

@interface YoutubeAddToPlaylistController ()<NSTableViewDelegate, NSTableViewDataSource>

@end

@implementation YoutubeAddToPlaylistController

- (void)viewDidLoad {
    [super viewDidLoad];
    playlistsList.delegate=self;
    playlistsList.dataSource=self;
    videosList.delegate=self;
    videosList.dataSource=self;
    _youtubeClient = [[YoutubeClient alloc] initWithTokensFromCoreData];
    _youtubeRWData = [[YoutubeRWData alloc]init];
    videosListData = [[NSMutableArray alloc] initWithArray: _receivedData];
    playlistsData = [[NSMutableArray alloc]init];
    [videosList reloadData];
//    NSLog(@"%@", _receivedData);
    [self loadPlaylists];
}

- (IBAction)addToPlaylists:(id)sender {
    
    
    
}
-(void)loadPlaylists{
    [playlistsData removeAllObjects];
    [_youtubeClient APIRequest:@"playlists" query:@{@"part":@"snippet", @"mine":@"true", @"maxResults":@50 } handler:^(NSData *data) {
        NSDictionary *playlistsResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"%@", playlistsResp);
        for(NSDictionary *i in playlistsResp[@"items"]){
            [playlistsData addObject:@{@"title":i[@"snippet"][@"title"], @"thumb":i[@"snippet"][@"thumbnails"][@"default"][@"url"]}];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [playlistsList reloadData];
        });
    }];
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if(tableView == videosList){
        
        
        return [videosListData count];
    }else if(tableView == playlistsList){
        
        return [playlistsData count];
    }
    return 0;
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if(tableView == videosList){
        YoutubeVideosCustomCell *cell = [[YoutubeVideosCustomCell alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.vtitle.stringValue = videosListData[row][@"title"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:videosListData[row][@"thumb"]]];
//            [cells addObject:cell];
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.thumb setImage:image];
            });
        });

        return cell;
    }else if(tableView == playlistsList){
        YoutubeVideosCustomCell *cell = [[YoutubeVideosCustomCell alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.vtitle.stringValue = playlistsData[row][@"title"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:playlistsData[row][@"thumb"]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.thumb setImage:image];
            });
        });
        return cell;
    }
    return nil;
}
@end
