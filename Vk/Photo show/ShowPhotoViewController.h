//
//  ShowPhotoViewController.h
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
//    __weak IBOutlet NSButton *backToAlbums;
    __weak IBOutlet NSButton *backToAlbums;
    __weak IBOutlet NSPopUpButton *albumsListDropdown;
    __weak IBOutlet NSPopUpButton *friendsListDropdown;
    __weak IBOutlet NSPopUpButton *groupsListPopup;
    __weak IBOutlet NSTextField *ownerField;
    __weak IBOutlet NSSearchField *searchBar;
    
    NSMutableArray
        *albumsData,
        *photoInAlbumData,
        *albumsData2,
        *friends,
        *albumsDataCopy,
        *groupsListPoupData;
    NSString
        *friendId,
        *nameSelectedObject,
        *albumTitle,
        *selectedAlbumToLoad;
 
     BOOL albumLoaded;

    ViewControllerMenuItem *viewControllerItem;
    NSMutableDictionary *cachedImage;
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
