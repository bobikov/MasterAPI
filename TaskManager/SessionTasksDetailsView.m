//
//  SessionTasksDetailsView.m
//  MasterAPI
//
//  Created by sim on 24.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "SessionTasksDetailsView.h"
#import "PostAttachmentsCustomItem.h"
#import "SessionTasksDetailsCellView.h"
@interface SessionTasksDetailsView ()<NSTableViewDataSource,NSTableViewDelegate,NSCollectionViewDelegate,NSCollectionViewDataSource>

@end

@implementation SessionTasksDetailsView

- (void)viewDidLoad {
    [super viewDidLoad];
    postsList.delegate=self;
    postsList.dataSource=self;
    postsData = [[NSMutableArray alloc]init];
    postsData = _receivedData[@"data"];
    [postsList reloadData];
    indexURL=0;
    NSLog(@"%@", _receivedData);
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [postsData count];
}
-(void)loadPosts{
    
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    SessionTasksDetailsCellView *cell = (SessionTasksDetailsCellView*)[tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.postAttachments.delegate=self;
    cell.postAttachments.dataSource=self;
    cell.postText.stringValue = postsData[row][@"message"];
    cell.postAttachments.content = postsData[row][@"attach_urls"];
   
    return cell;
}
-(NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [collectionView.content count];
}
-(NSCollectionViewItem*)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    PostAttachmentsCustomItem *item = (PostAttachmentsCustomItem*)[collectionView makeItemWithIdentifier:@"PostAttachmentsCustomItem" forIndexPath:indexPath];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSImage *image = [[NSImage alloc]init];
//            NSString *ph = i[@"data"][@"items"][@"photo"] ? i[@"items"][@"photo"] : i[@"data"][@"photo"]?i[@"data"][@"photo"]:i[@"data"][@"cover"];
            NSString *ph = collectionView.content[indexPath.item][@"data"][@"items"][@"photo"] ;
            image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:ph]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [item.previewItem setImage:image];
            });
            
        });
    return item;
}
@end
