//
//  YoutubeVideosAddToSocialsController.m
//  MasterAPI
//
//  Created by sim on 15.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "YoutubeVideosAddToSocialsController.h"
#import "ShowVideoViewController.h"
#import "YoutubeVideosCustomCell.h"
@interface YoutubeVideosAddToSocialsController () <NSTableViewDelegate, NSTableViewDataSource>

@end

@implementation YoutubeVideosAddToSocialsController 

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    NSLog(@"%@", _receivedData);
    [self addSuccessMarkToVideosData];
    videosListData = [[NSMutableArray alloc] initWithArray: _receivedData];
    albumsListData = [[NSMutableArray alloc] init];
    selectedVideosList.delegate = self;
    selectedVideosList.dataSource = self;
    selectedAlbumsList.delegate = self;
    selectedAlbumsList.dataSource = self;
    
    [selectedVideosList reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedVideoAlbumVK:) name:@"selectedVideoAlbumVK" object:nil];
}
-(void)selectedVideoAlbumVK:(NSNotification*)notification{
    [albumsListData addObject:notification.userInfo];
    NSLog(@"%@", albumsListData);
    [selectedAlbumsList reloadData];
}
- (IBAction)acceptAddToSocials:(id)sender {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self addToSocials];
    });
}
-(void)addSuccessMarkToVideosData{
    for(NSMutableDictionary *i in _receivedData){
//        [i insertValue:@0 inPropertyWithKey:@"success"];
        [i addEntriesFromDictionary:@{@"success":@0}];
    }
}
- (IBAction)selectAlbums:(id)sender {
    
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    ShowVideoViewController *controller = [story instantiateControllerWithIdentifier:@"ShowVideo"];
    controller.addSelectedAlbumVKSocial = @{@"addSelectedAlbumVKSocial":@"yes"};
    [self presentViewControllerAsModalWindow:controller];
    
}
-(void)addToSocials{
//    videoVkURL = [NSString stringWithFormat:@"https://youtube.com/watch?v=%@", videoVkData[@"video_id"]];
//    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        
        __block NSString *targetAlbumIdVK = [albumsListData count]>0 ? [NSString stringWithFormat:@"%@", albumsListData[0][@"id"]] : @"-2";
        targetAlbumIdVK = [targetAlbumIdVK isEqual:@"-2"] ? @"" : [NSString stringWithFormat:@"album_id=%@&", targetAlbumIdVK];
        targetAlbumOwner = albumsListData[0][@"owner_id"];
        NSLog(@"target album id:%@", targetAlbumIdVK);
        NSLog(@"%@", albumsListData[0]);
        for(NSMutableDictionary *i in _receivedData){
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.save?%@name=%@&link=%@&privacy_view=nobody&%@access_token=%@&v=%@",[targetAlbumOwner intValue]<0?[NSString stringWithFormat:@"group_id=%i&", abs([targetAlbumOwner intValue])] : @"", [i[@"title"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], [NSString stringWithFormat:@"https://youtube.com/watch?v=%@", i[@"video_id"]], targetAlbumIdVK, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *uploadResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", uploadResp);
                [[_app.session dataTaskWithURL:[NSURL URLWithString:uploadResp[@"response"][@"upload_url"]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSDictionary *saveResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@", saveResp);
                    if([saveResp[@"response"] intValue] == 1){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSInteger index = [_receivedData indexOfObject:i];
                            i[@"success"]=@1;
                            
                            [selectedVideosList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                            dispatch_semaphore_signal(semaphore);
                            //                       selectedVideosList rowat
                        });
                    }
                }]resume];
                sleep(1);
            }]resume];
            sleep(1);
       
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_signal(semaphore);
        }
    });
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if(tableView == selectedVideosList){
        return [videosListData count];
    }else{
        return [albumsListData count];
    }
    return 0;
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if(tableView == selectedVideosList){
        YoutubeVideosCustomCell *cell = [[YoutubeVideosCustomCell alloc] init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.vtitle.stringValue = videosListData[row][@"title"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:videosListData[row][@"thumb"]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.thumb setImage:image];
            });
        });
        if([videosListData[row][@"success"] intValue]==1){
            cell.successMark.hidden=NO;
        }else{
            cell.successMark.hidden=YES;
        }
        return cell;
    }else if(tableView == selectedAlbumsList){
        YoutubeVideosCustomCell *cell = [[YoutubeVideosCustomCell alloc] init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.vtitle.stringValue = albumsListData[row][@"title"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:albumsListData[row][@"cover"]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.thumb setImage:image];
            });
        });
        
        return cell;
    }
    else{
        return nil;
    }
}
@end
