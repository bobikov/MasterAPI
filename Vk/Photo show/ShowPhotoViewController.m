//
//  ShowPhotoViewController.m
//  vkapp
//
//  Created by sim on 25.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "ShowPhotoViewController.h"
#import "CreateNewAlbumController.h"
#import "GroupsFromFileViewController.h"

@interface ShowPhotoViewController ()<NSCollectionViewDataSource, NSCollectionViewDelegate, NSSearchFieldDelegate>

@end

@implementation ShowPhotoViewController
@synthesize  myWindowContr, ownerId,loadForAttachments;
- (void)viewDidLoad {
    [super viewDidLoad];
    collectionViewListAlbums.dataSource=self;
    collectionViewListAlbums.delegate=self;
    _app = [[appInfo alloc]init];
    albumsData = [[NSMutableArray alloc]init];
    albumsData2 = [[NSMutableArray alloc]init];
    friends = [[NSMutableArray alloc]init];
    searchBar.delegate = self;
    [self loadFriends];
    if(!albumLoaded){
        [self loadAlbums];
    }
   
    groupsListPoupData = [[NSMutableArray alloc]init];
  
    [self loadGroupsPopup];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeObject:) name:@"removeObjectPhoto" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removePhotoAlbum:) name:@"removePhotoAlbum" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createAlbumReload:) name:@"createAlbumReload" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMembershipGroupAlbum:) name:@"loadPhotoAlbumsFromMembershipGroups" object:nil];
    
     loadForAttachments = _receivedData[@"loadPhotosForAttachments"] ? YES : NO;

    cachedImage = [[NSMutableDictionary alloc]init];
}
-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"createPhotoAlbumSeague"]){
        CreateNewAlbumController *controller = (CreateNewAlbumController *)segue.destinationController;
        
        controller.receivedDataForNewAlbum=@{@"owner":ownerId == nil ? ownerId=_app.person : ownerId};
    }
    else if([segue.identifier isEqualToString:@"GroupsFromFileSeguePhoto"]){
        GroupsFromFileViewController *controller = (GroupsFromFileViewController *)segue.destinationController;
        controller.recivedData=@{@"type":@"photo"};
    }
}

-(void)loadGroupsPopup{
    __block NSMenu *menu1 = [[NSMenu alloc]init];
    __block  NSMenuItem *menuItem;
    [groupsListPopup removeAllItems];
    [groupsListPoupData addObject:_app.person];
    viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
    [viewControllerItem loadView];
    menuItem = [[NSMenuItem alloc]initWithTitle:@"Personal" action:nil keyEquivalent:@""];
    [menu1 addItem:menuItem];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
                [groupsListPoupData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [groupsListPopup setMenu:menu1];
            });
        }]resume];
    });
 
}

- (IBAction)groupsListPopup:(id)sender {
    ownerId=[groupsListPoupData objectAtIndex:[groupsListPopup indexOfSelectedItem]];
    [self loadAlbums];
}

-(void)removeObject:(NSNotification*)notification{
//    [self loadSelectedAlbum:selectedAlbumToLoad];
    dispatch_async(dispatch_get_main_queue(),^{
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[notification.userInfo[@"index"] intValue] inSection:0];
        [albumsData removeObjectAtIndex:[notification.userInfo[@"index"] intValue]];
        [collectionViewListAlbums deleteItemsAtIndexPaths:[NSSet setWithObject:indexPath]];
        collectionViewListAlbums.content=albumsData;
        
    });
}

-(void)removePhotoAlbum:(NSNotification*)notification{

    dispatch_async(dispatch_get_main_queue(),^{

        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[notification.userInfo[@"index"] intValue] inSection:0];
        [albumsData removeObjectAtIndex:[notification.userInfo[@"index"] intValue]];
        [collectionViewListAlbums deleteItemsAtIndexPaths:[NSSet setWithObject:indexPath]];
        collectionViewListAlbums.content=albumsData;

    });
}
-(void)createAlbumReload:(NSNotification*)notification{
    [self loadAlbums];
}

