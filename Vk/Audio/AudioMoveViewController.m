//
//  AudioMoveViewController.m
//  vkapp
//
//  Created by sim on 18.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "AudioMoveViewController.h"
#import "AudioAlbumsListCustomCell.h"
#import "EditAudioAlbumViewController.h"
#import "CreateAlbumPopup.h"
#import "AudioListCustomCell.h"
#import "AddAudiosViewController.h"
@interface AudioMoveViewController ()<NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate>

@end

@implementation AudioMoveViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    albumsListData = [[NSMutableArray alloc]init];
    audioListData = [[NSMutableArray alloc]init];
    removeMultipleAlbumsBut.hidden=YES;
    removeMultipleAudiosBut.hidden=YES;
    removeAudiosInAlbumCheck.hidden=YES;
    _app = [[appInfo alloc]init];
    [[audioListScroll contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadAlbums:) name:@"reloadAudioAlbums" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(editAudioAlbumName:) name:@"editAudioAlbumName" object:nil];
    searchBar.delegate=self;
    albumSearchBar.delegate=self;
    searchAudioOffset = 0;
   [audioList registerForDraggedTypes:[NSArray arrayWithObject:@"NSMutableArray"]];
    userGroupsByAdminData = [[NSMutableArray alloc]init];
    [userGroupsByAdminPopup removeAllItems];
    [userGroupsByAdminPopup addItemWithTitle:@"Personal"];
    [userGroupsByAdminData addObject:_app.person];
    [self loadGroupsByAdmin];
    [progressSpin startAnimation:self];
    [self loadAudioAlbums:nil publicId:_app.person];
    owner = owner == nil ? _app.person : owner;
    audiosForRestore = [[NSMutableArray alloc]init];
