//
//  TumblrFollowers.m
//  MasterAPI
//
//  Created by sim on 09.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TumblrFollowers.h"
#import "followersCustomCell.h"
@interface TumblrFollowers ()<NSTableViewDelegate, NSTableViewDataSource>

@end

@implementation TumblrFollowers

- (void)viewDidLoad {
    [super viewDidLoad];
    followersList.dataSource=self;
    followersList.delegate=self;
    _tumblrClient = [[TumblrClient alloc]initWithTokensFromCoreData];
    followersData = [[NSMutableArray alloc]init];
    [self loadFollowers];
}
-(void)loadFollowers{
    [progressLoad startAnimation:self];
    [_tumblrClient APIRequest:@"blog/hfdui2134.tumblr.com" rmethod:@"followers" query:@{@"limit":@20} handler:^(NSData *data) {
        if(data){
            NSDictionary *followersResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", followersResponse);
            for(NSDictionary *i in followersResponse[@"response"][@"users"]){
                NSURL *nurl = [NSURL URLWithString:i[@"url"]];
                
                [followersData addObject:@{@"name":i[@"name"], @"url":nurl.host}];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressLoad stopAnimation:self];
                [followersList reloadData];
            });
        }
    }];
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [followersData count];
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    followersCustomCell *cell = [[followersCustomCell alloc]init];
    cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.name.stringValue = followersData[row][@"name"];
    cell.url.stringValue = followersData[row][@"url"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:followersData[row][@"url"]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.avatar setImage:image];
        });
    });
    
    return cell;
}

@end
