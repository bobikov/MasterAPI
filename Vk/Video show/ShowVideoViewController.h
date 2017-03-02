//
//  ShowVideoViewController.h
//  vkapp
//
//  Created by sim on 25.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "CustomVideoCollectionItem.h"
#import "CustomAnimator.h"
#import "VideoPlayerViewController.h"
#import "MyVideoWindowController.h"
#import "groupsHandler.h"
#import "ViewControllerMenuItem.h"
#import "KBButton.h"
@interface ShowVideoViewController : NSViewController{
    __weak IBOutlet NSButton *safeModeSearch;
    __weak IBOutlet NSCollectionView *collectionViewListAlbums;
    __weak IBOutlet NSSearchField *searchBar;
    __weak IBOutlet NSScrollView *scrollView;
    __weak IBOutlet NSPopUpButton *groupsPopupList;
    __weak IBOutlet NSPopUpButton *albumsDropdownList;
    __weak IBOutlet NSSegmentedControl *searchSource;
    //    NSMutableArray *finalSortedAlbums;
    __weak IBOutlet NSClipView *videoAlbumsClipView;
    __weak IBOutlet NSButton *totalCount;
    __weak IBOutlet NSButton *searchResultCount;
    __weak IBOutlet NSPopUpButton *friendsListDropdown;
    __weak IBOutlet NSTextField *publicIdFromShow;
    __weak IBOutlet NSButton *showAlbumsFromButton;
    //    __weak IBOutlet NSButton *backToAlbums;
    __weak IBOutlet KBButton *backToAlbums;
    
    NSMutableArray
        *videoAlbums,
        *videoAlbumsCopy,
        *videoAlbums2,
        *photoInAlbumData,
        *indexPathss,
        *groupsPopupData,
        *videoAlbumsTemp,
        *friends;
    NSString
        *selectedVideoURL,
        *selectedVideoTitle,
        *selectedVideoCover,
        *countInAlbum,
        *selectedAlbum,
        *friendId,
        *publicIdFrom,
        *nameSelectedObject;
    BOOL
        albumLoaded,
        loadForAttachments,
        loadForVKAddToAlbum,
        searchGlobalMode,
        searchUserVideoMode,
        dragging,
        searchLocalVideo;
    int
        selectedAlbumOffset,
        offsetSearchCounter;
    NSInteger
        totalVideoInAlbum,
        offset;
    
    NSSet<NSIndexPath *> *indexPathsOfItemsBeingDragged;
    ViewControllerMenuItem *viewControllerItem;
}
@property(nonatomic)appInfo *app;
@property(strong) NSWindowController *myWinContr;
@property(strong) NSWindowController *myWinContr2;
@property(nonatomic)groupsHandler *groupsHandle;
@property(nonatomic,readwrite) NSDictionary *recivedDataForMessage;
@property(nonatomic,readwrite) NSDictionary *addSelectedAlbumVKSocial;
@property (strong)NSWindowController *windowController;
@property(nonatomic,readwrite)NSString *ownerId;
@property(nonatomic,readwrite)BOOL loadFromFullUserInfo;
@property(nonatomic,readwrite)BOOL loadFromWallPost;
@property(nonatomic,readwrite)NSDictionary *userDataFromFullUserInfo;
@end
