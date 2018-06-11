//
//  FavoritesPhotoController.h
//  MasterAPI
//
//  Created by sim on 10/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FavePhotoCollectionViewItem.h"
#import "appInfo.h"
@interface FavoritesPhotoController : NSViewController{
    __weak IBOutlet NSButton *addPhotoTo;
    __weak IBOutlet NSCollectionView *CollectionViewList;
    NSMutableArray *itemsList;
    __weak IBOutlet NSButton *unlikeBut;
}
@property(nonatomic)appInfo *app;
@end