-(void)viewDidAppear{
//    if(!albumLoaded){
//        [self loadAlbums:nil];
//    }
    if(_loadFromFullUserInfo || _loadFromWallPost){
        self.view.window.titleVisibility=NSWindowTitleHidden;
        self.view.window.titlebarAppearsTransparent = YES;
        self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
        self.view.window.movableByWindowBackground=NO;
    }
}

-(void)loadMembershipGroupAlbum:(NSNotification *)notification{
    ownerId = [NSString stringWithFormat:@"-%@", notification.userInfo[@"id"]];
    [self loadAlbums];
}

-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    [self loadSearchVideo];
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    [self loadAlbums];
}

-(void)loadSearchVideo{
    if(!albumLoaded){
        NSInteger counter=0;
        NSMutableArray *photoAlbumsTemp=[[NSMutableArray alloc]init];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
        for(NSDictionary *i in albumsData){
            
            NSArray *found = [regex matchesInString:i[@"title"]  options:0 range:NSMakeRange(0, [i[@"title"] length])];
            if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
                counter++;
                [photoAlbumsTemp addObject:i];
            }
            
        }
        if([photoAlbumsTemp count]>0){
            albumsData = photoAlbumsTemp;
            [collectionViewListAlbums setContent:albumsData];
            [collectionViewListAlbums reloadData];
        }
    }
}

- (IBAction)backToAlbumsAction:(id)sender {
    
    [self loadAlbums];
    
    friendId=nil;
    ownerId=nil;
    
}


- (IBAction)showPhotoByOwner:(id)sender {
    if(![ownerField.stringValue isEqual:@""]){
        ownerId=ownerField.stringValue;
        [self loadAlbums];
    }
    
    
    
}
- (IBAction)albumsListDropdownAction:(id)sender {
    [self loadSelectedAlbum:albumsData2[[albumsListDropdown indexOfSelectedItem]][@"id"]] ;
    
}
- (IBAction)friendsListDropdownAction:(id)sender {
    friendId = friends[[friendsListDropdown indexOfSelectedItem]][@"id"];
    ownerId= friendId;
    [self loadAlbums];
}
-(void)loadSelectedAlbum:(id)albumId{
    nameSelectedObject = @"album";
      [albumsData removeAllObjects];
    NSString *url;
   __block NSInteger index=0;
    if(friendId!=nil){
        url=[NSString stringWithFormat:@"https://api.vk.com/method/photos.get?owner_id=%@&album_id=%@&v=%@&rev=1&access_token=%@", friendId, albumId, _app.version, _app.token];
    }
    else{
        url=[NSString stringWithFormat:@"https://api.vk.com/method/photos.get?owner_id=%@&album_id=%@&rev=1&v=%@&access_token=%@", ownerId==nil ? _app.person : ownerId, albumId, _app.version, _app.token];
    }
    [[_app.session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *getAlbumResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *i in getAlbumResponse[@"response"][@"items"]){
            index++;
            NSString *bigPhoto;
            if(i[@"photo_807"]){
                bigPhoto = i[@"photo_807"];
            }
            else if(i[@"photo_604"] && !i[@"photo_807"]){
                bigPhoto = i[@"photo_604"];
            }
            [albumsData addObject:@{@"title": albumTitle,  @"owner_id":ownerId == nil?ownerId=_app.person:ownerId, @"items":@{@"index":[NSNumber numberWithInteger:index], @"id":i[@"id"], @"photo":i[@"photo_130"], @"photoBig":bigPhoto, @"caption":i[@"text"]}}];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            albumLoaded=YES;
            [collectionViewListAlbums setContent:albumsData];
            [collectionViewListAlbums reloadData];
   
        });
        
    }] resume];
}

