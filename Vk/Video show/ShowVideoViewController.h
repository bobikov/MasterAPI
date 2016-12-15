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
@interface ShowVideoViewController : NSViewController{
    __weak IBOutlet NSButton *safeModeSearch;
    __weak IBOutlet NSCollectionView *collectionViewListAlbums;
    __weak IBOutlet NSSearchField *searchBar;
    NSMutableArray *videoAlbums;
    NSMutableArray *videoAlbums2;
    NSMutableArray *photoInAlbumData;
    BOOL albumLoaded;
    __weak IBOutlet NSButton *backToAlbums;
    NSString *selectedVideoURL;
    NSString *selectedVideoTitle;
    NSString *selectedVideoCover;
    __weak IBOutlet NSScrollView *scrollView;
    NSInteger offset;
    __weak IBOutlet NSPopUpButton *groupsPopupList;
    __weak IBOutlet NSPopUpButton *albumsDropdownList;
    __weak IBOutlet NSSegmentedControl *searchSource;
   
//    NSMutableArray *finalSortedAlbums;
    NSString *selectedAlbum;
    NSString *countInAlbum;
    __weak IBOutlet NSClipView *videoAlbumsClipView;
    __weak IBOutlet NSButton *totalCount;
    __weak IBOutlet NSButton *searchResultCount;
    __weak IBOutlet NSPopUpButton *friendsListDropdown;
    NSMutableArray *friends;
    NSString *friendId;
    __weak IBOutlet NSTextField *publicIdFromShow;
    __weak IBOutlet NSButton *showAlbumsFromButton;
    NSString *publicIdFrom;
    NSMutableArray *groupsPopupData;
    
    BOOL loadForAttachments;
    BOOL loadForVKAddToAlbum;
    int selectedAlbumOffset;
    BOOL searchGlobalMode;
    BOOL searchUserVideoMode;
    int offsetSearchCounter;
    BOOL dragging;
    NSSet<NSIndexPath *> *indexPathsOfItemsBeingDragged;
    NSMutableArray *indexPathss;
    ViewControllerMenuItem *viewControllerItem;
    NSMutableDictionary *cachedImage;
    NSString *nameSelectedObject;
     NSInteger totalVideoInAlbum;
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
