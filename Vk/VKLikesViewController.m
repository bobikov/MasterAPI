//
//  VKLikesViewController.m
//  MasterAPI
//
//  Created by sim on 14/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "VKLikesViewController.h"
#import "VKLikesCellTableView.h"
#import <UIView+WebCache.h>
#import <UIImageView+WebCache.h>
@interface VKLikesViewController ()<NSTableViewDelegate,NSTableViewDataSource>

@end

@implementation VKLikesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    app = [[appInfo alloc]init];
    likedUsersList.delegate=self;
    likedUsersList.dataSource=self;
    usersListData = [[NSMutableArray alloc]init];
    dismiss.font=[NSFont fontWithName:@"Pe-icon-7-stroke" size:30];
    dismiss.title=@"\U0000E680";
    NSLog(@"%@", _receivedData);
    [self loadLikedUsers];
    
}
-(void)loadLikedUsers{
    [app getLikedPhotoUsersInfo:_receivedData :^(NSMutableArray * _Nonnull fullObjectLikedPhotoUsers){
        if([fullObjectLikedPhotoUsers count]){
            usersListData = fullObjectLikedPhotoUsers;
            dispatch_async(dispatch_get_main_queue(),^{
                [likedUsersList reloadData];
            });
        }
    }];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([usersListData count]){
        return [usersListData count];
    }
    return 0;
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    VKLikesCellTableView *cell = (VKLikesCellTableView*)[tableView makeViewWithIdentifier:@"MainCell" owner:self];

    [cell.photo sd_setImageWithURL:[NSURL URLWithString:usersListData[row][@"user_photo"]] placeholderImage:nil options:SDWebImageRefreshCached completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        image.size = NSMakeSize(100,100);
        cell.photo.image = image;
    }];
    cell.photo.wantsLayer=YES;
    cell.photo.layer.masksToBounds=YES;
    cell.photo.layer.cornerRadius=50/2;
    cell.fullName.stringValue = usersListData[row][@"full_name"];
    
    
    return cell;
}
@end