//        sleep(1);
//         [audioListData removeAllObjects];
    if([audioListData count]==0){
        [self loadAudioList:NO album:nil addTracks:NO fullReload:YES];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createAlbumFromArtistInAudiolist:) name:@"createAlbumFromArtistInAudiolist" object:nil];
    restoreAllAudiosBut.hidden=YES;
}
-(void)createAlbumFromArtistInAudiolist:(NSNotification*)notification{
    __block NSString *albumName = [audioListData[[notification.userInfo[@"row"] intValue]][@"artist"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.addAlbum?%@=%@&title=%@&v=%@&access_token=%@", [owner isEqual:_app.person ]?@"owner_id":@"group_id", [owner isEqual:_app.person ] ? owner : [NSString stringWithFormat:@"%i", abs([owner intValue])] , albumName,  _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *addAlbumResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(addAlbumResponse[@"response"]){
            NSLog(@"New album created. Album Id: %@. Album name: %@", addAlbumResponse[@"response"][@"album_id"], albumName);
            NSMutableDictionary *object = [[NSMutableDictionary alloc]initWithObjects:@[addAlbumResponse[@"response"][@"album_id"],[albumName stringByRemovingPercentEncoding]] forKeys:@[@"id",@"title"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [albumsListData insertObject:object atIndex:2];
                [albumsList insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:2] withAnimation:NSTableViewAnimationEffectNone];
                [albumsList reloadData];
            });
        
        }
        else if(addAlbumResponse[@"error"]){
            NSLog(@"%@:%@", addAlbumResponse[@"error"][@"error_code"], addAlbumResponse[@"error"][@"error_msg"]);
        }
        
    }] resume];

}
- (IBAction)userGroupsByAdminPopupSelect:(id)sender {
    owner = userGroupsByAdminData[[userGroupsByAdminPopup indexOfSelectedItem]];
//    NSLog(@"%@", owner);
    [self loadAudioAlbums:nil publicId:owner];
    
}
-(void)loadGroupsByAdmin{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
                    [userGroupsByAdminData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
                    [userGroupsByAdminPopup addItemWithTitle:i[@"name"]];
                    
                }
            }]resume];
        });
    });
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    if([sender isEqual: albumSearchBar]){
        albumsListData = albumsListDataCopy;
        [albumsList reloadData];
    }else{
        searchMode=NO;
//        audioListData = audioListDataCopy;
//        [audioList reloadData];
    }
}
-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    if([sender isEqual: albumSearchBar]){
        NSLog(@"sender equal albumsList");
        [self searchAlbum];
        
    }else{
        [self searchAudio:0];
    }
    
    
}
-(void)searchAudio:(BOOL)offset{
    searchMode=YES;
    if(offset){
        searchAudioOffset = searchAudioOffset + 300;
    }else{
        searchAudioOffset = 0;
        audioListDataCopy = [[NSMutableArray alloc]initWithArray:audioListData];
        [audioListData removeAllObjects];
    }
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.search?q=%@&count=300&auto_complete=1&offset=%i&access_token=%@&v=%@", [searchBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], searchAudioOffset, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *audioSearchResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(audioSearchResp[@"response"]){
            for(NSDictionary *i in audioSearchResp[@"response"][@"items"]){
                [audioListData addObject:@{@"id":i[@"id"], @"artist":i[@"artist"], @"title":i[@"title"], @"duration":i[@"duration"], @"url":i[@"url"], @"owner_id":i[@"owner_id"]}];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [audioList reloadData];
            });
        }
    }]resume];
}
- (IBAction)removeMultipleAlbums:(id)sender {
    
    
}
- (IBAction)restoreOneAudio:(id)sender {
    
   __block NSInteger row = [audioList rowForView:[sender superview]];
    
    
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.restore?audio_id=%@&owner_id=%@&access_token=%@&v=%@", audioListData[row][@"id"], owner == nil ? _app.person : owner, _app.token,_app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *audioRestoreResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(audioRestoreResp[@"response"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                audioListData[row][@"deleted"]=@0;
                [audiosForRestore removeObjectAtIndex:[audiosForRestore indexOfObject:audioListData[row]]];
                [audioList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                if([audiosForRestore count]==0){
                    restoreAllAudiosBut.hidden=YES;
                }else{
                    restoreAllAudiosBut.hidden=NO;
                }
            });
        }
    }]resume];
}
- (IBAction)restoreAllAudios:(id)sender {
    if([audiosForRestore count]>0){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for(NSMutableDictionary *i in audiosForRestore){
                [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.restore?audio_id=%@&owner_id=%@&access_token=%@&v=%@", i[@"id"], owner == nil ? _app.person : owner, _app.token,_app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSDictionary *audioRestoreResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@", audioRestoreResp);
                    if(audioRestoreResp[@"response"]){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            audioListData[[audioListData indexOfObject:i]][@"deleted"]=@0;
                            [audioList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[audioListData indexOfObject:i]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                        });
                        
                    }
                }]resume];
                sleep(1);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
//                restoreAllAudiosBut.hidden=YES;
                [audiosForRestore removeAllObjects];
                if([audiosForRestore count]==0){
                    restoreAllAudiosBut.hidden=YES;
                }else{
                    restoreAllAudiosBut.hidden=NO;
                }
            });
        });
    }
    
}
- (IBAction)removeMultipleAudios:(id)sender {
    __block NSInteger delCounter=0;
    removeMultipleAudiosProgressBar.maxValue=[[self getSelectedItemsInAudioList] count];
    removeMultipleAudiosLabel.stringValue = [NSString stringWithFormat:@"%li / %li", delCounter, [[self getSelectedItemsInAudioList] count]];
    
    
//    for(NSMutableDictionary *i in [self getSelectedItemsInAudioList]){
//       
//        
//    };

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(NSMutableDictionary *i in [self getSelectedItemsInAudioList]){
            
        
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.delete?audio_id=%@&owner_id=%@&access_token=%@&v=%@", i[@"id"], owner == nil ? _app.person : owner, _app.token,_app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if(data){
                    NSDictionary *deleteAudioResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@", deleteAudioResp);
                    delCounter++;
                    i[@"deleted"] = @1;
                    [audiosForRestore addObject:i];
                   
                    dispatch_async(dispatch_get_main_queue(), ^{
                         [audioList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[audioListData indexOfObject:i]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                        removeMultipleAudiosProgressBar.doubleValue=delCounter;
                        removeMultipleAudiosLabel.stringValue = [NSString stringWithFormat:@"%li / %li", delCounter, [[self getSelectedItemsInAudioList] count]];
                    });
                }else{
                    NSLog(@"Error delete audios. Connection problem.");
                    
                }
                
            }]resume];
            sleep(1);
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if([audiosForRestore count]>0){
                restoreAllAudiosBut.hidden=NO;
            }else{
                restoreAllAudiosBut.hidden=YES;
            }
            [audioList reloadData];
        });
    });
    
}

