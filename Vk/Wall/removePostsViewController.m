//
//  removePostsViewController.m
//  vkapp
//
//  Created by sim on 15.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "removePostsViewController.h"

@interface removePostsViewController ()

@end

@implementation removePostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    groupsPopupData = [[NSMutableArray alloc]init];
    _app = [[appInfo alloc]init];
    [groupsPopupList removeAllItems];
    [groupsPopupList addItemWithTitle:@"Personal"];
    [groupsPopupData addObject:_app.person];
    [self loadGroupsPopup];
}
-(void)loadGroupsPopup{
    
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
            [groupsPopupData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
            [groupsPopupList addItemWithTitle:i[@"name"]];
            
        }
    }]resume];
}
- (IBAction)groupsPopupSelect:(id)sender {
    
    groupsFromPostsRemove = [groupsPopupData objectAtIndex:[groupsPopupList indexOfSelectedItem]];
    
}
- (IBAction)stopRemove:(id)sender {
    
    
    
}
- (IBAction)removePosts:(id)sender {
    
    if([count.stringValue isEqual: @""]){
        totalCountPosts = CountPosts;
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.get?owner_id=%@&count=1&access_token=%@&v=%@", groupsFromPostsRemove, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *getCountResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            totalCountPosts = [getCountResp[@"response"][@"count"] intValue];
        }]resume];
    }else{
       
        totalCountPosts = [count.stringValue intValue];
    }
    sleep(1);
    offset=0;
    url = [NSString stringWithFormat:@"https://api.vk.com/method/wall.get?owner_id=%@&offset=%li&count=1&access_token=%@&v=%@", groupsFromPostsRemove, offset, _app.token, _app.version];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while(offset < totalCountPosts){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *wallGetRespo = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.delete?post_id=%@&owner_id=%@&access_token=%@&v=%@",wallGetRespo[@"response"][@"items"][0][@"id"], wallGetRespo[@"response"][@"items"][0][@"owner_id"], _app.token, _app.version ]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSDictionary *wallDeleteResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@", wallDeleteResponse);
                }]resume];
                
            }]resume];
            offset++;
            sleep(1);
        }
    });
    
}

@end
