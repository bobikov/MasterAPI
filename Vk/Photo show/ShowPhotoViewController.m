//
//  ShowPhotoViewController.m
//
//  Created by sim on 25.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "ShowPhotoViewController.h"
#import "CreateNewAlbumController.h"
#import "GroupsFromFileViewController.h"
#import "NSImage+Resizing.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImage+MultiFormat.h>
#import "SYFlatButton+ButtonsStyle.h"
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
    albumsDataCopy = [[NSMutableArray alloc]init];
    
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

    //     NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:favesScrollView.frame xRadius:4 yRadius:4];
    CAShapeLayer * layer = [CAShapeLayer layer];
    
    layer.cornerRadius=4;
    layer.borderWidth=1;
    layer.borderColor=[[NSColor colorWithWhite:0.8 alpha:1]CGColor];
    collectionViewListAlbums.enclosingScrollView.wantsLayer = TRUE;
    collectionViewListAlbums.enclosingScrollView.layer = layer;
    
    SYFlatButton *backBut = (SYFlatButton*)backToAlbums;
    [backBut simpleButton:backBut];
}

- (void)viewDidAppear{
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
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"createPhotoAlbumSeague"]){
        CreateNewAlbumController *controller = (CreateNewAlbumController *)segue.destinationController;
        
        controller.receivedDataForNewAlbum=@{@"owner":ownerId == nil ? ownerId=_app.person : ownerId};
    }
    else if([segue.identifier isEqualToString:@"GroupsFromFileSeguePhoto"]){
        
        
        
        GroupsFromFileViewController *controller = (GroupsFromFileViewController *)segue.destinationController;
        controller.recivedData=@{@"type":@"photo"};
    }
}
- (void)loadGroupsPopup{
    __block NSMenu *menu1 = [[NSMenu alloc]init];
    __block  NSMenuItem *menuItem;
    [groupsListPopup removeAllItems];
    [groupsListPoupData addObject:_app.person];
    viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
    [viewControllerItem loadView];
    menuItem = [[NSMenuItem alloc]initWithTitle:@"Personal" action:nil keyEquivalent:@""];
    viewControllerItem.nameField.stringValue=@"Personal";
    [menuItem setView:[viewControllerItem view]];
    [menu1 addItem:menuItem];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
                    [groupsListPoupData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
                    viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
                    [viewControllerItem loadView];
                    menuItem = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"%@", i[@"name"]] action:nil keyEquivalent:@""];
                    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:i[@"photo_50"]]];
                    image.size=NSMakeSize(30,30);
                    [menuItem setImage:image];
                    dispatch_async(dispatch_get_main_queue(),^{
                        viewControllerItem.photo.wantsLayer=YES;
                        viewControllerItem.photo.layer.masksToBounds=YES;
                        viewControllerItem.photo.layer.cornerRadius=39/2;
                        [viewControllerItem.photo setImageScaling:NSImageScaleProportionallyUpOrDown];
                        viewControllerItem.nameField.stringValue=[NSString stringWithFormat:@"%@", i[@"name"]];
                         [viewControllerItem.photo setImage:image];
                    });
                    [menuItem setView:[viewControllerItem view]];
                    [menu1 addItem:menuItem];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [groupsListPopup setMenu:menu1];
                });
            }
        }]resume];
    });
}
- (IBAction)groupsListPopup:(id)sender {
    ownerId=[groupsListPoupData objectAtIndex:[groupsListPopup indexOfSelectedItem]];
    [self loadAlbums];
}
- (void)removeObject:(NSNotification*)notification{
//    [self loadSelectedAlbum:selectedAlbumToLoad];
    dispatch_async(dispatch_get_main_queue(),^{
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[notification.userInfo[@"index"] intValue] inSection:0];
        [albumsData removeObjectAtIndex:[notification.userInfo[@"index"] intValue]];
        [collectionViewListAlbums deleteItemsAtIndexPaths:[NSSet setWithObject:indexPath]];
        collectionViewListAlbums.content=albumsData;
        
    });
}
- (void)removePhotoAlbum:(NSNotification*)notification{
    dispatch_async(dispatch_get_main_queue(),^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[notification.userInfo[@"index"] intValue] inSection:0];
        [albumsData removeObjectAtIndex:[notification.userInfo[@"index"] intValue]];
        [collectionViewListAlbums deleteItemsAtIndexPaths:[NSSet setWithObject:indexPath]];
        collectionViewListAlbums.content=albumsData;

    });
}
- (void)createAlbumReload:(NSNotification*)notification{
    [self loadAlbums];
}
- (void)loadMembershipGroupAlbum:(NSNotification *)notification{
    ownerId = [NSString stringWithFormat:@"-%@", notification.userInfo[@"id"]];
    [self loadAlbums];
}
- (void)searchFieldDidStartSearching:(NSSearchField *)sender{
    [self loadSearchVideo];
}
- (void)searchFieldDidEndSearching:(NSSearchField *)sender{
    [self loadAlbums];
}
- (void)loadSearchVideo{
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
            [albumsData removeAllObjects];
            albumsData = photoAlbumsTemp;
            [collectionViewListAlbums setContent:albumsData];
            [collectionViewListAlbums reloadData];
        }
    }
}

