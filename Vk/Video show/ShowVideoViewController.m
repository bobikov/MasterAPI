//
//  ShowVideoViewController.m
//  vkapp
//
//  Created by sim on 25.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "ShowVideoViewController.h"
#import "createNewVideoAlbumController.h"
#import "GroupsFromFileViewController.h"
#import "ShowNamesController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface ShowVideoViewController ()<NSCollectionViewDataSource, NSCollectionViewDelegate, NSSearchFieldDelegate>

@end
static NSString *StringFromCollectionViewDropOperation(NSCollectionViewDropOperation dropOperation);
static NSString *StringFromCollectionViewIndexPath(NSIndexPath *indexPath);
@implementation ShowVideoViewController
@synthesize myWinContr, myWinContr2, ownerId;

- (void)viewDidLoad {
    [super viewDidLoad];
 
    collectionViewListAlbums.dataSource=self;
    collectionViewListAlbums.delegate=self;
    searchBar.delegate=self;
    _app = [[appInfo alloc]init];
    _groupsHandle = [[groupsHandler alloc]init];
    videoAlbums = [[NSMutableArray alloc]init];
    videoAlbums2= [[NSMutableArray alloc]init];
    [[scrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    videoAlbumsCopy = [[NSMutableArray alloc]init];
    searchResultCount.hidden=YES;
    friends = [[NSMutableArray alloc]init];
    friendId=nil;
//    indexPathss = [[NSMutableArray alloc]init];
//    NSCollectionViewItem *itemPrototype = [self.storyboard instantiateControllerWithIdentifier:@"ShowVideoItemPrototype"];
//    NSNib *itemNib = [[NSNib alloc]initWithNibNamed:@"ShowVideoItem" bundle:nil];
//    [collectionViewListAlbums registerNib:itemNib forItemWithIdentifier:@"ShowVideoItemPrototype"];
//    [collectionViewListAlbums setItemPrototype:[self.storyboard instantiateControllerWithIdentifier:@"ShowVideoItemPrototype"]];
//    [collectionViewListAlbums registerForDraggedTypes:@[@"KL_DRAG_TYPE"]];
    [backToAlbums setKBButtonType:BButtonTypeDefault];
//    backToAlbums.highlightColor=[NSColor redColor];
//    backToAlbums.highlightTextColor=[NSColor whiteColor];
//    backToAlbums.textColor=[NSColor blackColor];
//    backToAlbums.cornerRadius=4;
    
    [self loadFriends];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeObject:) name:@"removeObjectVideo" object:nil];
    groupsPopupData = [[NSMutableArray alloc]init];
 
//    if(!albumLoaded){
        [self loadAlbums:NO :nil];
        //         albumsLabel.stringValue = @"Albums";
//    }
    
    [self loadGroupsPopup];
//    [self loadMembershipGroups];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeVideoAlbum:) name:@"removeVideoAlbum" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createVideoAlbumReload:) name:@"createVideoAlbumReload" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMembershipGroupAlbum:) name:@"loadVideoAlbumsFromMembershipGroups" object:nil];
    NSLog(@"%@",_recivedDataForMessage);
    loadForAttachments = _recivedDataForMessage[@"loadVideosForAttachments"] || _recivedDataForMessage[@"addSelectedAlbumVKSocial"] ? YES : NO;
    loadForVKAddToAlbum = _addSelectedAlbumVKSocial[@"addSelectedAlbumVKSocial"] ? YES : NO;
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNamesController:) name:@"ShowNamesController" object:nil];
 
    //     NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:favesScrollView.frame xRadius:4 yRadius:4];
    CAShapeLayer * layer = [CAShapeLayer layer];
    
    layer.cornerRadius=4;
    layer.borderWidth=1;
    layer.borderColor=[[NSColor colorWithWhite:0.8 alpha:1]CGColor];
    collectionViewListAlbums.enclosingScrollView.wantsLayer = TRUE;
    collectionViewListAlbums.enclosingScrollView.layer = layer;
}
- (void)showNamesController:(NSNotification*)notification{
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
//    ShowNamesController *contr = [story instantiateControllerWithIdentifier:@"ShowNamesViewController"];
    _windowController = [story instantiateControllerWithIdentifier:@"ShowNamesWindowController"];
//    contr.receivedData = [[NSMutableArray alloc]initWithArray: videoAlbums];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowNamesData" object:nil  userInfo:@{@"data":videoAlbums}];
    [_windowController showWindow:self];
}
- (void)viewDidAppear{
    if(_loadFromFullUserInfo || _loadFromWallPost){
        self.view.window.titleVisibility=NSWindowTitleHidden;
        self.view.window.titlebarAppearsTransparent = YES;
        self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
        self.view.window.movableByWindowBackground=NO;
    }

}
- (void)viewDidScroll:(NSNotification *)notification{
    if([notification.object isEqual:videoAlbumsClipView]){
        NSInteger scrollOrigin = [[scrollView contentView]bounds].origin.y+NSMaxY([scrollView visibleRect])-2;
        //    NSInteger numberRowHeights = [collectionViewListAlbums numberOfItemsInSection:0];
        NSInteger boundsHeight = collectionViewListAlbums.bounds.size.height;
        //    NSInteger frameHeight = playList.frame.size.height;
        if (scrollOrigin == boundsHeight) {
            
            NSLog(@"The end of section");
            if(!albumLoaded){
                [self loadAlbums:YES :nil];
            }
            else if(searchGlobalMode){
                [self loadSearchGlobalVideo:YES];
            }
            else if(searchUserVideoMode){
                [self loadSearchUserVideos:YES];
            }
            else{
                if(selectedAlbumOffset < totalVideoInAlbum)
                    [self loadSelectedAlbum:selectedAlbum :YES :countInAlbum :nil];
            }
        }
        //    NSLog(@"%lu", numberRowHeights);
        //        NSLog(@"%ld", scrollOrigin);
        //        NSLog(@"%ld", boundsHeight);
        //    NSLog(@"%fld", frameHeight-300);
        //
    }
}
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"createVideoAlbumSeague"]){
        createNewVideoAlbumController *controller = (createNewVideoAlbumController *)segue.destinationController;
        if([[collectionViewListAlbums selectionIndexes]count]>0 && videoAlbums[0][@"cover"]){
            NSMutableArray *titles = [[NSMutableArray alloc]init];
            for(NSDictionary *i in [videoAlbums objectsAtIndexes:[collectionViewListAlbums selectionIndexes]]){
                [titles addObject:i[@"title"]];
            }
            controller.selectedAlbumNames =  [titles componentsJoinedByString:@","];
        }
        
        
        controller.receivedDataForNewAlbum=@{@"owner":ownerId == nil || ![groupsPopupData containsObject:ownerId] ? _app.person : ownerId};
        controller.ownerInMainVideoController=ownerId == nil || ![groupsPopupData containsObject:ownerId] ? _app.person : ownerId;
    }
    else if([segue.identifier isEqualToString:@"GroupsFromFileSegueVideo"]){
        GroupsFromFileViewController *controller = (GroupsFromFileViewController *)segue.destinationController;
        controller.recivedData=@{@"type":@"video"};
        
    }
}