-(void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    NSEvent *currentEvent = [NSApp currentEvent];
    if(!albumLoaded){
        NSLog(@"%@", [albumsData objectsAtIndexes:[collectionViewListAlbums selectionIndexes]]);
        if(!([currentEvent modifierFlags] & NSCommandKeyMask) && [[collectionViewListAlbums selectionIndexes]count]==1){
            albumTitle =[[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject][@"title"];
            selectedAlbumToLoad = [[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject][@"id"];
            [self loadSelectedAlbum:selectedAlbumToLoad];
        }
    }
    else{
        if(!loadForAttachments && !([currentEvent modifierFlags] & NSCommandKeyMask) && [[collectionViewListAlbums selectionIndexes]count]==1){
            myWindowContr = [self.storyboard instantiateControllerWithIdentifier:@"PhotoController"];
            
            [myWindowContr showWindow:self];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"ShowPhotoSlider" object:nil userInfo:@{@"data":albumsData, @"current":[[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject][@"items"][@"index"]}];
            [collectionView deselectItemsAtIndexPaths:indexPaths];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addToAttachments" object:nil userInfo:@{@"type":@"photo", @"data":[[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject]}];
        }
    }
}

-(void)loadFriends{
    __block NSMenu *menu1 = [[NSMenu alloc]init];
    __block  NSMenuItem *menuItem;
    if(!_loadFromFullUserInfo){
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/friends.get?owner_id=%@&v=%@&fields=city,domain,photo_50,photo_100&access_token=%@", _app.person, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *getFriendsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for(NSDictionary *i in getFriendsResponse[@"response"][@"items"]){
                [friends addObject:@{@"full_name":[NSString stringWithFormat:@"%@ %@", i[@"first_name"], i[@"last_name"]], @"id":i[@"id"]}];
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
//                [friendsListDropdown removeAllItems];
                [friendsListDropdown setMenu:menu1];
            });
        }]resume];
    }else{
        [friends addObject:@{@"full_name":[NSString stringWithFormat:@"%@", _userDataFromFullUserInfo[@"full_name"]], @"id":_userDataFromFullUserInfo[@"id"]}];
        viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
        [viewControllerItem loadView];
        menuItem = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"%@", _userDataFromFullUserInfo[@"full_name"]] action:nil keyEquivalent:@""];
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:_userDataFromFullUserInfo[@"user_photo"]]];
        image.size=NSMakeSize(30,30);
        [menuItem setImage:image];
        viewControllerItem.photo.wantsLayer=YES;
        viewControllerItem.photo.layer.masksToBounds=YES;
        viewControllerItem.photo.layer.cornerRadius=39/2;
        [viewControllerItem.photo setImageScaling:NSImageScaleProportionallyUpOrDown];
        viewControllerItem.nameField.stringValue=[NSString stringWithFormat:@"%@", _userDataFromFullUserInfo[@"full_name"]];
        [viewControllerItem.photo setImage:image];
        [menuItem setView:[viewControllerItem view]];
        [menu1 addItem:menuItem];
        [friendsListDropdown setMenu:menu1];
      
    }
}

-(void)loadAlbums{
    [albumsData removeAllObjects];
     [albumsData2 removeAllObjects];
    [albumsListDropdown removeAllItems];
    nameSelectedObject = @"albums";
    __block NSString *url;
     NSMutableArray *itemTitles=[[NSMutableArray alloc]init];
    albumLoaded=NO;
    ownerId = ownerId == nil ? _app.person : ownerId;
    
    url =[NSString stringWithFormat:@"https://api.vk.com/method/photos.getAlbums?owner_id=%@&need_covers=1&need_system=1&v=%@&access_token=%@", ownerId, _app.version, _app.token];
    
    
    [[_app.session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *getAlbumsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *i in getAlbumsResponse[@"response"][@"items"]){
             NSMutableDictionary *object = [[NSMutableDictionary alloc]initWithDictionary:@{@"id":i[@"id"], @"owner":i[@"owner_id"], @"cover":i[@"thumb_src"], @"title":i[@"title"], @"size":i[@"size"], @"busy":@0,@"user_groups":groupsListPoupData}];
            [albumsData addObject:object];
            [albumsData2 addObject:object];
            [itemTitles addObject:i[@"title"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                [albumsListDropdown addItemWithTitle:i[@"title"]];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [collectionViewListAlbums setContent:albumsData];
            [collectionViewListAlbums reloadData];
        });
        
    }] resume];
}

