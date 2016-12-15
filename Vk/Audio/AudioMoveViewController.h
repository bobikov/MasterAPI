//
//  AudioMoveViewController.h
//  vkapp
//
//  Created by sim on 18.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "MoveListAlbumsViewController.h"
@interface AudioMoveViewController : NSViewController{
    NSMutableArray *audioListData;
    NSMutableArray *audioListDataCopy;
    NSMutableArray *albumsListData;
    __weak IBOutlet NSSearchField *searchBar;
    
    __weak IBOutlet NSTextField *removeMultipleAudiosLabel;
    __weak IBOutlet NSProgressIndicator *removeMultipleAudiosProgressBar;
    __weak IBOutlet NSButton *removeMultipleAlbumsBut;
    __weak IBOutlet NSButton *removeMultipleAudiosBut;
    __weak IBOutlet NSButton *removeAudiosInAlbumCheck;
    __weak IBOutlet NSTableView *albumsList;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    __weak IBOutlet NSButton *moveButton;
    __weak IBOutlet NSTableView *audioList;
    __weak IBOutlet NSTextField *selectedAlbumMoveTo;
    NSInteger offsetLoadAudiolist;
    __weak IBOutlet NSScrollView *audioListScroll;
    __weak IBOutlet NSClipView *clipOfAlbums;
    NSString *currentAlbumLoaded;
    NSMutableArray *albumsListDataCopy;
    BOOL searchMode;
    __weak IBOutlet NSClipView *clipOfAudiolist;
     NSInteger sourceIndex;
    __weak IBOutlet NSSearchField *albumSearchBar;
    int searchAudioOffset;
    __weak IBOutlet NSPopUpButton *userGroupsByAdminPopup;
    NSMutableArray *userGroupsByAdminData;
    NSString *owner;
    __weak IBOutlet NSButton *restoreAllAudiosBut;
    NSMutableArray *audiosForRestore;
}
@property(nonatomic)appInfo *app;
@end
