//
//  ViewController.m
//  vkapp
//
//  Created by sim on 19.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "ViewController.h"
#import "ApiSourceSelectorItem.h"
#import <Quartz/Quartz.h>
#import "CustomView.h"
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedItem=0;
    apiSourceListData = @[@"Vkontakte", @"Youtube", @"Twitter", @"Tumblr", @"Instagram"];
    apiSourceSelectorCollectionView.delegate=self;
    apiSourceSelectorCollectionView.dataSource=self;
    apiSourceSelectorCollectionView.content=apiSourceListData;
    apiSourceSelectorCollectionView.wantsLayer=YES;
    [apiSourceSelectorCollectionView reloadData];
//    self.view.wantsLayer=YES;
//    apiSelectorScrollview.wantsLayer=YES;
    
    apiSelectorScrollview.borderType=0;

    apiSelectorScrollview.drawsBackground=NO;

    NSView *border = [[NSView alloc]init];
    NSView *backG = [[NSView alloc]init];
    border.wantsLayer=YES;
    backG.wantsLayer=YES;
    border.layer.backgroundColor = [[NSColor colorWithWhite:0.6 alpha:1.0]CGColor];
    backG.layer.backgroundColor = [[NSColor colorWithWhite:0.8 alpha:1.0]CGColor];
//    [border setAutoresizingMask:NSConst
//    border.translatesAutoresizingMaskIntoConstraints = YES;
    border.layer.autoresizingMask=NSViewWidthSizable;
    backG.layer.autoresizingMask=NSViewWidthSizable;
    border.frame = NSMakeRect(0, apiSelectorScrollview.frame.size.height-1, apiSelectorScrollview.frame.size.width, 1.0);
    backG.frame  = NSMakeRect(0, 0, apiSelectorScrollview.frame.size.width, apiSelectorScrollview.frame.size.height-1);
    [apiSelectorScrollview addSubview:border positioned:NSWindowBelow relativeTo:apiSelectorScrollview];
    [apiSelectorScrollview addSubview:backG positioned:NSWindowBelow relativeTo:apiSelectorScrollview];
    
   
    
      [self setDefaultSelectedAPISource];
  
//    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:backG.frame];
//    vibrantView.material=NSVisualEffectMaterialTitlebar;
//    vibrantView.blendingMode=NSVisualEffectBlendingModeBehindWindow;
//    //    vibrantView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
//    //    vibrantView.wantsLayer=YES;
//    //    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
//    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
//
//    [backG addSubview:vibrantView positioned:NSWindowBelow relativeTo:backG];

    
//    [self setDefaultSelectedAPISource];
}

-(void)setDefaultSelectedAPISource{
  
    [apiSourceSelectorCollectionView setSelectionIndexes:[NSIndexSet indexSetWithIndex:selectedItem]];
 
 
}

-(void)viewDidLayout{
    
        [apiSourceSelectorCollectionView reloadData];
        [apiSourceSelectorCollectionView setSelectionIndexes:[NSIndexSet indexSetWithIndex:selectedItem]];
    
}


-(void)viewDidAppear{
    self.view.window.titleVisibility=NSWindowTitleHidden;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    self.view.window.movableByWindowBackground=YES;
   
    _VKKeyHandler = [[keyHandler alloc]init];
    _twitterRWD = [[TwitterRWData alloc]init];
    _youtubeRWD = [[YoutubeRWData alloc]init];
    _tumblrRWD = [[TumblrRWData alloc]init];
    _instaRWD  = [[InstagramRWD alloc]init];
    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:apiSourceSelectorCollectionView.frame];
    vibrantView.material=NSVisualEffectMaterialSidebar;
    
    vibrantView.blendingMode=NSVisualEffectBlendingModeBehindWindow;
    
    
    //    vibrantView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    //    vibrantView.wantsLayer=YES;
