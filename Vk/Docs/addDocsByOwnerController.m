//
//  addDocsByOwnerController.m
//  MasterAPI
//
//  Created by sim on 17.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "addDocsByOwnerController.h"

@interface addDocsByOwnerController ()

@end

@implementation addDocsByOwnerController

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    userGroupsByAdminData = [[NSMutableArray alloc]init];
    [userGroupsByAdmin removeAllItems];
    [userGroupsByAdmin addItemWithTitle:@"Personal"];
    [userGroupsByAdminData addObject:_app.person];
    [self loadUserGroupsByAdmin];
}
-(void)loadUserGroupsByAdmin{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
                [userGroupsByAdminData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [userGroupsByAdmin addItemWithTitle:i[@"name"]];
                });
                
                
            }
        }]resume];
    });
}
- (IBAction)userGroupsByAdminSelect:(id)sender {
    targetOwner = userGroupsByAdminData[[userGroupsByAdmin indexOfSelectedItem]];
}
- (IBAction)add:(id)sender {
    
    NSLog(@"%@", _receivedData);
   
}
- (IBAction)closeWindow:(id)sender {
    [self dismissController:self];
}

@end