- (void)createVideoAlbumReload:(NSNotification *)notification{
//    [ownerId isEqual:_app.person] ? [self loadAlbums:NO :nil :ownerId] : nil;
    
//    ownerId=[groupsPopupData containsObject:ownerId]?ownerId:_app.person;
    if(!albumLoaded && !searchGlobalMode && !searchUserVideoMode && [notification.userInfo[@"reload"] intValue] ){
        [self loadAlbums:NO :nil ];
    }
//    NSLog(@"%@", ownerId);
}
- (void)removeVideoAlbum:(NSNotification*)notification{
//    [self loadAlbums:NO :nil];
    dispatch_async(dispatch_get_main_queue(),^{
        
        
        NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[videoAlbums indexOfObject:notification.userInfo[@"object"]] inSection:0];
        
        [videoAlbums removeObjectAtIndex:[videoAlbums indexOfObject:notification.userInfo[@"object"]] ];
        [collectionViewListAlbums deleteItemsAtIndexPaths:[NSSet setWithObject:indexPath]];
        collectionViewListAlbums.content=videoAlbums;
        
    });
}
- (IBAction)createNewAlbum:(id)sender {
    
    
}
- (void)removeObject:(NSNotification*)notification{
    dispatch_async(dispatch_get_main_queue(),^{
        //    [self loadSelectedAlbum:selectedAlbum :NO :countInAlbum :nil];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[notification.userInfo[@"index"] intValue] inSection:0];
        
        [videoAlbums removeObjectAtIndex:[notification.userInfo[@"index"] intValue]];
        [collectionViewListAlbums deleteItemsAtIndexPaths:[NSSet setWithObject:indexPath]];
        collectionViewListAlbums.content = videoAlbums;
        //        [collectionViewListAlbums reloadData];
        //    NSLog(@"%@", selectedAlbum);
        //    NSLog(@"%@", countInAlbum);
    });
}
- (void)loadMembershipGroupAlbum:(NSNotification *)notification{
    publicIdFrom=nil;
    ownerId = [NSString stringWithFormat:@"-%@", notification.userInfo[@"id"]];
    [self loadAlbums:NO :nil];
}
- (void)loadGroupsPopup{
    __block NSMenu *menu1 = [[NSMenu alloc]init];
    __block  NSMenuItem *menuItem;
    [groupsPopupList removeAllItems];
    [groupsPopupData addObject:_app.person];
    viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
    [viewControllerItem loadView];
    menuItem = [[NSMenuItem alloc]initWithTitle:@"Personal" action:nil keyEquivalent:@""];
    viewControllerItem.nameField.stringValue=@"Personal";
    [menuItem setView:[viewControllerItem view]];
    [menu1 addItem:menuItem];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if(data){
                    NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
                        [groupsPopupData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
                        viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
                        [viewControllerItem loadView];
                        menuItem = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"%@", i[@"name"]] action:nil keyEquivalent:@""];
                        NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:i[@"photo_50"]]];
                        image.size=NSMakeSize(30,30);
                        [menuItem setImage:image];
                        viewControllerItem.photo.wantsLayer=YES;
                        viewControllerItem.photo.layer.masksToBounds=YES;
                        viewControllerItem.photo.layer.cornerRadius=39/2;
                        [viewControllerItem.photo setImageScaling:NSImageScaleProportionallyUpOrDown];
                        viewControllerItem.nameField.stringValue=[NSString stringWithFormat:@"%@", i[@"name"]];
                        [viewControllerItem.photo setImage:image];
                        [menuItem setView:[viewControllerItem view]];
                        [menu1 addItem:menuItem];
                        
                    }
                }
                dispatch_async(dispatch_get_main_queue(),^{
                    [groupsPopupList setMenu:menu1];
                });
            }]resume];
        });
    });

}
- (void)loadFriends{
    __block NSMenu *menu1 = [[NSMenu alloc]init];
    __block  NSMenuItem *menuItem;
    if(!_loadFromFullUserInfo){
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/friends.get?owner_id=%@&v=%@&fields=city,domain,photo_50&access_token=%@", _app.person, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *getFriendsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                for(NSDictionary *i in getFriendsResponse[@"response"][@"items"]){
                    [friends addObject:@{@"full_name":[NSString stringWithFormat:@"%@ %@", i[@"first_name"], i[@"last_name"]], @"id":i[@"id"]}];
                    //                    [itemTitles addObject:[NSString stringWithFormat:@"%@ %@", i[@"first_name"], i[@"last_name"]]];
                    viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
                    [viewControllerItem loadView];
                    menuItem = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"%@ %@", i[@"first_name"], i[@"last_name"]] action:nil keyEquivalent:@""];
                    
                    
                    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:i[@"photo_50"]]];
                    
                    image.size=NSMakeSize(30,30);
                    [menuItem setImage:image];
                    viewControllerItem.photo.wantsLayer=YES;
                    viewControllerItem.photo.layer.masksToBounds=YES;
                    viewControllerItem.photo.layer.cornerRadius=39/2;
                    [viewControllerItem.photo setImageScaling:NSImageScaleProportionallyUpOrDown];
                    viewControllerItem.nameField.stringValue=[NSString stringWithFormat:@"%@ %@", i[@"first_name"],i[@"last_name"]];
                    [viewControllerItem.photo setImage:image];
                    [menuItem setView:[viewControllerItem view]];
                    [menu1 addItem:menuItem];
                    
                }
                
                dispatch_async(dispatch_get_main_queue(),^{
                    
                    //                    [friendsListDropdown setPullsDown:YES];
                    [friendsListDropdown removeAllItems];
                    [friendsListDropdown setMenu:menu1];
                    
                    
                });
                
                //                [friendsListDropdown addItemsWithTitles:[NSArray arrayWithArray:itemTitles]];
            }
        }]resume];
        
    }else{
        //        ownerId = _userDataFromFullUserInfo[@"id"];
        [friends addObject:@{@"full_name":[NSString stringWithFormat:@"%@ %@", _userDataFromFullUserInfo[@"first_name"], _userDataFromFullUserInfo[@"last_name"]], @"id":_userDataFromFullUserInfo[@"id"]}];
        [friendsListDropdown removeAllItems];
        [friendsListDropdown addItemWithTitle:_userDataFromFullUserInfo[@"full_name"]];
    }
}
- (IBAction)groupsPopupAction:(id)sender {
    ownerId =[groupsPopupData objectAtIndex:[groupsPopupList indexOfSelectedItem]];
    [self loadAlbums:NO :nil];
   
    
}