- (IBAction)deleteItemInAudioList:(id)sender {
    
    NSView *view =[sender superview];
    __block NSInteger index = [audioList rowForView:view];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.delete?owner_id=%@&audio_id=%@&access_token=%@&v=%@", owner, audioListData[index][@"id"], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *deleteAudioResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(deleteAudioResp[@"response"]){
            dispatch_async(dispatch_get_main_queue(), ^{
//                [audioListData removeObjectAtIndex:index];
                [audioList deselectRow:index];
                audioListData[index][@"deleted"]=@1;
                [audiosForRestore addObject:audioListData[index]];
//                [audioList removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationEffectNone];
                [audioList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index]  columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                //    [audioList reloadData];
                if([audiosForRestore count]==0){
                    restoreAllAudiosBut.hidden=YES;
                }else{
                    restoreAllAudiosBut.hidden=NO;
                }
            });
            
            
        }
    }]resume];
    
}
-(void)searchAlbum{
    albumsListDataCopy = [[NSMutableArray alloc]initWithArray:albumsListData];
    [albumsListData removeAllObjects];
    NSRegularExpression *regex =[ NSRegularExpression regularExpressionWithPattern:albumSearchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
    [albumsListData addObject:@{ @"title":@"all"}];
    [albumsListData addObject:@{ @"title":@"without album"}];
    for(NSDictionary *i in albumsListDataCopy){
        NSArray *found = [regex matchesInString:i[@"title"] options:0 range:NSMakeRange(0, [i[@"title"] length])];
        if([found count]>0){
            NSMutableDictionary *object = [[NSMutableDictionary alloc]initWithObjects:@[i[@"title"], i[@"id"]] forKeys:@[@"title", @"id"]];
            [albumsListData addObject:object];
        }
    }
    [albumsList reloadData];
}

- (IBAction)deleteAlbum:(id)sender {
   
    [albumsList deselectAll:nil];
    
    NSView *view = [sender superview];
    __block NSInteger index = [albumsList rowForView:view];

    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.deleteAlbum?%@=%@&album_id=%@&access_token=%@&v=%@",  [owner isEqual:_app.person ] ? @"owner_id" : @"group_id",  [owner isEqual:_app.person ] ? owner : [NSString stringWithFormat:@"%i", abs([owner intValue])], albumsListData[index][@"id"], _app.token, _app.version]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *deleteAlbumResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", deleteAlbumResp);
        if(deleteAlbumResp[@"response"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //    NSLog(@"%li", index);
                
                [albumsListData removeObjectAtIndex:index];
             
                [albumsList removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationEffectNone];
                [albumsList reloadData];
            });
        }
    }]resume];
}
-(void)editAudioAlbumName:(NSNotification*)notification{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.editAlbum?album_id=%@&title=%@&access_token=%@&v=%@",notification.userInfo[@"data"][@"id"], [notification.userInfo[@"title"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *editAudioAlbumResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", editAudioAlbumResp);
        if(editAudioAlbumResp[@"response"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSInteger index = [albumsListData indexOfObject:notification.userInfo[@"data"]];
//                NSLog(@"%@", albumsListData[index][@"title"]);
                albumsListData[index][@"title"] = notification.userInfo[@"title"];
                [albumsList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            });
        }
    }]resume];

}

