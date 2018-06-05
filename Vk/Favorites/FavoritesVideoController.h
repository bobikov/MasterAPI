//
//  FavoritesVideoController.h
//  MasterAPI
//
//  Created by sim on 05/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FaveVideoControllerViewItem.h"
#import "appInfo.h"
@interface FavoritesVideoController : NSViewController{
    
    __weak IBOutlet NSButton *addVideoTo;
    __weak IBOutlet NSCollectionView *CollectionViewList;
    NSMutableArray *itemsList;
    
}
@property(nonatomic)appInfo *app;
@end
