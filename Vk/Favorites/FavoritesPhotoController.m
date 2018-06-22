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
                NSString *bigPhoto;
                NSString *likesCount = @"";
                NSString *userLikesCount = @"";
                if(i[@"photo_807"] && i[@"photo_807"]!=nil ){
                    bigPhoto = i[@"photo_807"];
                }
                else if(i[@"photo_604"] && !i[@"photo_807"]){
                    bigPhoto = i[@"photo_604"];
                }
                else if(!i[@"photo_604"]){
                    bigPhoto = i[@"photo_130"];
                }
                
                NSMutableDictionary *object = [NSMutableDictionary dictionaryWithDictionary:@{@"title": @"",  @"owner_id":_app.person, @"items":[NSMutableDictionary dictionaryWithDictionary:@{@"index":[NSNumber numberWithInteger:[obj[@"response"][@"items"] indexOfObject:i]+1], @"id":i[@"id"], @"photo":i[@"photo_130"]?i[@"photo_130"]:i[@"photo_75"], @"photoBig":bigPhoto, @"caption":i[@"text"], @"likesCount":likesCount, @"userLikes":userLikesCount}]}];
                [itemsList addObject:object];
              
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
    NSEvent *currentEvent = [NSApp currentEvent];
    addPhotoTo.enabled = [collectionView.selectionIndexes count] ? YES : NO;
    unlikeBut.enabled = [collectionView.selectionIndexes count] ? YES : NO;
    
    if(!([currentEvent modifierFlags] & NSCommandKeyMask) && [collectionView.selectionIndexes count]==1){
        NSStoryboard *board1 = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
        myWindowContr = [board1 instantiateControllerWithIdentifier:@"PhotoController"];
        [myWindowContr showWindow:self];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowPhotoSlider" object:nil userInfo:@{@"data":itemsList, @"current":[[collectionView itemAtIndexPath:[indexPaths allObjects][0]] representedObject][@"items"][@"index"]}];
        [collectionView deselectItemsAtIndexPaths:indexPaths];
        NSLog(@"Open photo slider");
    }
}

-(void)collectionView:(NSCollectionView *)collectionView didDeselectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    addPhotoTo.enabled = [collectionView.selectionIndexes count] ? YES : NO;
    unlikeBut.enabled = [collectionView.selectionIndexes count] ? YES : NO;
    NSLog(@"%li", [collectionView.selectionIndexes count]);
}
-(NSCollectionViewItem*)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    
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