- (IBAction)backToAlbumsAction:(id)sender {
    friendId=nil;
    [self loadAlbums];
}
- (IBAction)showPhotoByOwner:(id)sender {
    if(![ownerField.stringValue isEqual:@""]){
        ownerId=ownerField.stringValue;
        [self loadAlbums];
    }
}
- (IBAction)albumsListDropdownAction:(id)sender {
    albumTitle = albumsDataCopy[[albumsListDropdown indexOfSelectedItem]][@"title"];
    [self loadSelectedAlbum:albumsDataCopy[[albumsListDropdown indexOfSelectedItem]][@"id"]] ;
//    NSLog(@"%@", albumsData[[albumsListDropdown indexOfSelectedItem]][@"id"]);
//    NSLog(@"%@", albumsData[[albumsListDropdown indexOfSelectedItem]]);
}
- (IBAction)friendsListDropdownAction:(id)sender {
    friendId = friends[[friendsListDropdown indexOfSelectedItem]][@"id"];
    ownerId= friendId;
    [self loadAlbums];
}
- (void)loadSelectedAlbum:(id)albumId{
    
    nameSelectedObject = @"album";
    [albumsData removeAllObjects];
//    [collectionViewListAlbums setContent:albumsData];
    NSLog(@"%@", albumTitle);
    NSString *url;
   __block NSInteger index=0;
    if(friendId!=nil){
        url=[NSString stringWithFormat:@"https://api.vk.com/method/photos.get?owner_id=%@&album_id=%@&v=%@&rev=1&access_token=%@", friendId, albumId, _app.version, _app.token];
    }
    else{
        url=[NSString stringWithFormat:@"https://api.vk.com/method/photos.get?owner_id=%@&album_id=%@&rev=1&v=%@&extended=1&access_token=%@", ownerId==nil ? _app.person : ownerId, albumId, _app.version, _app.token];
    }
    [[_app.session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *getAlbumResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            NSLog(@"%@", getAlbumResponse);
            
            for(NSDictionary *i in getAlbumResponse[@"response"][@"items"]){
                index++;
                NSString *bigPhoto;
                NSString *likesCount = [NSString stringWithFormat:@"%@", i[@"likes"][@"count"]];
                NSString *userLikesCount = [NSString stringWithFormat:@"%@", i[@"likes"][@"user_likes"]];
                NSString *prPhoto;
                
                for (NSDictionary *a in i[@"sizes"]){
                    if([a[@"type"] isEqual:@"y"]){
                        bigPhoto = a[@"url"];
                    }
                    else if([a[@"type"] isEqual:@"x"] && !bigPhoto){
                        bigPhoto = a[@"url"];
                    }
                    else if([a[@"type"] isEqual:@"m"]){
                        prPhoto = a[@"url"];
                    }
                 
                }

                NSMutableDictionary *object = [NSMutableDictionary dictionaryWithDictionary:@{@"title": albumTitle,  @"owner_id":ownerId == nil?_app.person:ownerId, @"items":[NSMutableDictionary dictionaryWithDictionary:@{@"index":[NSNumber numberWithInteger:index], @"id":i[@"id"], @"photo":prPhoto, @"photoBig":bigPhoto, @"caption":i[@"text"], @"likesCount":likesCount, @"userLikes":userLikesCount}]}];
                
                [albumsData addObject:object ];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                albumLoaded=YES;
                [collectionViewListAlbums setContent:albumsData];
                [collectionViewListAlbums reloadData];
                
            });
        }
    }] resume];
}
- (void)loadFriends{
    __block NSMenu *menu1 = [[NSMenu alloc]init];
    __block  NSMenuItem *menuItem;
    if(!_loadFromFullUserInfo){
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/friends.get?owner_id=%@&v=%@&fields=city,domain,photo_50,photo_100&access_token=%@", _app.person, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
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
            }
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
- (void)loadAlbums{
    
    [albumsData removeAllObjects];
    [albumsData2 removeAllObjects];

//    [collectionViewListAlbums setContent:albumsData];
    nameSelectedObject = @"albums";
    __block NSString *url;

    albumLoaded=NO;
    if(!_loadFromWallPost && !loadForAttachments && !_loadFromFullUserInfo && ((ownerId && [ownerId intValue]>0) || !ownerId)){
        ownerId = _app.person;
    }
    NSLog(@"%@", ownerId);
    
    url =[NSString stringWithFormat:@"https://api.vk.com/method/photos.getAlbums?owner_id=%@&need_covers=1&need_system=1&v=%@&access_token=%@", ownerId, _app.version, _app.token];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *getAlbumsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for(NSDictionary *i in getAlbumsResponse[@"response"][@"items"]){
                NSMutableDictionary *object = [[NSMutableDictionary alloc]initWithDictionary:@{@"id":i[@"id"], @"owner":i[@"owner_id"], @"cover":i[@"thumb_src"], @"title":i[@"title"], @"size":i[@"size"], @"busy":@0,@"user_groups":groupsListPoupData, @"desc":i[@"description"]!=nil?i[@"description"]:@""}];
                [albumsData addObject:object];
                [albumsData2 addObject:object];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadAlbumsDropDown];
                [collectionViewListAlbums setContent:albumsData];
                [collectionViewListAlbums reloadData];
            });
        }
    }] resume];
}
- (void)loadAlbumsDropDown{
    [albumsListDropdown removeAllItems];
    [albumsDataCopy removeAllObjects];
    if([albumsDataCopy count]==0){
        albumsDataCopy = [albumsData mutableCopy];
        for(NSDictionary *i in albumsDataCopy){
            NSMenuItem *menuItem = [[NSMenuItem alloc]initWithTitle:i[@"title"] action:nil keyEquivalent:@""];
//            [albumsListDropdown addItemWithTitle:i[@"title"]];
            [[albumsListDropdown menu] addItem:menuItem];
        }
    }
}


- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths{
    NSEvent *currentEvent = [NSApp currentEvent];
    if(!albumLoaded){
        NSInteger selectedItemIndex = [indexPaths allObjects][0].item;
        if(selectedItemIndex <= [albumsData count]){
            [albumsListDropdown selectItemAtIndex:selectedItemIndex];
            NSLog(@"%@", [albumsData objectsAtIndexes:[collectionViewListAlbums selectionIndexes]]);
            if(!([currentEvent modifierFlags] & NSCommandKeyMask) && [currentEvent type]!=NSLeftMouseDragged && [[collectionViewListAlbums selectionIndexes]count]==1){
                albumTitle =[[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject][@"title"];
                selectedAlbumToLoad = [[collectionViewListAlbums itemAtIndexPath:[indexPaths allObjects][0]] representedObject][@"id"];
                [self loadSelectedAlbum:selectedAlbumToLoad];
            }
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
- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return [albumsData count];
}
- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    customViewCollectionItem *photoAlbumsItem;

    if([albumsData count]>0){
        photoAlbumsItem = (customViewCollectionItem *)[collectionView makeItemWithIdentifier:@"ShowPhotoViewController" forIndexPath:indexPath];
        NSAttributedString *attrTitle;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.alignment=NSTextAlignmentCenter;
        if([nameSelectedObject isEqualToString:@"albums"]){
            photoAlbumsItem.textLabel.hidden=NO;
            NSString *albumCover = [albumsData objectAtIndex:indexPath.item][@"cover"];
            NSString *albumName = [albumsData objectAtIndex:indexPath.item][@"title"];
            photoAlbumsItem.attachAlbum.hidden = loadForAttachments ? NO : YES;
            attrTitle = [[NSAttributedString alloc]initWithString:albumName attributes:@{NSForegroundColorAttributeName:photoAlbumsItem.isSelected ? [NSColor whiteColor] : [NSColor blackColor], NSParagraphStyleAttributeName:paragraphStyle}];
            photoAlbumsItem.textLabel.attributedStringValue=attrTitle;
            NSAttributedString *countAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", [albumsData objectAtIndex:indexPath.item][@"size"] ]attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSParagraphStyleAttributeName:paragraphStyle}];
            photoAlbumsItem.countInAlbum.attributedStringValue=countAttrString;
            photoAlbumsItem.countInAlbum.hidden=NO;
            if(loadForAttachments){
                [photoAlbumsItem.downloadButton removeFromSuperview];
                [photoAlbumsItem.uploadPhoto removeFromSuperview];
                [photoAlbumsItem.removeItem removeFromSuperview];
                [photoAlbumsItem.moveToAlbumBut removeFromSuperview];
                [photoAlbumsItem.uploadByURLsButton removeFromSuperview];
                [photoAlbumsItem.downloadAndUploadStatusOver removeFromSuperview];
            }else{
                if([albumsData[indexPath.item][@"busy"] intValue]){
                    photoAlbumsItem.downloadAndUploadStatusOver.hidden=NO;
                    
                }else{
                    photoAlbumsItem.downloadAndUploadStatusOver.hidden=YES;
                }
            }
            photoAlbumsItem.albumsCover.image = nil;
//            if([cachedImage count]>0 && cachedImage[[albumsData objectAtIndex:indexPath.item]]!=nil){
//                [photoAlbumsItem.albumsCover setImage:cachedImage[[albumsData objectAtIndex:indexPath.item]]];
//            }else{
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:albumCover]];
//                    NSImageRep *rep = [[image representations] objectAtIndex:0];
//                    NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
//                    image.size=imageSize;
////                    double realImageWidth = imageSize.width;
////                    double realImageHeight = imageSize.height;
////                    NSLog(@"%@", albumCover );
////                    image = [image cropImageToSize:NSMakeSize(100, 100) fromPoint:NSZeroPoint];
//                    cachedImage[albumsData[indexPath.item]]=image;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [photoAlbumsItem.albumsCover setImage:image];
//                    });
//                });
//            }
         
//            [photoAlbumsItem.albumsCover sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:albumCover]placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//                
//            } completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//                NSImageRep *rep = [[image representations] objectAtIndex:0];
//                NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
//                image.size=imageSize;
//                photoAlbumsItem.albumsCover.image=image;
//                
//            }];
            
      
            //|SDWebImageProgressiveDownload
            [photoAlbumsItem.albumsCover  sd_setImageWithURL:[NSURL URLWithString:albumCover] placeholderImage:nil options:SDWebImageRefreshCached completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                NSImageRep *rep = [[image representations] objectAtIndex:0];
                NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
                image.size=imageSize;
                photoAlbumsItem.albumsCover.image=image;
            }];
            
        }
        else{
            photoAlbumsItem.attachAlbum.hidden=YES;
            photoAlbumsItem.albumsCover.image = nil;
            photoAlbumsItem.textLabel.hidden=YES;
            photoAlbumsItem.countInAlbum.hidden=YES;
//            if([cachedImage count]>0 && cachedImage[[albumsData objectAtIndex:indexPath.item]]!=nil){
//                [photoAlbumsItem.albumsCover setImage:cachedImage[[albumsData objectAtIndex:indexPath.item]]];
//            }else{
//                NSString *photo = [albumsData objectAtIndex:indexPath.item][@"items"][@"photo"];
//                photoAlbumsItem.countInAlbum.hidden=YES;
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    NSImage *image = [[[NSImage alloc]initWithContentsOfURL:
//                    NSImageRep *rep = [[image representations] objectAtIndex:0];
//                    NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
//                    image.size=imageSize;
////                     image = [image cropImageToSize:NSMakeSize(photoAlbumsItem.albumsCover.frame.size.width, photoAlbumsItem.albumsCover.frame.size.height) fromPoint:NSZeroPoint];
//                    if(image){
//                        cachedImage[[albumsData objectAtIndex:indexPath.item]]=image;
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            photoAlbumsItem.albumsCover.image=image;
//                        });
//                    }
//                });
//            }
            NSString *photo = [albumsData objectAtIndex:indexPath.item][@"items"][@"photo"];
//            [photoAlbumsItem.albumsCover sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:photo]placeholderImage:nil options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
//                
//            } completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
//                NSImageRep *rep = [[image representations] objectAtIndex:0];
//                NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
//                image.size=imageSize;
//                photoAlbumsItem.albumsCover.image=image;
//                
////            }];
            //|SDWebImageProgressiveDownload
            [photoAlbumsItem.albumsCover  sd_setImageWithURL:[NSURL URLWithString:photo] placeholderImage:nil options:SDWebImageRefreshCached completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                NSImageRep *rep = [[image representations] objectAtIndex:0];
                NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
                image.size=imageSize;
                photoAlbumsItem.albumsCover.image=image;
            }];
            
        }
    }
    return photoAlbumsItem;
}
@end
