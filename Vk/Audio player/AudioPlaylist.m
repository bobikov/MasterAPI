//
//  AudioPlaylist.m
//  vkapp
//
//  Created by sim on 05.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "AudioPlaylist.h"

@interface AudioPlaylist ()<NSTableViewDataSource, NSTableViewDelegate,NSOutlineViewDataSource, NSOutlineViewDelegate, NSSearchFieldDelegate, NSPopoverDelegate>

@end

@implementation AudioPlaylist

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    playList.delegate = self;
    playList.dataSource = self;
    searchAudioBar.delegate = self;
    outlineAudioPlayer.delegate=self;
    outlineAudioPlayer.dataSource=self;
    
    playListData = [[NSMutableArray alloc]init];
    _childrenDictionary = [[NSMutableDictionary alloc]init];
    [self loadAudioPlaylist:NO];
    [[audioScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    myAlbumsData = [[NSMutableArray alloc]init];
    _topLevelItems = [NSArray arrayWithObjects:@"My audio",@"Recomendations", @"My albums", nil];
   
    [outlineAudioPlayer reloadData];
}

- (BOOL)popoverShouldClose:(NSPopover *)popover{
    return YES;
}
- (void)viewDidScroll:(NSNotification *)notification{
    if(notification.object == playlistClip){
        NSInteger scrollOrigin = [[audioScrollView contentView]bounds].origin.y+NSMaxY([audioScrollView visibleRect]);
        //    NSInteger numberRowHeights = [playList numberOfRows] * [playList rowHeight];
        NSInteger boundsHeight = playList.bounds.size.height;
        //    NSInteger frameHeight = playList.frame.size.height;
        if (scrollOrigin == boundsHeight) {
            //Refresh here
            //         NSLog(@"The end of table");
            if(!albumLoaded){
                
                [self loadAudioPlaylist:YES];
                
            }
            if(searchActive){
                [self loadSearchResults:YES];
            }
            
        }
    }
    //    NSLog(@"%ld", scrollOrigin);
    //    NSLog(@"%ld", boundsHeight);
    //    NSLog(@"%fld", frameHeight-300);
    //
}
- (void)loadSelectedAlbum:(id)albumId{
    albumLoaded=YES;
    [playListData removeAllObjects];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.get?owner_id=%@&album_id=%@&count=1000&access_token=%@&v=%@", _app.person, albumId, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *getAudioByAlbumResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for (NSDictionary *i in getAudioByAlbumResp[@"response"][@"items"]){
                [playListData addObject:@{@"artist":i[@"artist"], @"title":i[@"title"], @"duration":i[@"duration"], @"url":i[@"url"]}];
                
            }
            NSLog(@"%lu", [playListData count]);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [playList reloadData];
            });
        }
    }]resume];
}
- (void)loadMyAlbums{
    [myAlbumsData removeAllObjects];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.getAlbums?owner_id=%@&v=%@&access_token=%@&count=100", _app.person, _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(data){
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            for(NSDictionary *i in jsonData[@"response"][@"items"]){
                [myAlbumsData addObject:@{@"title":i[@"title"], @"id":i[@"id"]}];
                
            }
            [_childrenDictionary setObject:[NSArray arrayWithArray:myAlbumsData] forKey:@"My albums"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [outlineAudioPlayer expandItem:nil expandChildren:YES];
                [outlineAudioPlayer reloadData];
                //            NSLog(@"%@", myAlbumsData);
            });
        }
    }]resume];
    
}
- (IBAction)playAction:(id)sender {
    NSView *parentCell = [sender superview];
    NSInteger row = [playList rowForView:parentCell];
//    NSLog(@"Send play here");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayPause" object:nil userInfo:@{@"playlist":playListData, @"row":[NSString stringWithFormat:@"%lu", row]}];
  
    
}
- (void)searchFieldDidStartSearching:(NSSearchField *)sender{
    playListDataCopy = [[NSMutableArray alloc]initWithArray:playListData];
    [playListData removeAllObjects];
    [self loadSearchResults:NO];
}
- (void)loadSearchResults:(BOOL)offset{
    searchActive = YES;
      albumLoaded=NO;
    offsetStep = offset ? offsetStep+100 : 0;
    
    NSString *searchString = [searchAudioBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.search?q=%@&search_own=0&count=100&offset=%i&access_token=%@&v=%@", searchString, offsetStep, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *audioSearchResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *i in audioSearchResp[@"response"][@"items"]){
            [playListData addObject:@{@"artist":i[@"artist"], @"title":i[@"title"], @"duration":i[@"duration"], @"url":i[@"url"]}];
            
        }
        NSLog(@"%lu", [playListData count]);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [playList reloadData];
        });
        
    }]resume];
}
- (void)searchFieldDidEndSearching:(NSSearchField *)sender{
    searchActive = NO;
    playListData = playListDataCopy;
    [playList reloadData];
}

