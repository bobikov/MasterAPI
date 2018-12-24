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
@synthesize myWindowContr;
- (void)viewDidLoad {
    [super viewDidLoad];
    CollectionViewList.delegate = self;
    CollectionViewList.dataSource = self;
    _app = [[appInfo alloc]init];
    itemsList = [[NSMutableArray alloc]init];
   
    
}
- (void)setButtonsState{
    addPhotoTo.enabled = [CollectionViewList.selectionIndexes count] ? YES : NO;
    unlikeBut.enabled = [CollectionViewList.selectionIndexes count] ? YES : NO;
    addToSavedBut.enabled = [CollectionViewList.selectionIndexes count] ? YES : NO;
}
- (void)viewDidAppear{
    [self setButtonsState];
    [self loadFavePhoto];
}
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    NSMutableArray *selectedItems =  [[NSMutableArray alloc] initWithArray:[CollectionViewList.content objectsAtIndexes:[CollectionViewList selectionIndexes]]];
    ProgressViewController *contr = (ProgressViewController*)segue.destinationController;
    contr.total = [CollectionViewList.selectionIndexes count];
    contr.items = [[NSMutableArray alloc] initWithArray:selectedItems];
    contr.mediaType = @"photo";
    if(sender == addToSavedBut){
        contr.savePhotoToSaved=YES;
    }
}
- (void)addToSavedAlbum{
    
}
- (void)loadFavePhoto{
   
    [itemsList removeAllObjects];
    [CollectionViewList setContent:itemsList];
    [CollectionViewList reloadData];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/fave.getPhotos?count=1000&offset=0&access_token=%@&v=%@", _app.token,_app.version]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data){
                NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                NSLog(@"%@", obj);
                for (NSDictionary *i in obj[@"response"][@"items"] ){
                    //  NSLog(@"%@", i);
                    NSString *bigPhoto;
                    NSString *likesCount = @"";
                    NSString *userLikesCount = @"";
                    NSString *prPhoto;
                    for (NSDictionary *a in i[@"sizes"]){
                        if([a[@"type"] isEqual:@"y"]){
                            bigPhoto = a[@"url"];
                        }
                        else if([a[@"type"] isEqual:@"x"] && !bigPhoto){
                            bigPhoto = a[@"url"];
                        }
                        else if([a[@"type"] isEqual:@"o"]){
                            prPhoto = a[@"url"];
                        }
//                        NSLog(@"%@", a);
                    }
//                    NSLog(@"bigPhoto:%@\nprPhoto:%@", bigPhoto, prPhoto);
                    NSMutableDictionary *object = [NSMutableDictionary dictionaryWithDictionary:@{@"title": @"",  @"owner_id":_app.person, @"items":[NSMutableDictionary dictionaryWithDictionary:@{@"owner_id":i[@"owner_id"], @"index":[NSNumber numberWithInteger:[obj[@"response"][@"items"] indexOfObject:i]+1], @"id":i[@"id"], @"photo":prPhoto, @"photoBig":bigPhoto, @"caption":i[@"text"], @"likesCount":likesCount, @"userLikes":userLikesCount}]}];
                    NSLog(@"%@", object);
                    [itemsList addObject:object];
    //
    //            }
                   
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
//    controller.savePhotoToSaved=YES;
    controller.selectedItems =  [[NSMutableArray alloc] initWithArray:[itemsList objectsAtIndexes:[CollectionViewList selectionIndexes]]];
    controller.type = @"photo";
    controller.mediaType = @"photo";
    
   
    [self presentViewControllerAsSheet:controller];
    
}
- (IBAction)unlike:(id)sender {
    
    
}


- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [itemsList count];
}
- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    NSEvent *currentEvent = [NSApp currentEvent];
    [self setButtonsState];
    NSLog(@"Selected count: %li", [collectionView.selectionIndexes count]);
    NSLog(@"Selection indexes:%@", collectionView.selectionIndexes );
    sleep(1);
    if(!([currentEvent modifierFlags] & NSCommandKeyMask) && [collectionView.selectionIndexes count]==1){
        NSStoryboard *board1 = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        myWindowContr = [board1 instantiateControllerWithIdentifier:@"PhotoController"];
        [myWindowContr showWindow:self];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowPhotoSlider" object:nil userInfo:@{@"data":itemsList, @"current":[[collectionView itemAtIndexPath:[indexPaths allObjects][0]] representedObject][@"items"][@"index"]}];
        [collectionView deselectItemsAtIndexPaths:indexPaths];
        NSLog(@"Open photo slider");
    }
}

- (void)collectionView:(NSCollectionView *)collectionView didDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    [self setButtonsState];
    NSLog(@"%li", [collectionView.selectionIndexes count]);
}
- (NSCollectionViewItem*)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    
    FavePhotoCollectionViewItem *item1 = (FavePhotoCollectionViewItem*)[collectionView makeItemWithIdentifier:@"FavePhotoCollectionViewItem" forIndexPath:indexPath];
    [item1.thumb sd_setImageWithURL:[NSURL URLWithString:[itemsList objectAtIndex:indexPath.item][@"items"][@"photo"]] placeholderImage:nil options:SDWebImageRefreshCached completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        NSImageRep *rep = [[image representations] objectAtIndex:0];
        NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
        image.size = imageSize;
        item1.thumb.image = image;
    }];
    return item1;
    
}
@end
