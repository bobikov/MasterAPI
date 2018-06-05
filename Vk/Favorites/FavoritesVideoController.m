//
//  FavoritesVideoController.m
//  MasterAPI
//
//  Created by sim on 05/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import "FavoritesVideoController.h"
#import "moveToAlbumViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ProgressViewController.h"
@interface FavoritesVideoController () <NSCollectionViewDataSource, NSCollectionViewDelegate>

@end

@implementation FavoritesVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    CollectionViewList.delegate = self;
    CollectionViewList.dataSource = self;
    _app = [[appInfo alloc]init];
    itemsList = [[NSMutableArray alloc]init];
    addVideoTo.enabled=NO;
    unlikeBut.enabled=NO;

    [self loadFaveVideo];
}
- (void)viewDidAppear{
  
}
-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    ProgressViewController *contr = (ProgressViewController*)segue.destinationController;
    contr.total = [CollectionViewList.selectionIndexes count];
    
}

- (void)loadFaveVideo{
    [itemsList removeAllObjects];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/fave.getVideos?count=600&access_token=%@&v=%@", _app.token,_app.version]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data){
            NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for (NSDictionary *i in obj[@"response"][@"items"] ){
//                NSLog(@"%@", i);
                [itemsList addObject:i];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [CollectionViewList setContent:itemsList];
                [CollectionViewList reloadData];
            });
        }
    }]resume];
}
- (IBAction)moveToAlbum:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    moveToAlbumViewController *controller = [story instantiateControllerWithIdentifier:@"MoveToAlbumPopup"];
    //    controller.videoId=self.representedObject[@"id"];
    controller.selectedItems =  [[NSMutableArray alloc] initWithArray:[CollectionViewList.content objectsAtIndexes:[CollectionViewList selectionIndexes]]];
    controller.type = @"video";
    controller.mediaType = @"video";

    
    [self presentViewControllerAsSheet:controller];
    
}
- (IBAction)unlike:(id)sender {
   NSMutableArray *selectedItems =  [[NSMutableArray alloc] initWithArray:[CollectionViewList.content objectsAtIndexes:[CollectionViewList selectionIndexes]]];
    for (NSDictionary *i in selectedItems){
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/likes.delete?type=video&item_id=%@&owner_id=%@&access_token=%@&v=%@", i[@"id"], i[@"owner_id"], _app.token, _app.version]]]resume];
        
    }
}

-(NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [itemsList count];
}
- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    addVideoTo.enabled = [collectionView.selectionIndexes count] ? YES : NO;
    unlikeBut.enabled = [collectionView.selectionIndexes count] ? YES : NO;
}

-(void)collectionView:(NSCollectionView *)collectionView didDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    addVideoTo.enabled = [collectionView.selectionIndexes count] ? YES : NO;
    unlikeBut.enabled = [collectionView.selectionIndexes count] ? YES : NO;
    NSLog(@"%li", [collectionView.selectionIndexes count]);
}
-(NSCollectionViewItem*)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    
    FaveVideoControllerViewItem *item1 = (FaveVideoControllerViewItem*)[collectionView makeItemWithIdentifier:@"FaveVideoControllerViewItem" forIndexPath:indexPath];
    [item1.thumb sd_setImageWithURL:[NSURL URLWithString:[itemsList objectAtIndex:indexPath.item][@"photo_130"]] placeholderImage:nil options:SDWebImageRefreshCached completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        item1.thumb.image = image;
    }];
    return item1;

}
@end