- (IBAction)albumsDropdownListAction:(id)sender {
    selectedAlbum= videoAlbumsCopy[[albumsDropdownList indexOfSelectedItem]][@"id"];
    countInAlbum =videoAlbumsCopy[[albumsDropdownList indexOfSelectedItem]][@"count"];
    ownerId=ownerId==nil?_app.person : ownerId;
    NSLog(@"%@", selectedAlbum);
    [self loadSelectedAlbum:selectedAlbum :NO :countInAlbum :nil];
//    NSLog(@"%@", videoAlbums2[[albumsDropdownList indexOfSelectedItem]][@"id"]);
    
}
- (IBAction)friendsListDropdownAction:(id)sender {
    
    friendId = friends[[friendsListDropdown indexOfSelectedItem]][@"id"];
    ownerId= friendId;
    [self loadAlbums:NO :nil];
    
}
- (void)searchFieldDidStartSearching:(NSSearchField *)sender{
   
    
    switch (searchSource.selectedSegment){
        case 0:
            searchUserVideoMode = YES;
            [self loadSearchUserVideos:NO];
            break;
        case 1:
            searchLocalVideo = YES;
            [self loadSearchLocalVideo:NO];
            break;
        case 2:
             searchGlobalMode = YES;
            [self loadSearchGlobalVideo:NO];
            break;
    }
    
}
- (void)searchFieldDidEndSearching:(NSSearchField *)sender{
    searchGlobalMode = NO;
    searchUserVideoMode = NO;
    searchLocalVideo = NO;
//    if(albumLoaded){
//        [self loadSelectedAlbum:selectedAlbum :NO :countInAlbum :videoAlbums] ;
//        searchResultCount.hidden=YES;
//    }
//    else{
        searchResultCount.hidden=YES;
//        [self loadAlbums:NO :videoAlbums];
//        NSLog(@"%@", videoAlbums);
//    }
    videoAlbums = [[NSMutableArray alloc]initWithArray:videoAlbumsTemp];
    [collectionViewListAlbums setContent:videoAlbums];
    [collectionViewListAlbums reloadData];
}

