//
//  ViewController.h
//  vkapp
//
//  Created by sim on 19.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "keyHandler.h"
#import "TwitterRWData.h"
#import "YoutubeRWData.h"
#import "TumblrRWData.h"
#import "InstagramRWD.h"
@interface ViewController : NSViewController<NSCollectionViewDelegate, NSCollectionViewDataSource,NSCollectionViewDelegateFlowLayout>{
    
    __weak IBOutlet NSCollectionView *apiSourceSelectorCollectionView;
    NSArray *apiSourceListData;
    __weak IBOutlet NSScrollView *apiSelectorScrollview;
//    CALayer *border;
//    CALayer *backG;
    BOOL loaded;
    NSInteger selectedItem;
   
}
@property(nonatomic)keyHandler *VKKeyHandler;
@property(nonatomic)TwitterRWData *twitterRWD;
@property(nonatomic)YoutubeRWData *youtubeRWD;
@property(nonatomic)TumblrRWData *tumblrRWD;
@property(nonatomic)InstagramRWD *instaRWD;
@end

