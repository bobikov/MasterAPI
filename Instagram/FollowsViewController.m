//
//  FollowsViewController.m
//  MasterAPI
//
//  Created by sim on 04.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "FollowsViewController.h"
#import "FollowsInstagramCell.h"
#import "HTMLReader.h"
@interface FollowsViewController ()<NSTableViewDelegate, NSTableViewDataSource>

@end

@implementation FollowsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    followsList.delegate=self;
    followsList.dataSource=self;
    instaClient = [[InstagramClient alloc]initWithTokensFromCoreData];
  
  
}
-(void)viewDidAppear{
      [self loadFollows];
}
-(void)loadFollows{
    [instaClient APIRequest:@"users/self/follows" completion:^(NSData *data) {
        if(data){
            NSDictionary *selfFollowsResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", selfFollowsResp);
            dispatch_async(dispatch_get_main_queue(),^{
                
            });
        }
    }];


}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [followListData count];
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    FollowsInstagramCell *cell = [[FollowsInstagramCell alloc]init];
    cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    
    return cell;
}
@end
