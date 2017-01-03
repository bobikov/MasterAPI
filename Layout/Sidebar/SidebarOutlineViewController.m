//
//  SidebarOutlineViewController.m
//  vkapp
//
//  Created by sim on 21.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "SidebarOutlineViewController.h"

@interface SidebarOutlineViewController ()<NSOutlineViewDataSource, NSOutlineViewDelegate>

@end

@implementation SidebarOutlineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _VKKeyHandler = [[keyHandler alloc]init];
    _twitterRWD = [[TwitterRWData alloc]init];
    _youtubeRWD = [[YoutubeRWData alloc]init];
    _tumblrRWD = [[TumblrRWData alloc]init];
    [OutlineSidebar setDelegate: self];
    [OutlineSidebar setDataSource:self];
    _childrenDictionary=[[NSMutableDictionary alloc]init];
    
    [_VKKeyHandler VKTokensEcxistsInCoreData] ? [self loadVK] : nil;
//    loaded = NO;
//

//    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0.0, 770.0, 183.0, 26.0)];
//    vibrantView.appearance = [NSAppearance
//                              appearanceNamed:NSAppearanceNameVibrantLight];
//    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
//    [self.view addSubview:vibrantView];
//
  
    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:self.view.frame];
    vibrantView.material=NSVisualEffectMaterialSidebar;
    
    vibrantView.blendingMode=NSVisualEffectBlendingModeBehindWindow;
    
    
    //    vibrantView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    //    vibrantView.wantsLayer=YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self.view addSubview:vibrantView positioned:NSWindowBelow relativeTo:self.view];


}