-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"MoveToAlbumList"]){
        MoveListAlbumsViewController *controller = (MoveListAlbumsViewController *)segue.destinationController;
        NSIndexSet *rows;
        rows=[audioList selectedRowIndexes];
        NSMutableArray *selectedTracks=[[NSMutableArray alloc]init];
        controller.owner=owner;
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            [selectedTracks addObject:audioListData[i]];
        }
        controller.recivedAudioTracksData=[[NSMutableArray alloc]initWithArray:selectedTracks];
        controller.recivedAlbumsData=[[NSMutableArray alloc]initWithArray:albumsListData];
    }else if([segue.identifier isEqualToString:@"editAudioAlbumSegue"]){
        EditAudioAlbumViewController *contr = (EditAudioAlbumViewController*)segue.destinationController;
        NSView *view = [sender superview];
        NSInteger row =[albumsList rowForView:view];
        contr.receivedData=albumsListData[row];
        
    }
    else if([segue.identifier isEqualToString:@"createAlbumSegue"]){
        CreateAlbumPopup *contr = (CreateAlbumPopup*)segue.destinationController;
        contr.ownerSelectedInAudioMainContainer=owner;
    }else if([segue.identifier isEqualToString:@"AddAudiosSegue"]){
        AddAudiosViewController *contr = (AddAudiosViewController *)segue.destinationController;
        contr.receivedData = [[NSMutableArray alloc]initWithArray: [self getSelectedItemsInAudioList]];
    }
}
-(NSMutableArray*)getSelectedItemsInAudioList{
    NSMutableArray *items = [[NSMutableArray alloc]init];
    NSIndexSet *rows = [audioList selectedRowIndexes];
    items = [[NSMutableArray alloc]initWithArray:[audioListData objectsAtIndexes:rows]];
    return items;
}
-(void)reloadAlbums:(NSNotification*)notif{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *object = [[NSMutableDictionary alloc]initWithObjects:@[notif.userInfo[@"album_id"],notif.userInfo[@"title"]] forKeys:@[@"id",@"title"]];
        [albumsListData insertObject:object atIndex:2];
        [albumsList insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:2] withAnimation:NSTableViewAnimationEffectNone];
//            [albumsList reloadData];
        NSLog(@"%@", notif.userInfo);
    });

//    [self loadAudioAlbums:nil publicId:owner];
    

}

-(void)viewDidScroll:(NSNotification *)notification{
//    NSLog(@"%@", notification.object);
    if([notification.object isEqual:clipOfAudiolist]){
        NSInteger scrollOrigin = [[audioListScroll contentView]bounds].origin.y+NSMaxY([audioListScroll visibleRect]);
        //    NSInteger numberRowHeights = [audioList numberOfRows] * [audioList rowHeight];
        NSInteger boundsHeight = audioList.bounds.size.height;
        //    NSInteger frameHeight = audioList.frame.size.height;
        //    NSLog(@"%ld", scrollOrigin);
        //    NSLog(@"%lu", boundsHeight);
        
        if (scrollOrigin-1 == boundsHeight) {
            //Refresh here
            //         NSLog(@"The end of table");
            if(searchMode){
                [self searchAudio:1];
            }
            else{
                [self loadAudioList:YES album:nil addTracks:YES fullReload:NO];
            }
        }
    }
}
- (IBAction)moveAction:(id)sender {
    NSIndexSet *rows;
    rows=[audioList selectedRowIndexes];
    NSMutableArray *selectedTracks=[[NSMutableArray alloc]init];;
    for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
        [selectedTracks addObject:audioListData[i][@"id"]];
    }
