//
//  CreateAlbumPopup.m
//  vkapp
//
//  Created by sim on 18.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CreateAlbumPopup.h"

@interface CreateAlbumPopup ()

@end

@implementation CreateAlbumPopup

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    _app = [[appInfo alloc]init];
    [userGroupsByAdmin removeAllItems];
    userGroupsByAdminData = [[NSMutableArray alloc]init];
    [userGroupsByAdmin addItemWithTitle:@"Personal"];
    [userGroupsByAdminData addObject:_app.person];
    _owner = _owner == nil ? _app.person : _owner;
    [self loadGroupsByAdmin];
}
-(void)loadGroupsByAdmin{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
                    [userGroupsByAdminData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
                    [userGroupsByAdmin addItemWithTitle:i[@"name"]];
                    
                }
            }]resume];
        });
    });
}
- (IBAction)userGroupsByAdminSelect:(id)sender {
    _owner = userGroupsByAdminData[[userGroupsByAdmin indexOfSelectedItem]];
    NSLog(@"%@", _owner);
    
}

- (IBAction)createAction:(id)sender {
    NSString *albumName = [newAlbumName.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.addAlbum?%@=%@&title=%@&v=%@&access_token=%@", [_owner isEqual:_app.person ]?@"owner_id":@"group_id", [_owner isEqual:_app.person ] ? _owner : [NSString stringWithFormat:@"%i", abs([_owner intValue])] , albumName,  _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *addAlbumResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(addAlbumResponse[@"response"]){
            NSLog(@"New album created. Album Id: %@. Album name: %@", addAlbumResponse[@"response"][@"album_id"], newAlbumName.stringValue);
            if([_owner isEqual:_ownerSelectedInAudioMainContainer]){
                [[NSNotificationCenter defaultCenter]postNotificationName:@"reloadAudioAlbums" object:self userInfo:@{@"album_id":addAlbumResponse[@"response"][@"album_id"],@"title":newAlbumName.stringValue}];
            }
            
        }
        else if(addAlbumResponse[@"error"]){
            NSLog(@"%@:%@", addAlbumResponse[@"error"][@"error_code"], addAlbumResponse[@"error"][@"error_msg"]);
        }
        
    }] resume];
}
@end