-(void)viewDidAppear{
    
//    self.view.wantsLayer=YES;
//    [self.view.layer setBackgroundColor:[[NSColor blackColor] CGColor]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectVKApi" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectTumblrApi" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectTwitterApi" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectYoutubeApi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SelectYoutubeApi:) name:@"SelectInstagramApi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SelectVKApi:) name:@"SelectVKApi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SelectTumblrApi:) name:@"SelectTumblrApi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SelectTwitterApi:) name:@"SelectTwitterApi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SelectYoutubeApi:) name:@"SelectYoutubeApi" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SelectInstagramApi:) name:@"SelectInstagramApi" object:nil];
//    self.view.window.titleVisibility=NSWindowTitleVisible;
//    self.view.window.titlebarAppearsTransparent = YES;
//    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
//    self.view.window.movableByWindowBackground=NO;
 
//}
//    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
//    [self.view.subviews[0] setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
}
-(void)SelectVKApi:(NSNotification *)notification{
   
   
    [self loadVK];
    
}
-(void)loadVK{
//    NSLog(@"VK API LOAD HERE");
    currentSelectorName = @"vk";
    _topLevelItems = @[@"Profile", @"Friends",  @"Dialogs", @"Status", @"Video", @"Audio", @"Photo",@"Docs", @"Wall", @"Groups", @"Banlist", @"Favorites"];
    
    // The data is stored ina  dictionary. The objects are the nib names to load.
    //    _childrenDictionary = [NSMutableDictionary new];
    
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"copy video", @"privacy video albums", @"show video", nil] forKey:@"Video"];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"copy audio", @"show audio", nil] forKey:@"Audio"];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"copy photo", @"privacy photo albums", @"download photo", @"show photo", nil] forKey:@"Photo"];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"show dialogs", nil] forKey:@"Dialogs"];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"show friends", @"show subscribers", @"show friends outs", nil] forKey:@"Friends"];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"show docs",  nil] forKey:@"Docs"];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"post wall",@"wall posts remove", nil] forKey:@"Wall"];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"change status", nil] forKey:@"Status"];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"profile photo change", nil] forKey:@"Profile"];
    [_childrenDictionary setObject:@[@"show groups"] forKey:@"Groups"];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"in black list?", @"show banned", nil] forKey:@"Banlist"];
    [_childrenDictionary setObject:@[@"show favorites"] forKey:@"Favorites"];
    
    //        NSLog(@"%@", _childrenDictionary);
    [OutlineSidebar reloadData];
    [OutlineSidebar expandItem:nil expandChildren:YES];

}
-(void)SelectTumblrApi:(NSNotification *)notification{
//      NSLog(@"Tumblr API LOAD HERE");
     currentSelectorName = @"tumblr";
    _topLevelItems = @[@"Avatar", @"Following",@"Followers", @"Posts"];
    
    // The data is stored ina  dictionary. The objects are the nib names to load.
//    _childrenDictionary = [NSMutableDictionary new];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"show avatar", nil] forKey:@"Avatar"];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"show following", nil] forKey:@"Following"];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"show followers", nil] forKey:@"Followers"];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"show posts", nil] forKey:@"Posts"];
    
    //    NSLog(@"%@", _childrenDictionary);
    [OutlineSidebar reloadData];
    [OutlineSidebar expandItem:nil expandChildren:YES];

}
-(void)SelectTwitterApi:(NSNotification *)notification{
//    NSLog(@"Twitter API LOAD HERE");
     currentSelectorName = @"twitter";
    _topLevelItems = [NSArray arrayWithObjects: @"Profile", @"Friends", nil];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"show twitter friends", nil] forKey:@"Friends"];
     [_childrenDictionary setObject:[NSArray arrayWithObjects:@"show twitter profile", nil] forKey:@"Profile"];
    [OutlineSidebar reloadData];
    [OutlineSidebar expandItem:nil expandChildren:YES];
}
-(void)SelectYoutubeApi:(NSNotification *)notification{
//     NSLog(@"Youtube API LOAD HERE");
     currentSelectorName = @"youtube";
    _topLevelItems = [NSArray arrayWithObjects: @"Subscriptions", @"Videos", nil];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"show subscriptions", nil] forKey:@"Subscriptions"];
    [_childrenDictionary setObject:[NSArray arrayWithObjects:@"show youtube videos", nil] forKey:@"Videos"];
    [OutlineSidebar reloadData];
    [OutlineSidebar expandItem:nil expandChildren:YES];
}
-(void)SelectInstagramApi:(NSNotification*)notification{
    currentSelectorName = @"instagram";
    _topLevelItems = @[@"Media"];
    [_childrenDictionary setObject:@[@"user media feed", @"show media", @"search media by tag"] forKey:@"Media"];
    
    [OutlineSidebar reloadData];
    [OutlineSidebar expandItem:nil expandChildren:YES];
}
- (NSArray *)_childrenForItem:(id)item {
    NSArray *children;
    if (item == nil) {
        children = _topLevelItems;
    } else {
        children = [_childrenDictionary objectForKey:item];
    }
    return children;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return [[self _childrenForItem:item] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if ([outlineView parentForItem:item] == nil) {
//        NSLog(@"%@", item);
        return YES;
    } else {
        return NO;
    }
}

- (NSInteger) outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return [[self _childrenForItem:item] count];
}

- (BOOL) outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [_topLevelItems containsObject:item];
}