//    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
//    [apiSourceSelectorCollectionView addSubview:vibrantView positioned:NSWindowBelow relativeTo:apiSourceSelectorCollectionView];
//    if (![_VKKeyHandler VKTokensEcxistsInCoreData]){
//        [ApiSourceSelector setEnabled:NO forSegment:0];
//    }
//    else if(![_twitterRWD TwitterTokensEcxistsInCoreData]){
//        [ApiSourceSelector setEnabled:NO forSegment:2];
//    }
//    else if(![_youtubeRWD YoutubeTokensEcxistsInCoreData]){
//        [ApiSourceSelector setEnabled:NO forSegment:1];
//    }
//    else if(![_tumblrRWD TumblrTokensEcxistsInCoreData]){
//        [ApiSourceSelector setEnabled:NO forSegment:3];
//    }
//    else if(![_instaRWD InstagramTokensEcxistsInCoreData]){
//        [ApiSourceSelector setEnabled:NO forSegment:4];
//    }
//    if(ApiSourceSelector.selectedSegment==0){
//        
//        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectVKApi" object:nil];
//    }
    
//    else if(ApiSourceSelector.selectedSegment==3){
//        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectTumblrApi" object:nil];
//    }
}


//- (void)setRepresentedObject:(id)representedObject {
//    [super setRepresentedObject:representedObject];
//   
//    // Update the view, if already loaded.
//}
- (IBAction)ApiSourceSelect:(id)sender {
//    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
//    
//    NSViewController *contr = [story instantiateControllerWithIdentifier:@"MainController"];
//    NSLog(@"%@", contr.childViewControllers);
//    [[contr.view subviews][0] removeFromSuperview];
//    [contr removeFromParentViewController];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveMainController" object:nil];
//    [contr removeChildViewControllerAtIndex:0];
//    [contr removeFromParentViewController];
//    [contr.view removeFromSuperview];
//    NSLog(@"%li", ApiSourceSelector.selectedSegment);
//    switch(ApiSourceSelector.selectedSegment){
//        case 0:
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectVKApi" object:nil];
//            break;
//        case 1:
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectYoutubeApi" object:nil];
//            break;
//        case 2:
//             [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectTwitterApi" object:nil];
//            break;
//        case 3:
//             [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectTumblrApi" object:nil];
//            break;
//        case 4:
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectInstagramApi" object:nil];
//            break;
//            
//    }

}

-(void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    NSInteger selectedSource = [indexPaths allObjects][0].item;
    selectedItem = selectedSource;
//    NSRect selectedSourceFrame = [collectionView itemAtIndexPath:[indexPaths allObjects][0]].view.frame;
//    ApiSourceSelectorItem *item = (ApiSourceSelectorItem*)[collectionView itemAtIndexPath:[indexPaths allObjects][0]];
    
//    NSLog(@"%f", selectedSourceFrame.origin.x);
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"redrawBorderLine" object:nil userInfo:@{@"rect":[NSValue valueWithRect: selectedSourceFrame]}];
    switch (selectedSource){
        case 0:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectVKApi" object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"loadProfileImage" object:nil userInfo:@{@"source":@"vk"}];
            break;
        case 1:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectYoutubeApi" object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"loadProfileImage" object:nil userInfo:@{@"source":@"youtube"}];
            break;
        case 2:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectTwitterApi" object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"loadProfileImage" object:nil userInfo:@{@"source":@"twitter"}];
            break;
        case 3:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectTumblrApi" object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"loadProfileImage" object:nil userInfo:@{@"source":@"tumblr"}];
            break;
        case 4:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectInstagramApi" object:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"loadProfileImage" object:nil userInfo:@{@"source":@"instagram"}];
            break;
            
    }
//    [collectionView deselectItemsAtIndexPaths:indexPaths];
}
-(NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return NSMakeSize((collectionView.frame.size.width/[apiSourceListData count]), 24);
}

-(NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [apiSourceListData count];
}
-(NSCollectionViewItem*)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    ApiSourceSelectorItem *item = (ApiSourceSelectorItem*)[collectionView makeItemWithIdentifier:@"ApiSourceSelectorItem" forIndexPath:indexPath];
    item.sourceName.stringValue = apiSourceListData[indexPath.item];
    return item;
}
@end