- (id)timeConvert:(NSInteger)seconds{
    NSInteger elapsedTimeSeconds;
    NSInteger elapsedTimeMinutes;
    NSInteger elapsedTimeHours;
    elapsedTimeSeconds = seconds % 60;
    elapsedTimeMinutes = (seconds / 60) % 60;
    elapsedTimeHours = ((seconds / 60) / 60) % 60;
    NSString *time;
    if(elapsedTimeSeconds<10){
        time = [NSString stringWithFormat:@"%@%@:0%ld", elapsedTimeHours > 0 ? [NSString stringWithFormat:@"%ld:", elapsedTimeHours]: @"", elapsedTimeMinutes < 10 ? [NSString stringWithFormat:@"0%ld", elapsedTimeMinutes] :[NSString stringWithFormat:@"%ld", elapsedTimeMinutes] , elapsedTimeSeconds];
    }
    else{
        time = [NSString stringWithFormat:@"%@%@:%ld",elapsedTimeHours > 0 ? [NSString stringWithFormat:@"%ld:", elapsedTimeHours]: @"" , elapsedTimeMinutes < 10 ? [NSString stringWithFormat:@"0%ld", elapsedTimeMinutes] :[NSString stringWithFormat:@"%ld", elapsedTimeMinutes], elapsedTimeSeconds];
    }
    return time;
}
- (void)loadAudioPlaylist:(BOOL)makeOffset{
    albumLoaded=NO;
    __block void (^loadData)(int offset);
    if(makeOffset){
        offsetLoadPlylist=offsetLoadPlylist+100;
    }else{
        offsetLoadPlylist=0;
        [playListData removeAllObjects];
    }
    loadData = ^(int offset){
       
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.get?owner_id=%@&count=100&v=%@&offset=%d&access_token=%@", _app.person, _app.version, offset, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *audioGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                for (NSDictionary *i in audioGetResponse[@"response"][@"items"]){
                    [playListData addObject:@{@"artist":i[@"artist"], @"title":i[@"title"], @"duration":i[@"duration"], @"url":i[@"url"]}];
                    
                }
                NSLog(@"%lu", [playListData count]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [playList reloadData];
                });
            }
        }] resume];
    };
    loadData(offsetLoadPlylist);

}
- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([tableView isEqual:playList]){
        if([playListData count]>0){
            return [playListData count];
        }
    }
  
    return 0;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([tableView isEqual:playList]){
        if([playListData count]>0){
            CustomAudioPlayerCell *cell = [[CustomAudioPlayerCell alloc]init];
            cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
            cell.title.stringValue = [NSString stringWithFormat:@"%@ - %@", playListData[row][@"artist"], playListData[row][@"title"]];
            cell.duration.stringValue =  [self timeConvert:[playListData[row][@"duration"] intValue] ];
            return cell;
        }
    }
    return nil;
}
- (NSArray *)_childrenForItem:(id)item {
    NSArray *children;
    if (item == nil) {
        children = _topLevelItems;
    } else {
        children = [_childrenDictionary objectForKey:item];
    }
    return children;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return [[self _childrenForItem:item] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([item isEqual:@"My albums"]) {
        //        NSLog(@"%@", item);
        return YES;
    } else {
        return NO;
    }
//    return NO;
}

- (NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return [[self _childrenForItem:item] count];
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [_topLevelItems containsObject:item];
}

-(void) outlineViewSelectionDidChange:(NSNotification *)notification{
    NSString *item;
    NSInteger row;
    NSString *parent;
    row = [outlineAudioPlayer selectedRow];
    item = [outlineAudioPlayer itemAtRow:[outlineAudioPlayer selectedRow]];
    //    NSInteger counterChilds=0;
    //    NSInteger counterParents=0;
    parent = [outlineAudioPlayer parentForItem:[outlineAudioPlayer itemAtRow:[outlineAudioPlayer selectedRow]]];
    //    NSLog(@"%@",parent);
    //    NSLog(@"%lu", [OutlineSidebar selectedRow]);
    NSString *currentElem =item;
    if([currentElem isEqual:@"My albums"]){
        [self loadMyAlbums];
    }
    if([currentElem isEqual:@"My audio"]){
        [self loadAudioPlaylist:NO];
    }
//    NSLog(@"%@", parent);
    if([parent isEqual:@"My albums"]){
        [self loadSelectedAlbum:[outlineAudioPlayer itemAtRow:[outlineAudioPlayer selectedRow]][@"id"]];
        
    }
}

//- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
//    // As an example, hide the "outline disclosure button" for FAVORITES. This hides the "Show/Hide" button and disables the tracking area for that row.
//    if ([item isEqualToString:@"Favorites"]) {
//        return NO;
//    } else {
//        return YES;
//    }
//}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    // For the groups, we just return a regular text view.
    NSTableCellView *cell;
    if ([_topLevelItems containsObject:item]) {
        cell = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        
        NSString *value = item;
        [cell.textField setStringValue:value];
        //        cell.wantsLayer=YES;
        //        [cell.layer setBackgroundColor:[[NSColor whiteColor]CGColor]];
        
        
        
        //        if([value isEqualToString:@"PROFILE"]){
        //            NSImageView *imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(5, 2, 70, 16)];
        //            imageView.wantsLayer = YES;
        //            imageView.layer.cornerRadius = 8;
        //            imageView.layer.masksToBounds = YES;
        //              [cell addSubview:imageView];
        //            [imageView setImage:[NSImage imageNamed:@"profile.png"]];
        //        }
        //        else if([value isEqualToString:@"DIALOGS"]){
        //
        //            NSImageView *imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(5, 2, 70, 18)];
        //
        //            [cell addSubview:imageView];
        //            [imageView setImage:[NSImage imageNamed:@"dialogs.png"]];
        //        }
        //        else if([value isEqualToString:@"VIDEO"]){
        //
        //            NSImageView *imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(5, 2, 70, 18)];
        //
        //            [cell addSubview:imageView];
        //            [imageView setImage:[NSImage imageNamed:@"video.png"]];
        //        }
        //        else if([value isEqualToString:@"AUDIO"]){
        //
        //            NSImageView *imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(5, 2, 70, 18)];
        //
        //            [cell addSubview:imageView];
        //            [imageView setImage:[NSImage imageNamed:@"audio.png"]];
        //        }
        //        else if([value isEqualToString:@"PHOTO"]){
        //
        //            NSImageView *imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(5, 2, 70, 18)];
        //
        //            [cell addSubview:imageView];
        //            [imageView setImage:[NSImage imageNamed:@"photo.png"]];
        //        }
        //        else if([value isEqualToString:@"DOCS"]){
        //
        //            NSImageView *imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(5, 2, 70, 18)];
        //
        //            [cell addSubview:imageView];
        //            [imageView setImage:[NSImage imageNamed:@"docs1.png"]];
        //        }
        //        else{
        //            for(int i = 0; i<[[cell subviews] count]; i++){
        //                if([[cell subviews][i] isKindOfClass:[NSImageView class]]){
        //                    [[cell subviews][i] removeFromSuperview];
        //                    
        //                }
        //            }
        //        }
        
        
        
    } else  {
        cell= [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        
        [cell.textField setStringValue:item[@"title"]];
//        [cell.imageView removeFromSuperview];
        
        // Setup the icon based on our section
    }
    return cell;
}
@end
