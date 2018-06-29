//
//  moveToAlbumViewController.h
//  vkapp
//
//  Created by sim on 09.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"

@interface moveToAlbumViewController : NSViewController{
    
    __weak IBOutlet NSTableView *moveToAlbumTableView;
    NSMutableArray *albumsData;
    NSString *albumAdded;
    NSString *targetAlbum;
    __weak IBOutlet NSPopUpButton *groupsByAdminPopup;
    NSMutableArray *groupsByAdminPopupData;
    NSString *targetId;
    __weak IBOutlet NSScrollView *albumsListScrollView;
    __weak IBOutlet NSClipView *albumsListClipView;
    int offsetAlbums;
    BOOL stopFlag;
    BOOL next;
    NSMutableArray *videoIdsInAlbum;
     NSMutableArray *photoIdsInAlbum;
        NSInteger offsetCounter;
    __weak IBOutlet NSProgressIndicator *progressBar;
   
}




@property(nonatomic)appInfo *app;
@property(nonatomic,readwrite) NSString *videoId;
@property(nonatomic,readwrite) NSString *photoId;
@property(nonatomic,readwrite) NSString *ownerId;
@property(nonatomic, readwrite) NSString *countInAlbum;
@property(nonatomic,readwrite) NSString *albumIdToGetVideos;
@property(nonatomic,readwrite) NSString *type;
@property(nonatomic,readwrite) NSString *publicOrOwnerOfAlbums;
@property(nonatomic,readwrite) NSMutableArray *selectedItems;
@property(nonatomic,readwrite) NSString *mediaType;
@property(nonatomic,readwrite) BOOL savePhotoToSaved;
@end