- (IBAction)backToAlbumsAction:(id)sender {
//    [self resetAlbumsDropdown];
    ownerId=_app.person;
    friendId=nil;
    publicIdFrom = nil;
    [self loadAlbums:NO :nil];

}

NSInteger floatSort(id num1, id num2, void *context){
    float v1 = [num1 floatValue];
    float v2 = [num2 floatValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

- (void)loadAlbums:(BOOL)makeOffset :(id)albums {
    ownerId = ownerId == nil ? _app.person : ownerId;
    __block NSString *url;
    nameSelectedObject = @"albums";
    albumLoaded=NO;
    searchGlobalMode=NO;
    searchUserVideoMode=NO;
    //    NSMutableArray *itemTitles = [[NSMutableArray alloc]init];
    __block int index=0;
    if(!makeOffset && !albums){
        
        [videoAlbums removeAllObjects];
        [albumsDropdownList removeAllItems];
//        [collectionViewListAlbums setContent:videoAlbums];
        
        offset = 0;
    }
    else{
        offset=offset+100;
    }
    
    
    url =[NSString stringWithFormat:@"https://api.vk.com/method/video.getAlbums?owner_id=%@&extended=1&v=%@&count=100&offset=%lu&need_system=1&access_token=%@", ownerId, _app.version, offset, _app.token];
    
    
    
    if(albums==nil){
        __block NSString *cover;
        [[_app.session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *getAlbumsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                for(NSDictionary *i in getAlbumsResponse[@"response"][@"items"]){
                    index++;
                    if(i[@"photo_160"]){
                        cover= i[@"photo_160"];
                    }
                    else{
                        cover=@"";
                    }
                    NSMutableDictionary *object = [[NSMutableDictionary alloc]initWithDictionary:@{@"index":[NSNumber numberWithInt:index], @"id":i[@"id"], @"cover":cover, @"owner_id":i[@"owner_id"], @"title":i[@"title"], @"count":i[@"count"], @"desc":i[@"description"]!=nil?i[@"description"]:@""}];
                    
                    [videoAlbums addObject:object];
                  
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self loadAlbumsDropdown];
                    [collectionViewListAlbums setContent:videoAlbums];
                    [collectionViewListAlbums reloadData];
                    totalCount.title = [NSString stringWithFormat:@"%@", getAlbumsResponse[@"response"][@"count"]];
                });
            }
        }] resume];
    }
    else{
        
        [collectionViewListAlbums setContent:videoAlbums];
        [collectionViewListAlbums reloadData];
        
    }
}
- (void)loadAlbumsDropdown{
//    if(!albumLoaded){
        [videoAlbumsCopy removeAllObjects];
        [albumsDropdownList removeAllItems];
        if([videoAlbumsCopy count]==0){
            videoAlbumsCopy = [[NSMutableArray alloc]initWithArray:videoAlbums];
            
            
            for(NSDictionary *i in videoAlbumsCopy){
//                [albumsDropdownList addItemWithTitle:i[@"title"]];
                NSMenuItem *menuItem = [[NSMenuItem alloc]initWithTitle:i[@"title"] action:nil keyEquivalent:@""];
                [[albumsDropdownList menu] addItem:menuItem];
            }
        }
//    }
//        for(NSDictionary *i in videoAlbums){
//            [videoAlbumsCopy addObject:i];
//            [albumsDropdownList addItemWithTitle:i[@"title"]];
//        }
//    }
}
- (void)resetAlbumsDropdown{
    [self loadAlbumsDropdown];
}
- (void)showAlbumsFromPublic{
    ownerId=[NSString stringWithFormat:@"%@", publicIdFromShow.stringValue];
    [self loadAlbums:NO :nil];
    
}
- (IBAction)showAlbumsFromButAction:(id)sender {
    
    ownerId=[NSString stringWithFormat:@"%@", publicIdFromShow.stringValue];
    publicIdFrom=[NSString stringWithFormat:@"%@", publicIdFromShow.stringValue];
    [self loadAlbums:NO :nil];
}
- (void)loadSearchAlbumVideo{
    
//    if(albumLoaded){
      //    }

}
- (void)loadSearchUserVideos:(BOOL)makeOffset{
    NSLog(@"Load searc user videos");
    ownerId=nil;
    NSString *url;
    if(safeModeSearch.state==1){
        url = [NSString stringWithFormat:@"https://api.vk.com/method/video.search?q=%@&extended=0&search_own=1&count=200&v=%@&offset=%i&adult=0&access_token=%@", [searchBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], _app.version, offsetSearchCounter, _app.token ];
    }
    else{
        url = [NSString stringWithFormat:@"https://api.vk.com/method/video.search?q=%@&extended=1&count=200&v=%@&search_own=1&offset=%i&adult=1&access_token=%@", [searchBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], _app.version, offsetSearchCounter, _app.token ];
    }
    if(makeOffset){
        offsetSearchCounter = offsetSearchCounter + 200;
    }else{
        offsetSearchCounter = 0;
        [videoAlbums removeAllObjects];
    }
    [[_app.session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *searchResponse=[NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
        for(NSDictionary *i in searchResponse[@"response"][@"items"]){
            [videoAlbums addObject:@{@"id":i[@"id"], @"photo":i[@"photo_130"],@"photo2":i[@"photo_320"], @"owner_id":i[@"owner_id"], @"title":i[@"title"], @"player":i[@"player"]}];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date"  ascending:NO];
            //            sortedAlbums=[videoAlbums sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
            albumLoaded = YES;
          
            [collectionViewListAlbums setContent:videoAlbums];
            [collectionViewListAlbums reloadData];
            searchResultCount.hidden=NO;
            totalCount.title = [NSString stringWithFormat:@"%i", offsetSearchCounter];
            
            searchResultCount.title= [NSString stringWithFormat:@"%@", searchResponse[@"response"][@"count"]];
        });
    }] resume];
}
- (void)loadSearchGlobalVideo:(BOOL)makeOffset{
    nameSelectedObject = @"album";
    ownerId=nil;
    if(makeOffset){
        offsetSearchCounter = offsetSearchCounter + 200;
    }else{
        offsetSearchCounter = 0;
        [videoAlbums removeAllObjects];
    }
    
    NSString *url;
    if(safeModeSearch.state==1){
        url = [NSString stringWithFormat:@"https://api.vk.com/method/video.search?q=%@&extended=0&count=200&v=%@&offset=%i&adult=0&access_token=%@", [searchBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], _app.version, offsetSearchCounter, _app.token ];
    }
    else{
        url = [NSString stringWithFormat:@"https://api.vk.com/method/video.search?q=%@&extended=1&count=200&v=%@&offset=%i&adult=1&access_token=%@", [searchBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], _app.version, offsetSearchCounter, _app.token ];
    }
    [[_app.session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *searchResponse=[NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
        for(NSDictionary *i in searchResponse[@"response"][@"items"]){
            [videoAlbums addObject:@{@"id":i[@"id"], @"photo":i[@"photo_130"],@"photo2":i[@"photo_320"], @"owner_id":i[@"owner_id"], @"title":i[@"title"], @"player":i[@"player"]}];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date"  ascending:NO];
            //            sortedAlbums=[videoAlbums sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];
            albumLoaded = YES;
            
            [collectionViewListAlbums setContent:videoAlbums];
            [collectionViewListAlbums reloadData];
            searchResultCount.hidden=NO;
            totalCount.title = [NSString stringWithFormat:@"%i", offsetSearchCounter];
            
            searchResultCount.title= [NSString stringWithFormat:@"%@", searchResponse[@"response"][@"count"]];
        });
    }] resume];
    
    
}
- (void)loadSearchLocalVideo:(BOOL)makeOffset{
    NSLog(@"Local search");
    NSInteger counter=0;
    videoAlbumsTemp=[[NSMutableArray alloc]initWithArray:videoAlbums];
    if(albumLoaded){
        nameSelectedObject=@"album";
    }else{
        nameSelectedObject=@"albums";
    }
    [videoAlbums removeAllObjects];
    for(NSDictionary *i in videoAlbumsTemp){
        
        if([i[@"title"] containsString: searchBar.stringValue ]){
       
            counter++;
            [videoAlbums addObject:i];
            NSLog(@"%@",i);
        }
        
    }

        //                NSLog(@"%@", videoAlbumsTemp);
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date"  ascending:NO];
        
        
        [collectionViewListAlbums setContent:videoAlbums];
        [collectionViewListAlbums reloadData];
        searchResultCount.hidden=NO;
        searchResultCount.title = [NSString stringWithFormat:@"%lu", counter];
    

}
- (void)loadSelectedAlbum:(id)albumId :(BOOL)makeOffset :(id)count :(id)videoData{
    albumLoaded=YES;
    nameSelectedObject = @"album";
    __block int index=0;
    if(makeOffset){
        selectedAlbumOffset = selectedAlbumOffset+200;
    }else{
        selectedAlbumOffset = 0;
        [videoAlbums removeAllObjects];
    }
    
    NSString *url;

    if(videoData==nil){
       
        NSLog(@"OWNER SELECTED ALBUM %@", ownerId);
        
//            if(friendId!=nil){
//                
//                url =[NSString stringWithFormat:@"https://api.vk.com/method/video.get?owner_id=%@&album_id=%@&count=200&offset=%i&extended=1&v=%@&access_token=%@", friendId, albumId, selectedAlbumOffset, _app.version,  _app.token];
//            }
//            else{
            url = [NSString stringWithFormat:@"https://api.vk.com/method/video.get?owner_id=%@&album_id=%@&count=200&offset=%i&extended=1&v=%@&access_token=%@", ownerId==nil ? _app.person : ownerId, albumId, selectedAlbumOffset, _app.version,  _app.token];
//            }
        
            [[_app.session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *getAlbumResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if(data){
                    totalVideoInAlbum = [getAlbumResponse[@"response"][@"count"] intValue];
                     NSLog(@"%i %li %@", selectedAlbumOffset, totalVideoInAlbum, countInAlbum);
                    for(NSDictionary *i in getAlbumResponse[@"response"][@"items"]){
                        //            NSLog(@"%@", i);
                        index++;
                        [videoAlbums addObject:@{@"albumOwner":ownerId, @"albumId":selectedAlbum, @"index":[NSNumber numberWithInt:index], @"id":i[@"id"], @"owner_id":i[@"owner_id"], @"photo":i[@"photo_130"], @"title":i[@"title"], @"photo2":i[@"photo_320"],@"player":i[@"player"], @"date":i[@"date"]}];
                        //                    [indexPathss addObject:[NSIndexPath indexPathForItem:[videoAlbums count] == 0 ? 0 : [videoAlbums count]-1 inSection:0]];
                        //                    dispatch_async(dispatch_get_main_queue(), ^{
                        //                        [collectionViewListAlbums insertItemsAtIndexPaths:[NSSet setWithArray:@[[NSIndexPath indexPathForItem:[videoAlbums count] == 0 ? 0 : [videoAlbums count]-1 inSection:0]]]];
                        //                    });
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                    
                        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date"  ascending:NO];
                        videoAlbums=[[NSMutableArray alloc]initWithArray:[videoAlbums sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]] ];
                        totalCount.title = [NSString stringWithFormat:@"%li",totalVideoInAlbum];
                        [collectionViewListAlbums setContent:videoAlbums];
                        [collectionViewListAlbums reloadData];
                    });
                }
            }] resume];
    }
     else{
         NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"date"  ascending:NO];
         videoAlbums = [[NSMutableArray alloc]initWithArray: [videoData sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]]];
         [collectionViewListAlbums setContent:videoAlbums];
         [collectionViewListAlbums reloadData];
         
     }
}




- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    NSEvent *currentEvent = [NSApp currentEvent];

    if(!albumLoaded){
        NSInteger selectedItemIndex = [indexPaths allObjects][0].item;
        if(selectedItemIndex <= [videoAlbums count]){
            [albumsDropdownList selectItemAtIndex:selectedItemIndex];
            NSLog(@"%@", [videoAlbums objectsAtIndexes:[collectionViewListAlbums selectionIndexes]]);
            selectedAlbum= [[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject][@"id"] ;
            countInAlbum = [[[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject][@"count"] copy];
            ownerId=[[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject][@"owner_id"];
            totalCount.title = [NSString stringWithFormat:@"%@", countInAlbum];
            if(!loadForVKAddToAlbum && !([currentEvent modifierFlags] & NSCommandKeyMask) && [currentEvent type]!=NSLeftMouseDragged && [[collectionViewListAlbums selectionIndexes]count]==1){
                [self loadSelectedAlbum:selectedAlbum :NO :countInAlbum :nil] ;
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedVideoAlbumVK" object:nil userInfo:[[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject]];
            }
        }
 
    }
    else{
        myWinContr = [[NSWindowController alloc]initWithWindowNibName:@"MyVideoWindowController"];
        myWinContr2 = [self.storyboard instantiateControllerWithIdentifier:@"VideoController"];
        selectedVideoURL = [[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject][@"player"];
        selectedVideoTitle =[[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject][@"title"];
        selectedVideoCover = [[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject][@"photo2"];
        if(!loadForAttachments ){
            if(!([currentEvent modifierFlags] & NSCommandKeyMask) && [[collectionViewListAlbums selectionIndexes]count]==1){
                [myWinContr2 showWindow:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"playVideo" object:nil userInfo:@{@"url":selectedVideoURL, @"title":selectedVideoTitle, @"cover":selectedVideoCover}];
            }
        }else{
            NSLog(@"%@", selectedVideoTitle);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addToAttachments" object:nil userInfo:@{@"type":@"video", @"data":[[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject]}];
        }
    }
}

- (BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths withEvent:(NSEvent *)event{
    return YES;
}
//- (BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths toPasteboard:(NSPasteboard *)pasteboard{
//    //    [pasteBoard clearContents];
//    //
//    //    NSArray *objects = [NSArray arrayWithObjects:[[collectionViewListAlbums itemAtIndexPath:indexPath]representedObject][@"cover"], nil];
//    //    [pasteBoard writeObjects:objects];
//    return YES;
//}

- (NSImage*)collectionView:(NSCollectionView *)collectionView draggingImageForItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths withEvent:(NSEvent *)event offset:(NSPointPointer)dragImageOffset{
    NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:[[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]]representedObject][@"cover"]]];
//    NSLog(@"%@", indexes);
    return image;
}
- (NSDragOperation)draggingSession:(NSDraggingSession *)session
sourceOperationMaskForDraggingContext:(NSDraggingContext)context{
    return NSDragOperationMove;
}
- (id<NSPasteboardWriting>)collectionView:(NSCollectionView *)collectionView pasteboardWriterForItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
//    [pasteBoard clearContents];
//    NSArray *objects = [NSArray arrayWithObjects:[[collectionViewListAlbums itemAtIndexPath:indexPath]representedObject][@"cover"], nil];
//    [pasteBoard writeObjects:objects];
    return [[collectionViewListAlbums itemAtIndexPath:indexPath]representedObject][@"cover"];
}

- (void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    NSLog(@"Dragging session is started");
    indexPathsOfItemsBeingDragged = [indexPaths copy];
    NSLog(@"%@", indexPaths);
}
//-(void)collectionView:(NSCollectionView *)collectionView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint dragOperation:(NSDragOperation)operation{
//    NSPasteboardItem *pitem = [[NSPasteboard generalPasteboard]pasteboardItems][0];
//    NSString *urlString = [pitem stringForType:(NSString *)kUTTypeUTF8PlainText];
//    NSLog(@"%@", urlString);
//    indexPathsOfItemsBeingDragged = nil;
//    
//}
- (NSDragOperation)collectionView:(NSCollectionView *)collectionView validateDrop:(id <NSDraggingInfo>)draggingInfo proposedIndexPath:(NSIndexPath **)proposedDropIndexPath dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation {
    NSLog(@"Validate Drop");
    NSString *proposedActionDescription = [NSString stringWithFormat:@"Validate drop %@ item at indexPath=%@", StringFromCollectionViewDropOperation(*proposedDropOperation), StringFromCollectionViewIndexPath(*proposedDropIndexPath)];
    if (*proposedDropOperation == NSCollectionViewDropOn) {
        *proposedDropOperation = NSCollectionViewDropBefore;
        proposedActionDescription = [proposedActionDescription stringByAppendingFormat:@" -- changed to drop before %@", StringFromCollectionViewIndexPath(*proposedDropIndexPath)];
    }
    if (indexPathsOfItemsBeingDragged) {
        return  NSDragOperationMove;
    } else {
        return NSDragOperationCopy;
    }
//    return NSDragOperationMove;
}
- (BOOL)collectionView:(NSCollectionView *)collectionView acceptDrop:(id<NSDraggingInfo>)draggingInfo indexPath:(NSIndexPath *)indexPath dropOperation:(NSCollectionViewDropOperation)dropOperation{
    __block NSInteger toItemIndex = indexPath.item;
    [indexPathsOfItemsBeingDragged enumerateIndexPathsWithOptions:0 usingBlock:^(NSIndexPath *fromIndexPath, BOOL *stop) {
        NSInteger fromItemIndex = fromIndexPath.item;
        if (fromItemIndex > toItemIndex) {
            
            /*
             For each step: First, modify our model.
             */
            [collectionViewListAlbums moveItemAtIndexPath:fromIndexPath toIndexPath:indexPath];
            
            /*
             Next, notify the CollectionView of the change we just
             made to our model.
             */
            [[collectionViewListAlbums animator] moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromItemIndex inSection:[indexPath section]] toIndexPath:[NSIndexPath indexPathForItem:toItemIndex inSection:[indexPath section]]];
            
            // Advance to maintain moved items in their original order.
            ++toItemIndex;
        }
    }];
    
    /*
     Walk backward through fromItemIndex values < toItemIndex, to
     keep our "from" and "to" indexes valid as we go, moving items
     one at a time.
     */
    __block NSInteger adjustedToItemIndex = indexPath.item - 1;
    [indexPathsOfItemsBeingDragged enumerateIndexPathsWithOptions:NSEnumerationReverse  usingBlock:^(NSIndexPath *fromIndexPath, BOOL *stop) {
        NSInteger fromItemIndex = [fromIndexPath item];
        if (fromItemIndex < adjustedToItemIndex) {
            
            /*
             For each step: First, modify our model.
             */
             [collectionViewListAlbums moveItemAtIndexPath:fromIndexPath toIndexPath:indexPath];
            
            
            /*
             Next, notify the CollectionView of the change we just
             made to our model.
             */
            NSIndexPath *adjustedToIndexPath = [NSIndexPath indexPathForItem:adjustedToItemIndex inSection:[indexPath section]];
            [collectionViewListAlbums.animator moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromItemIndex inSection:indexPath.section] toIndexPath:adjustedToIndexPath];
            
            // Retreat to maintain moved items in their original order.
            --adjustedToItemIndex;
        }
    }];
    
    // We did it!
    

    return YES;
}
- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return [videoAlbums count];
}
- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    
    CustomVideoCollectionItem *item1;
    NSAttributedString *attrTitle;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.alignment=NSTextAlignmentCenter;
    if([videoAlbums count]>0){
        item1 = (CustomVideoCollectionItem*)[collectionView makeItemWithIdentifier:@"CustomVideoCollectionItem" forIndexPath:indexPath];
        NSString *coverAlbum = [videoAlbums objectAtIndex:indexPath.item][@"cover"];
        NSString *itemTitle = [videoAlbums objectAtIndex:indexPath.item][@"title"];
       
        if([nameSelectedObject isEqualToString:@"albums"]){
             countInAlbum = [videoAlbums objectAtIndex:indexPath.item][@"count"];
            NSAttributedString *countAttrString = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@", countInAlbum ]attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSParagraphStyleAttributeName:paragraphStyle}];
            item1.countLabel.hidden=NO;
            item1.countLabel.attributedStringValue=countAttrString;

          
           attrTitle = [[NSAttributedString alloc]initWithString:itemTitle attributes:@{NSForegroundColorAttributeName:item1.isSelected ? [NSColor whiteColor] : [NSColor blackColor], NSParagraphStyleAttributeName:paragraphStyle}];
            item1.textLabel.attributedStringValue=attrTitle;
//            item1.textLabel.stringValue=itt2;
            //    NSLog(@"%@", itt);
            item1.textField.stringValue=@"";
            
            item1.attachAlbum.hidden =  YES;
//            if(loadForAttachments){
////                [item1.downloadButton removeFromSuperview];
////                [item1.uploadPhoto removeFromSuperview];
//                
//                [item1.removeItem removeFromSuperview];
//                [item1.moveToAlbum removeFromSuperview];
////                [item1.uploadByURLsButton removeFromSuperview];
////                [item1.downloadAndUploadStatusOver removeFromSuperview];
//            }
            //SDWebImageProgressiveDownload
            
            if([countInAlbum intValue]==0){
                [item1.albumCover setImage:[NSImage imageNamed:@"video_album_def1.png"]];
            }else{
                [item1.albumCover  sd_setImageWithURL:[NSURL URLWithString:coverAlbum] placeholderImage:nil options:SDWebImageRefreshCached completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    NSImageRep *rep = [[image representations] objectAtIndex:0];
                    NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
                    image.size=imageSize;
                    item1.albumCover.image=image;
                }];
            }

        }
        else{
            item1.attachAlbum.hidden =  YES;
            item1.albumCover.image=nil;
            item1.textField.stringValue=@"";
            attrTitle = [[NSAttributedString alloc]initWithString:itemTitle attributes:@{NSForegroundColorAttributeName:item1.isSelected ? [NSColor whiteColor] : [NSColor blackColor], NSParagraphStyleAttributeName:paragraphStyle}];
            NSString *photo = [videoAlbums objectAtIndex:indexPath.item][@"photo"];
            item1.countLabel.hidden=YES;
            item1.textLabel.attributedStringValue=attrTitle;

            [item1.albumCover  sd_setImageWithURL:[NSURL URLWithString:photo] placeholderImage:nil options:SDWebImageRefreshCached completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                NSImageRep *rep = [[image representations] objectAtIndex:0];
                NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
                image.size=imageSize;
                item1.albumCover.image=image;
            }];
        }
    }
    return item1;
    
    
}
static NSString *StringFromCollectionViewDropOperation(NSCollectionViewDropOperation dropOperation) {
    switch (dropOperation) {
        case NSCollectionViewDropBefore:
            return @"before";
            
        case NSCollectionViewDropOn:
            return @"on";
            
        default:
            return @"?";
    }
}
static NSString *StringFromCollectionViewIndexPath(NSIndexPath *indexPath) {
    if (indexPath && indexPath.length == 2) {
        return [NSString stringWithFormat:@"(%ld,%ld)", (long)(indexPath.section), (long)(indexPath.item)];
    
    } else {
        return @"(nil)";
    }
}
@end
