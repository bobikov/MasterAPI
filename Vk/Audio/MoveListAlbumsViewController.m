//
//  MoveListAlbumsViewController.m
//  vkapp
//
//  Created by sim on 19.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "MoveListAlbumsViewController.h"

@interface MoveListAlbumsViewController ()<NSTableViewDelegate, NSTableViewDataSource>

@end

@implementation MoveListAlbumsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.wantsLayer=YES;
    [self.view.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    albumsListData = [[NSMutableArray alloc]init];
    albumsList.delegate = self;
    albumsList.dataSource = self;
    _app = [[appInfo alloc]init];
    [albumsList reloadData];
}
-(void)viewDidAppear{
    self.view.wantsLayer=YES;
    self.view.layer.masksToBounds=YES;
    self.view.layer.backgroundColor=[[NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:0.0]CGColor];
    

}
-(void)moveAction:(id)selectedAlbum{
    NSMutableArray *selectedTracks = [[NSMutableArray alloc]init];
    for (NSDictionary *i in _recivedAudioTracksData){
        [selectedTracks addObject:i[@"id"]];
    }
    //    NSLog(@"%@", selectedTracks);
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.moveToAlbum?%@=%@&album_id=%@&audio_ids=%@&v=%@&access_token=%@", [_owner isEqual:_app.person ]?@"owner_id":@"group_id", [_owner isEqual:_app.person ] ? _owner : [NSString stringWithFormat:@"%i", abs([_owner intValue])], selectedAlbum,  [selectedTracks componentsJoinedByString:@","], _owner, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *moveDataResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", moveDataResponse);
    }] resume];
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row;
    NSString *item;
    if([notification.object isEqual:albumsList]){
        row = [albumsList selectedRow];
        item = [NSString stringWithFormat:@"%@", _recivedAlbumsData[row][@"id"]];
        [self moveAction:item];
        [self dismissViewController:self];
    }
    
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([_recivedAlbumsData count]>0){
        return [_recivedAlbumsData count];
    }
    return 0;
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([_recivedAlbumsData count]>0){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        [ cell.textField setStringValue:_recivedAlbumsData[row][@"title"]];
        return cell;
    }
    return nil;
}

@end
