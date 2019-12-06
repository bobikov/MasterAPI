//
//  FavoritesPostsController.m
//  MasterAPI
//
//  Created by sim on 23/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import "FavoritesPostsController.h"

@interface FavoritesPostsController () <NSTableViewDelegate,NSTableViewDataSource>

@end

@implementation FavoritesPostsController

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    [self getPosts];
    postsData = [[NSMutableArray alloc] init];
    
}
- (void)getPosts{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/fave.getPosts?count=10&access_token=%@&v=%@", _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"%@", obj);
    }]resume];
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    
    return [postsData count];
}

-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    

    return nil;
}

@end
