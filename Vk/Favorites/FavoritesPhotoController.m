//
//  FavoritesPhotoController.m
//  MasterAPI
//
//  Created by sim on 10/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import "FavoritesPhotoController.h"
#import "moveToAlbumViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ProgressViewController.h"
@interface FavoritesPhotoController ()<NSCollectionViewDataSource, NSCollectionViewDelegate>


@end

@implementation FavoritesPhotoController

- (void)viewDidLoad {
    [super viewDidLoad];
    CollectionViewList.delegate = self;
    CollectionViewList.dataSource = self;
    _app = [[appInfo alloc]init];
    itemsList = [[NSMutableArray alloc]init];
    addPhotoTo.enabled=NO;
    unlikeBut.enabled=NO;
    
    
}
- (void)viewDidAppear{
    [self loadFavePhoto];
}
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    NSMutableArray *selectedItems =  [[NSMutableArray alloc] initWithArray:[CollectionViewList.content objectsAtIndexes:[CollectionViewList selectionIndexes]]];
    ProgressViewController *contr = (ProgressViewController*)segue.destinationController;
    contr.total = [CollectionViewList.selectionIndexes count];
    contr.items = [[NSMutableArray alloc] initWithArray:selectedItems];
}

- (void)loadFavePhoto{
    [itemsList removeAllObjects];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/fave.getPhotos?count=600&access_token=%@&v=%@", _app.token,_app.version]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
    controller.type = @"photo";
    controller.mediaType = @"photo";
    
    
    [self presentViewControllerAsSheet:controller];
    
}
- (IBAction)unlike:(id)sender {
    
    
}

-(NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [itemsList count];
}
- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    addPhotoTo.enabled = [collectionView.selectionIndexes count] ? YES : NO;
    unlikeBut.enabled = [collectionView.selectionIndexes count] ? YES : NO;
}

-(void)collectionView:(NSCollectionView *)collectionView didDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    addPhotoTo.enabled = [collectionView.selectionIndexes count] ? YES : NO;
    unlikeBut.enabled = [collectionView.selectionIndexes count] ? YES : NO;
    NSLog(@"%li", [collectionView.selectionIndexes count]);
}
-(NSCollectionViewItem*)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    
    FavePhotoCollectionViewItem *item1 = (FavePhotoCollectionViewItem*)[collectionView makeItemWithIdentifier:@"FavePhotoCollectionViewItem" forIndexPath:indexPath];
    [item1.thumb sd_setImageWithURL:[NSURL URLWithString:[itemsList objectAtIndex:indexPath.item][@"photo_130"]] placeholderImage:nil options:SDWebImageRefreshCached completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        NSImageRep *rep = [[image representations] objectAtIndex:0];
        NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
        image.size = imageSize;
        item1.thumb.image = image;
    }];
    return item1;
    
}
@end
