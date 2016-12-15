//
//  TwitterFriends.m
//  MasterAPI
//
//  Created by sim on 11.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TwitterFriends.h"
#import "TwitterFriendsCustomCell.h"
@interface TwitterFriends ()<NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate>

@end

@implementation TwitterFriends

- (void)viewDidLoad {
    [super viewDidLoad];
    friendsList.dataSource=self;
    friendsList.delegate=self;
    friendsListData=[[NSMutableArray alloc]init];
    offsetCounter = 0;
    [self loadFriends];
    searchBar.delegate=self;
    
}
- (IBAction)follow:(id)sender {
    NSView *parentView = [sender superview];
    NSInteger row = [friendsList rowForView:parentView];
    NSLog(@"%@", friendsListData[row]);
    NSString *userId = friendsListData[row][@"id"];
//    NSString *screenName = friendsListData[row][@"screen_name"];
    [_twitterClient APIRequest:@"friendships" rmethod:@"create.json" query:@{@"user_id":userId, @"follow":@"true"} handler:^(NSData *data) {
     
        if(data){
            NSDictionary *followUsersResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", followUsersResp);
        }
    }];
}
-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    [self loadSearchResults:NO];
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    friendsListData = friendsListDataCopy;
    [friendsList reloadData];
}
-(void)loadSearchResults:(BOOL)makeOffset{
    friendsListDataCopy = [[NSMutableArray alloc]initWithArray:friendsListData];
    [friendsListData removeAllObjects];
    NSString *searchString = [searchBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    [_twitterClient APIRequest:@"users" rmethod:@"search.json" query:@{@"q":searchString} handler:^(NSData *data) {
        if(data){
            NSDictionary *searchUsersResp = [NSJSONSerialization  JSONObjectWithData:data options:0 error:nil];
//            NSLog(@"%@", searchUsersResp);
            for(NSDictionary *i in searchUsersResp){
                int following = [i[@"following"] intValue];
                [friendsListData addObject:@{@"id":i[@"id"], @"name":i[@"name"], @"desc":i[@"description"], @"photo":[i[@"profile_image_url"] stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"], @"following":[NSNumber numberWithInt:following], @"screen_name":i[@"screen_name"]}];
                //        NSLog(@"%@", i["]);
                offsetCounter++;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                loadedCount.title = [NSString stringWithFormat:@"%i", offsetCounter];
                [progressLoad stopAnimation:self];
                [friendsList reloadData];
            });
            
        }
    }];
}
-(void)loadFriends{
    [progressLoad startAnimation:self];
    _twitterClient = [[TwitterClient alloc]initWithTokensFromCoreData];
    [_twitterClient APIRequest:@"friends" rmethod:@"list.json" query:@{@"count":@200} handler:^(NSData *data) {
        if(data){
            NSDictionary *friendsResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //        NSLog(@"%@", friendsResp);
            for(NSDictionary *i in friendsResp[@"users"]){
                 int following = [i[@"following"] intValue];
                [friendsListData addObject:@{@"id":i[@"id"],@"name":i[@"name"], @"desc":i[@"description"], @"photo":[i[@"profile_image_url"] stringByReplacingOccurrencesOfString:@"normal" withString:@"bigger"],@"following":[NSNumber numberWithInt:following]}];
                //        NSLog(@"%@", i["]);
                offsetCounter++;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                loadedCount.title = [NSString stringWithFormat:@"%i", offsetCounter];
                [progressLoad stopAnimation:self];
                [friendsList reloadData];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressLoad stopAnimation:self];
            });
        }
    }];
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [friendsListData count];
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    TwitterFriendsCustomCell *cell = [[TwitterFriendsCustomCell alloc]init];
    cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.name.stringValue = friendsListData[row][@"name"];
    cell.desc.stringValue = friendsListData[row][@"desc"];
    cell.photo.wantsLayer=YES;
    cell.photo.layer.masksToBounds=YES;
    cell.photo.layer.cornerRadius=64/2;
    if([friendsListData[row][@"following"] intValue]){
        cell.follow.hidden=YES;
    }else{
        cell.follow.hidden=NO;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:friendsListData[row][@"photo"]]];
        image.size=NSMakeSize(64,64);
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.photo setImage:image];
        });
    });
    return cell;
}
@end