//    NSLog(@"%@", selectedTracks);
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.moveToAlbum?owner_id=%@&album_id=%@&audio_ids=%@&v=%@&access_token=%@", _app.person, selectedAlbumMoveTo.stringValue,  [selectedTracks componentsJoinedByString:@","], _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *moveDataResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", moveDataResponse);
    }] resume];
}
-(void)loadAudioList:(BOOL)makeOffset album:(id)album addTracks:(BOOL)addTracks fullReload:(BOOL)fullReload{
    [audiosForRestore removeAllObjects];
    restoreAllAudiosBut.hidden=YES;
    removeMultipleAudiosBut.hidden=YES;
    removeMultipleAudiosProgressBar.hidden=YES;
    removeMultipleAudiosLabel.hidden=YES;

    audioList.delegate=self;
    audioList.dataSource=self;
    __block NSString *url;
    __block void (^loadData)(NSInteger offset);
    if(makeOffset){
        offsetLoadAudiolist=offsetLoadAudiolist+[audioListData count];
    }
    else{
        offsetLoadAudiolist=0;
        if([audioList numberOfRows]>0){
//            [audioList removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [audioListData count])] withAnimation:NSTableViewAnimationEffectNone];
//        
            [audioListData removeAllObjects];
//            [audioList reloadData];
        }
      
    }
    owner = owner == nil ? _app.person : owner;
    loadData = ^(NSInteger offset){
        if([album isEqual:@"all"] || fullReload){
            
            currentAlbumLoaded=nil;
            NSLog(@"all");
            url=[NSString stringWithFormat:@"https://api.vk.com/method/audio.get?owner_id=%@&count=100&v=%@&offset=%li&access_token=%@", owner, _app.version, offsetLoadAudiolist, _app.token];
        }
        else if([album isEqual:@"without album"]){
            NSLog(@"without album");
            [audioListData removeAllObjects];
//            currentAlbumLoaded=nil;
            url=[NSString stringWithFormat:@"https://api.vk.com/method/audio.get?owner_id=%@&count=6000&v=%@&offset=%li&access_token=%@", owner, _app.version, offsetLoadAudiolist, _app.token];
        }
        else if(addTracks && !fullReload){
            
            NSLog(@"%@", currentAlbumLoaded);
            if(currentAlbumLoaded){
                url=[NSString stringWithFormat:@"https://api.vk.com/method/audio.get?owner_id=%@&album_id=%@&count=100&v=%@&offset=%li&access_token=%@", owner, currentAlbumLoaded, _app.version, offsetLoadAudiolist, _app.token];
            }
            else{
                 url=[NSString stringWithFormat:@"https://api.vk.com/method/audio.get?owner_id=%@&count=100&v=%@&offset=%li&access_token=%@", owner, _app.version, offsetLoadAudiolist, _app.token];
            }
        }

        else if(!fullReload) {
//            [audioListData removeAllObjects];
            
            currentAlbumLoaded = album;
            url=[NSString stringWithFormat:@"https://api.vk.com/method/audio.get?owner_id=%@&album_id=%@&count=100&v=%@&offset=%li&access_token=%@", owner, album, _app.version, offsetLoadAudiolist, _app.token];
        }
        
//        else{
//            [audioListData removeAllObjects];
//            url=[NSString stringWithFormat:@"https://api.vk.com/method/audio.get?owner_id=%@&count=100&v=%@&offset=%d&access_token=%@", _app.person, _app.version, offset, _app.token];
//        }
//
            [[_app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if(data){
                    NSDictionary *audioGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    
                    if(![album isEqual:@"without album"]){
                        for (NSDictionary *i in audioGetResponse[@"response"][@"items"]){
                            NSMutableDictionary *object = [[NSMutableDictionary alloc]initWithObjects:@[i[@"id"], i[@"artist"], i[@"title"], i[@"duration"], i[@"url"], @0, i[@"owner_id"]] forKeys:@[@"id", @"artist",@"title", @"duration",@"url",@"deleted", @"owner_id"]];
                           
                                [audioListData addObject:object];
                            
//                            [audioListData insertObject:@{@"id":i[@"id"], @"artist":i[@"artist"], @"title":i[@"title"], @"duration":i[@"duration"], @"url":i[@"url"]} atIndex:[audioListData count]-1];
                        }
                    }
                    else{
                        for (NSDictionary *i in audioGetResponse[@"response"][@"items"]){

                            if(![[i allKeys] containsObject:@"album_id"]){
                                NSMutableDictionary *object = [[NSMutableDictionary alloc]initWithObjects:@[i[@"id"], i[@"artist"], i[@"title"], i[@"duration"], i[@"url"], @0, i[@"owner_id"]] forKeys:@[@"id", @"artist",@"title", @"duration",@"url", @"deleted", @"owner_id"]];
//                                NSLog(@"%@", i);
                                [audioListData addObject:object];
                                
//                                [audioListData insertObject:@{@"id":i[@"id"], @"artist":i[@"artist"], @"title":i[@"title"], @"duration":i[@"duration"], @"url":i[@"url"]} atIndex:[audioListData count]-1];
                            }
                        }
                        
                    }
                    //NSLog(@"%lu", [audioListData count]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [progressSpin stopAnimation:self];
//                        if([audioListData count]<200){
                             [audioList reloadData];
//                        }else{
//                            [audioList insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(offsetLoadAudiolist, [audioListData count])] withAnimation:NSTableViewAnimationEffectNone];
//                             [audioList reloadData];
//                        }
                        NSLog(@"%li", [audioListData count]);
                         NSLog(@"%li", offsetLoadAudiolist );
                        [audioList setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
                    });
                }
            }] resume];
     
    };
    loadData(offsetLoadAudiolist);

    
}
-(void)loadAudioAlbums:(NSString *)source publicId:(NSString *)public{
    albumsList.delegate = self;
    albumsList.dataSource = self;
   
    __block int step = 0;

    [albumsListData removeAllObjects];
        
 
    void (^loadAlbums)()=^{
        __block NSString *totalAlbums;
      
        [albumsListData addObject:@{ @"title":@"all"}];
        [albumsListData addObject:@{ @"title":@"without album"}];
        NSURLSessionDataTask *getAlbums1 = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.getAlbums?owner_id=%@&v=%@&access_token=%@&count=5", public, _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(data){
                NSDictionary *jsonData1 = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                totalAlbums=[NSString stringWithFormat:@"%@", jsonData1[@"response"][@"count"]];

                if([totalAlbums intValue] >=1){
                    while (step < [totalAlbums intValue]){
                        NSURLSessionDataTask *getAlbums = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.getAlbums?owner_id=%@&v=%@&access_token=%@&count=100&offset=%d", public, _app.version, _app.token, step]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            for (NSDictionary *i in jsonData[@"response"][@"items"]){
                                
                                NSMutableDictionary *object = [[NSMutableDictionary alloc]initWithObjects:@[i[@"id"],i[@"title"]] forKeys:@[@"id", @"title"]];
                                [albumsListData addObject:object];
                                
                            }
                         
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [albumsList reloadData];
//                                NSTableColumn *column = [[NSTableColumn alloc]initWithIdentifier:@"MainCell"];
                                NSTableColumn *column = [[albumsList tableColumns]firstObject];
                                [column.headerCell setStringValue:[NSString stringWithFormat:@"%@ %li", @"Albums:", [albumsListData count]]];
                                [progressSpin stopAnimation:self];
                            });
                        }];
                        [getAlbums resume];
                        step+=100;
                        usleep(500000);
                        
                    }
                
                }
                
                else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [albumsList reloadData];
                        
                        [progressSpin stopAnimation:self];
                    });
                    
                }
            }
        }];
        [getAlbums1 resume];
        
    };
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        loadAlbums();
    });
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row;
    NSString *item;
    if([notification.object isEqual:albumsList]){
        searchMode=NO;
        if([[albumsList selectedRowIndexes]count]>0){
            row = [albumsList selectedRow];
            item = [NSString stringWithFormat:@"%@", albumsListData[row][@"id"]];
            if([[albumsList selectedRowIndexes]count]>1){
                removeMultipleAlbumsBut.hidden=NO;
                removeAudiosInAlbumCheck.hidden=NO;
            }else{
                removeMultipleAlbumsBut.hidden=YES;
                removeAudiosInAlbumCheck.hidden=YES;
                if(row == 0){
                    item=@"all";
                    [progressSpin startAnimation:self];
                    [self loadAudioList:NO album:item addTracks:NO fullReload:YES];
                }
                else if(row==1) {
                    item = @"without album";
                    [progressSpin startAnimation:self];
                    //            selectedAlbumMoveTo.stringValue = item;
                    [self loadAudioList:NO album:item addTracks:NO fullReload:NO];
                }
                else{
                    selectedAlbumMoveTo.stringValue = item;
                    [progressSpin startAnimation:self];
                    item = [NSString stringWithFormat:@"%@", albumsListData[row][@"id"]];
                    [self loadAudioList:NO album:item addTracks:NO fullReload:NO];
                    
                }
                NSTableColumn *column = [[audioList tableColumns]firstObject];
                
                [column.headerCell setStringValue:[NSString stringWithFormat:@"%@ %@", @"Audios:", albumsListData[row][@"title"]]];
            }
            
        }
        
        
    }else{
        if([[audioList selectedRowIndexes] count] > 1){
            
            removeMultipleAudiosBut.hidden=NO;
           
        }else{
            
            removeMultipleAudiosBut.hidden=YES;
            
        }
    }
    
}
-(void)reArrange:(NSMutableArray *)array sourceNum:(NSInteger)sourceNum destNum:(NSInteger)destNum {
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.reorder?audio_id=%@&before=%@&access_token=%@&v=%@", audioListData[sourceNum][@"id"], audioListData[destNum][@"id"], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *audioReorderResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", audioReorderResp);
        if(audioReorderResp[@"response"]){
            
        }
    }]resume];
    [audioListData insertObject:audioListData[sourceNum] atIndex:destNum];
    NSInteger index;

    if (sourceNum < destNum) {
        index=sourceNum;
        [audioListData removeObjectAtIndex:sourceNum];
    } else {
        index=sourceNum+1;
        [audioListData removeObjectAtIndex:sourceNum+1];
    }

    [audioList reloadData];
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([tableView isEqual:albumsList]){
        if([albumsListData count]>0){
            return [albumsListData count];
        }
    }
    else if([tableView isEqual:audioList]){
        if([audioListData count]>0){
            return [audioListData count];
        }
    }
    return 0;
}