-(void) outlineViewSelectionDidChange:(NSNotification *)notification{
    NSString *item;
    NSInteger row;
    NSString *parent;
    row = [OutlineSidebar selectedRow];
    item = [OutlineSidebar itemAtRow:[OutlineSidebar selectedRow]];
//    NSInteger counterChilds=0;
//    NSInteger counterParents=0;
    parent = [OutlineSidebar parentForItem:[OutlineSidebar itemAtRow:[OutlineSidebar selectedRow]]];
//    NSLog(@"%@",parent);
//    NSLog(@"%lu", [OutlineSidebar selectedRow]);
    NSString *currentElem =item;

    [[NSNotificationCenter defaultCenter] postNotificationName:currentElem object:self userInfo:@{@"currentSelectorName":currentSelectorName}];
//    NSLog(@"%lu", row);
//    item = [OutlineSidebar parentForItem:];

//    for(NSDictionary *i in _childrenDictionary){
//        NSLog(@"%@", i);
//        if([_childrenDictionary objectForKey:item] ){
//            NSLog(@"this is boss - %@", _childrenDictionary[item]);
//            for (NSString *i in _childrenDictionary){
//                if(i == item) {
//                    NSLog(@"%lu", [_childrenDictionary[item] count]);
//                }
//                else{
////                    NSLog(@"%@", i);
//                }
//            }
//        }
//        else{
//            for(NSString *i in _childrenDictionary){
////                counter++;
//                counterChilds += [_childrenDictionary[i] count];
//                counterParents++;
//            }
//             NSLog(@"Children: %ld", counterChilds);
//            NSLog(@"Parents: %ld", counterParents);
//        }
//    }
    
//    NSLog(@"%@", item);
}

//- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
//    // As an example, hide the "outline disclosure button" for FAVORITES. This hides the "Show/Hide" button and disables the tracking area for that row.
//    if ([item isEqualToString:@"Favorites"]) {
//        return NO;
//    } else {
//        return YES;
//    }
//}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    // For the groups, we just return a regular text view.
    NSTableCellView *cell;
    if ([_topLevelItems containsObject:item]) {
       cell = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
       
        NSString *value = [item uppercaseString];
        [cell.textField setStringValue:value];
//        cell.wantsLayer=YES;
//        [cell.layer setBackgroundColor:[[NSColor whiteColor]CGColor]];
       
        
//        if([currentSelectorName isEqual:@"vk"]){
//            if([value isEqualToString:@"PROFILE"]){
//                NSImageView *imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(5, 2, 70, 16)];
//                imageView.wantsLayer = YES;
//                imageView.layer.cornerRadius = 8;
//                imageView.layer.masksToBounds = YES;
//                [cell addSubview:imageView];
//                [imageView setImage:[NSImage imageNamed:@"profile.png"]];
//            }
//            else if([value isEqualToString:@"DIALOGS"]){
//                
//                NSImageView *imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(5, 2, 70, 18)];
//                
//                [cell addSubview:imageView];
//                [imageView setImage:[NSImage imageNamed:@"dialogs.png"]];
//            }
//            else if([value isEqualToString:@"VIDEO"]){
//                
//                NSImageView *imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(5, 2, 70, 18)];
//                
//                [cell addSubview:imageView];
//                [imageView setImage:[NSImage imageNamed:@"video.png"]];
//            }
//            else if([value isEqualToString:@"AUDIO"]){
//                
//                NSImageView *imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(5, 2, 70, 18)];
//                
//                [cell addSubview:imageView];
//                [imageView setImage:[NSImage imageNamed:@"audio.png"]];
//            }
//            else if([value isEqualToString:@"PHOTO"]){
//                
//                NSImageView *imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(5, 2, 70, 18)];
//                
//                [cell addSubview:imageView];
//                [imageView setImage:[NSImage imageNamed:@"photo.png"]];
//            }
//            else if([value isEqualToString:@"DOCS"]){
//                
//                NSImageView *imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(5, 2, 70, 18)];
//                
//                [cell addSubview:imageView];
//                [imageView setImage:[NSImage imageNamed:@"docs1.png"]];
//            }
////            else{
////               
////            }
//        }else{
//            for(int i = 0; i<[[cell subviews] count]; i++){
//                if([[cell subviews][i] isKindOfClass:[NSImageView class]]){
//                    [[cell subviews][i] removeFromSuperview];
////                    cell.imageView.image=nil;
//                }
//            }
//        }
    

    } else  {
        cell= [outlineView makeViewWithIdentifier:@"DataCell" owner:self];

         [cell.textField setStringValue:item];
//        [cell.imageView removeFromSuperview];
        
        // Setup the icon based on our section
    }
    return cell;
}
@end