-(NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if([albumsData count]>0){
        return [albumsData count];
    }
    return 0;
}

-(NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    customViewCollectionItem *videoAlbumsItem = (customViewCollectionItem *)[collectionView makeItemWithIdentifier:@"ShowPhotoViewController" forIndexPath:indexPath];
    if([albumsData count]>0){
        NSAttributedString *attrTitle;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.alignment=NSTextAlignmentCenter;
        if([nameSelectedObject isEqualToString:@"albums"]){
             videoAlbumsItem.textLabel.hidden=NO;
             NSString *albumCover = [albumsData objectAtIndex:indexPath.item][@"cover"];
             NSString *albumName = [albumsData objectAtIndex:indexPath.item][@"title"];
            videoAlbumsItem.attachAlbum.hidden = loadForAttachments ? NO : YES;
            attrTitle = [[NSAttributedString alloc]initWithString:albumName attributes:@{NSForegroundColorAttributeName:videoAlbumsItem.isSelected ? [NSColor whiteColor] : [NSColor blackColor], NSParagraphStyleAttributeName:paragraphStyle}];
            videoAlbumsItem.textLabel.attributedStringValue=attrTitle;
            NSAttributedString *countAttrString = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@", [albumsData objectAtIndex:indexPath.item][@"size"] ]attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSParagraphStyleAttributeName:paragraphStyle}];
            videoAlbumsItem.countInAlbum.attributedStringValue=countAttrString;
            videoAlbumsItem.countInAlbum.hidden=NO;
            if(loadForAttachments){
                [videoAlbumsItem.downloadButton removeFromSuperview];
                [videoAlbumsItem.uploadPhoto removeFromSuperview];
                [videoAlbumsItem.removeItem removeFromSuperview];
                [videoAlbumsItem.moveToAlbumBut removeFromSuperview];
                [videoAlbumsItem.uploadByURLsButton removeFromSuperview];
                [videoAlbumsItem.downloadAndUploadStatusOver removeFromSuperview];
            }else{
                if([albumsData[indexPath.item][@"busy"] intValue]){
                    videoAlbumsItem.downloadAndUploadStatusOver.hidden=NO;
                    
                }else{
                    videoAlbumsItem.downloadAndUploadStatusOver.hidden=YES;
                }
            }
            videoAlbumsItem.albumsCover.image = nil;
            if([cachedImage count]>0 && cachedImage[[albumsData objectAtIndex:indexPath.item]]!=nil){
                [videoAlbumsItem.albumsCover setImage:cachedImage[[albumsData objectAtIndex:indexPath.item]]];
            }else{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:albumCover]];
                    NSImageRep *rep = [[image representations] objectAtIndex:0];
                    NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
                    image.size=imageSize;
                    cachedImage[[albumsData objectAtIndex:indexPath.item]]=image;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [videoAlbumsItem.albumsCover setImage:image];
                    });
                });
            }
        }
        else{
            videoAlbumsItem.attachAlbum.hidden=YES;
            videoAlbumsItem.albumsCover.image = nil;
            videoAlbumsItem.textLabel.hidden=YES;
            videoAlbumsItem.countInAlbum.hidden=YES;
            if([cachedImage count]>0 && cachedImage[[albumsData objectAtIndex:indexPath.item]]!=nil){
                [videoAlbumsItem.albumsCover setImage:cachedImage[[albumsData objectAtIndex:indexPath.item]]];
            }else{
                NSString *photo = [albumsData objectAtIndex:indexPath.item][@"items"][@"photo"];
                videoAlbumsItem.countInAlbum.hidden=YES;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:photo]];
                    NSImageRep *rep = [[image representations] objectAtIndex:0];
                    NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
                    image.size=imageSize;
                    cachedImage[[albumsData objectAtIndex:indexPath.item]]=image;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        videoAlbumsItem.albumsCover.image=image;
                    });
                });
            }
        }
    }
    return videoAlbumsItem;
}
@end