//-(id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row{
//    return audioListData[row];
//}
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    if(tv==audioList){
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
        [pboard declareTypes:[NSArray arrayWithObject:@"NSMutableArray"] owner:self];
        [pboard setData:data forType:@"NSMutableArray"];
        sourceIndex = [rowIndexes firstIndex];
        return YES;
    }
    return NO;
}
-(NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation{
    if(tableView == audioList){
        return dropOperation == NSTableViewDropAbove;
    }
    return NO;
}
-(BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation{
    if(tableView == audioList){
        [self reArrange:audioListData sourceNum:sourceIndex destNum:row]; // let the source array reflect the change
        return YES;
    }
    return NO;
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([tableView isEqual:albumsList]){
        if([albumsListData count]>0){
        
            NSString *title = albumsListData[row][@"title"];
            AudioAlbumsListCustomCell *cell = [[AudioAlbumsListCustomCell alloc]init];
            cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
//            if(row == 0 || row == 1){
//                [cell.editItem removeFromSuperview];
//                [cell.deleteItem removeFromSuperview];
//            }
            [ cell.itemTitle setStringValue:[title stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]];
            return cell;
        }
        
    }
    else if([tableView isEqual:audioList]){
        if([audioListData count]>0){
            AudioListCustomCell *cell = [[AudioListCustomCell alloc]init];
            cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
            
            [ cell.itemTitle setStringValue:[NSString stringWithFormat:@"%@ - %@", audioListData[row][@"artist"], audioListData[row][@"title"]]];
            NSInteger elapsedTimeSeconds;
            NSInteger elapsedTimeMinutes;
            NSInteger elapsedTimeHours;
            NSInteger duration = [audioListData[row][@"duration"] intValue];
            elapsedTimeSeconds = duration % 60;
            elapsedTimeMinutes = (duration / 60) % 60;
            elapsedTimeHours = ((duration / 60) / 60) % 60;
            if(elapsedTimeSeconds<10){
                cell.time.stringValue = [NSString stringWithFormat:@"%@%@:0%ld", elapsedTimeHours > 0 ? [NSString stringWithFormat:@"%ld:", elapsedTimeHours]: @"", elapsedTimeMinutes < 10 ? [NSString stringWithFormat:@"0%ld", elapsedTimeMinutes] :[NSString stringWithFormat:@"%ld", elapsedTimeMinutes] , elapsedTimeSeconds];
            }
            else{
                cell.time.stringValue = [NSString stringWithFormat:@"%@%@:%ld",elapsedTimeHours > 0 ? [NSString stringWithFormat:@"%ld:", elapsedTimeHours]: @"" , elapsedTimeMinutes < 10 ? [NSString stringWithFormat:@"0%ld", elapsedTimeMinutes] :[NSString stringWithFormat:@"%ld", elapsedTimeMinutes], elapsedTimeSeconds];
            }
            if([audioListData[row][@"deleted"] intValue]==1){
                cell.restore.hidden=NO;
            }else{
                cell.restore.hidden=YES;
            }
            return cell;
        }
    }
    return nil;
}
@end
