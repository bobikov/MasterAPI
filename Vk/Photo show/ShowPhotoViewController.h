//
//  ShowPhotoViewController.h
//  vkapp
//
//  Created by sim on 25.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "customViewCollectionItem.h"
#import "MyPhotoWindowController.h"
#import "ViewControllerMenuItem.h"
@interface ShowPhotoViewController : NSViewController{
__weak IBOutlet NSCollectionView *collectionViewListAlbums;
    NSMutableArray *albumsData;
    NSMutableArray *albumsData2;
    NSMutableArray *photoInAlbumData;
    BOOL albumLoaded;
    __weak IBOutlet NSButton *backToAlbums;
    __weak IBOutlet NSPopUpButton *albumsListDropdown;
    __weak IBOutlet NSPopUpButton *friendsListDropdown;
    NSMutableArray *friends;
    NSString *friendId ;
    NSString *albumTitle;
    NSString *selectedAlbumToLoad;
    NSMutableArray *groupsListPoupData;
    __weak IBOutlet NSPopUpButton *groupsListPopup;
    __weak IBOutlet NSTextField *ownerField;
    __weak IBOutlet NSSearchField *searchBar;

    ViewControllerMenuItem *viewControllerItem;
    NSMutableDictionary *cachedImage;
    NSString *nameSelectedObject;
   
   
}
@property(nonatomic)appInfo *app;
@property(strong) NSWindowController *myWindowContr;
@property(nonatomic) NSString *ownerId;
@property(nonatomic,readwrite) BOOL loadFromFullUserInfo;
@property(nonatomic,readwrite) BOOL loadFromWallPost;
@property(nonatomic,readwrite) NSDictionary *receivedData;
@property(nonatomic,readwrite) NSDictionary *userDataFromFullUserInfo;
@property(nonatomic,readwrite) BOOL loadForAttachments;
@end
