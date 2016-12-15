//
//  moveToAlbumViewController.m
//  vkapp
//
//  Created by sim on 09.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "moveToAlbumViewController.h"

@interface moveToAlbumViewController () <NSTableViewDelegate, NSTableViewDataSource>

@end

@implementation moveToAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _app = [[appInfo alloc]init];
    moveToAlbumTableView.delegate=self;
    moveToAlbumTableView.dataSource=self;
    albumsData = [[NSMutableArray alloc]init];
    groupsByAdminPopupData = [[NSMutableArray alloc]init];
    [groupsByAdminPopup removeAllItems];
    [groupsByAdminPopupData addObject:_app.person];
    [groupsByAdminPopup addItemWithTitle:@"Personal"];
    [[albumsListScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    videoIdsInAlbum = [[NSMutableArray alloc]init];
    NSLog(@"ID %@", _videoId);
    NSLog(@"ownerId %@", _ownerId);
    [self loadAlbums:NO];
    [self loadGroupsByAdminPopup];
    offsetAlbums=0;
    targetId = targetId == nil ? _app.person : targetId;
    _captchaHandle = [[VKCaptchaHandler alloc]init];
    offsetCounter=0;
    progressBar.maxValue=[_countInAlbum intValue];
}
-(void)viewDidScroll:(NSNotification*)notification{
    
    NSInteger scrollOrigin = [[albumsListScrollView contentView]bounds].origin.y+NSMaxY([albumsListScrollView visibleRect]);
    //    NSInteger numberRowHeights = [collectionViewListAlbums numberOfItemsInSection:0];
    NSInteger boundsHeight = moveToAlbumTableView.bounds.size.height;
    //    NSInteger frameHeight = playList.frame.size.height;
    if (scrollOrigin == boundsHeight) {
        
        NSLog(@"The end of section");
        
        [self loadAlbums:YES];
        
       
    }

}
- (IBAction)closeWindow:(id)sender {

    [self dismissViewController:self];
    
    
}
-(void)loadGroupsByAdminPopup{
    
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
            [groupsByAdminPopupData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
            [groupsByAdminPopup addItemWithTitle:i[@"name"]];
            
        }
    }]resume];
}
- (IBAction)groupsByAdminPopupSelect:(id)sender {
    targetId = [groupsByAdminPopupData objectAtIndex:[groupsByAdminPopup indexOfSelectedItem]];
    [self loadAlbums:0];
    
    
    
}
- (IBAction)moveToAlbum:(id)sender {
    targetAlbum = [albumsData objectAtIndex:[moveToAlbumTableView selectedRow]][@"id"];
//
    NSLog(@"Add to %@", targetAlbum);
    targetId = targetId == nil ? _app.person : targetId;
//    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.removeFromAlbum?target_id=%@&album_id=%@&owner_id=%@&video_id=%@&access_token=%@&v=%@", targetId, albumAdded, _ownerId, _videoId, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSDictionary *videoAddToAlbumResposne = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"Video added successfully %@", videoAddToAlbumResposne);
//         NSLog(@"Remove from %@", albumAdded);
//    }]resume];
    if([_type isEqual:@"video"]){
        [self addToAlbumSelectedVideo];
    }else{
        NSLog(@"album type action there will be");
        [self addToAlbumVideosInSelectedAlbum];
    }
}
-(void)addToAlbumVideosInSelectedAlbum{

      [self getVideoInAlbum:^(NSMutableArray *data) {
          if(data){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self addMultipleVideos];
            
            });
          }
      }];
   
  
    
}
-(void)addMultipleVideos{
    __block void (^addToAlbumVideos)( BOOL, NSInteger, NSString *, NSString *);
    addToAlbumVideos = ^void(BOOL captcha, NSInteger offset, NSString *captcha_sid, NSString *captcha_key){
        stopFlag=NO;
        next=NO;
        offsetCounter = offset ? offset : offsetCounter;
        while(offsetCounter < [videoIdsInAlbum count]){
            if(next){
                next=NO;
                continue;
                
            }
            NSLog(@"Offset %li", offsetCounter);
            NSLog(@"data count %li", [videoIdsInAlbum count]);
            NSLog(@"targetID %@", targetId );
            NSLog(@"targetAlbum %@", targetAlbum );
            
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.addToAlbum?target_id=%@&album_id=%@&owner_id=%@&video_id=%@&access_token=%@&v=%@%@", targetId, targetAlbum, videoIdsInAlbum[offsetCounter][@"owner_id"], videoIdsInAlbum[offsetCounter][@"id"], _app.token, _app.version, captcha ? [NSString stringWithFormat:@"&captcha_sid=%@&captcha_key=%@", captcha_sid, captcha_key ] : @""]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *videoAddToAlbumResposne = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", videoAddToAlbumResposne);
                if(videoAddToAlbumResposne[@"error"]){
                    if([videoAddToAlbumResposne[@"error"][@"error_code"] intValue] == 14){
                        if(!stopFlag){
                            stopFlag=YES;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSInteger result = [[_captchaHandle handleCaptcha:videoAddToAlbumResposne[@"error"][@"captcha_img"]]runModal];
                                if(result == NSAlertFirstButtonReturn){
                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                        addToAlbumVideos(YES, offsetCounter, videoAddToAlbumResposne[@"error"][@"captcha_sid"],_captchaHandle.enterCode.stringValue);
                                        
                                    });
                                    
                                    
                                }
                            });
                        }
                        
                    }
                    else if([videoAddToAlbumResposne[@"error"][@"error_code"] intValue] == 800){
                        NSLog(@"%@:%@", videoAddToAlbumResposne[@"error"][@"error_msg"], videoAddToAlbumResposne[@"error"][@"error_code"]);
                        next=YES;
                        offsetCounter+=1;
                        
                    }
                    //                    NSLog(@"%@", videoAddToAlbumResposne[@"error"]);
                }else{
                    offsetCounter+=1;
                    NSLog(@"Video added successfully.");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressBar.doubleValue=offsetCounter;
                    });
                }
            }]resume];
            sleep(1);
            if(stopFlag){
                break;
            }
        }
    };
    addToAlbumVideos(NO, 0, @"", @"");

}
-(void)getVideoInAlbum:(OnComplete)completion{
    __block int offset=0;
    [videoIdsInAlbum removeAllObjects];
    if([_countInAlbum intValue]>200){
        while(offset < [_countInAlbum intValue]){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.get?owner_id=%@&album_id=%@&count=200&offset=%i&access_token=%@&v=%@", _ownerId, _albumIdToGetVideos, offset, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *getVideosResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if(getVideosResp[@"response"]){
                    for(NSDictionary *i in getVideosResp[@"response"][@"items"]){
                        [videoIdsInAlbum addObject:@{@"owner_id":i[@"owner_id"], @"id":i[@"id"]}];
                        
                    }
                    offset+=200;
                }
                
            }]resume];
            sleep(1);
        }
        completion(videoIdsInAlbum);
    }else{
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.get?owner_id=%@&album_id=%@&count=200&access_token=%@&v=%@", _ownerId, _albumIdToGetVideos, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *getVideosResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(getVideosResp[@"response"]){
                for(NSDictionary *i in getVideosResp[@"response"][@"items"]){
                    [videoIdsInAlbum addObject:@{@"owner_id":i[@"owner_id"], @"id":i[@"id"]}];
                    
                }
                completion(videoIdsInAlbum);
            }
        }]resume];
    }
}
-(void)addToAlbumSelectedVideo{
    if([_selectedVideos count]>0){
        videoIdsInAlbum = _selectedVideos;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             [self addMultipleVideos];
        });
       
    }else{
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.addToAlbum?target_id=%@&album_id=%@&owner_id=%@&video_id=%@&access_token=%@&v=%@", targetId, targetAlbum, _ownerId, _videoId, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *videoAddToAlbumResposne = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"Video added successfully %@", videoAddToAlbumResposne);
        }]resume];
    }
}
-(void)loadAlbums:(BOOL)makeOffset{
    if(makeOffset){
        offsetAlbums=offsetAlbums+100;
    }else{
        offsetAlbums=0;
        [albumsData removeAllObjects];
    }
    targetId = targetId == nil ? _app.person : targetId;
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.getAlbums?owner_id=%@&count=100&offset=%i&need_system=1&access_token=%@&v=%@",targetId, offsetAlbums, _app.token, _app.version]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *getAlbumsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *i in getAlbumsResponse[@"response"][@"items"]){
            [albumsData addObject:@{@"title":i[@"title"], @"id":i[@"id"]}];
            if([i[@"title"] isEqual:@"Добавленные"]){
                albumAdded = i[@"id"];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [moveToAlbumTableView reloadData];
        });
    }]resume];
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([albumsData count]>0){
        
        return [albumsData count];
    }
    return 0;
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
     if([albumsData count]>0){
         NSTableCellView *cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
         cell.textField.stringValue=albumsData[row][@"title"];
         return cell;
     }
    return nil;
}
@end
