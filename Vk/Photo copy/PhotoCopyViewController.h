//
//  PhotoCopyViewController.h
//  vkapp
//
//  Created by sim on 20.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"

#import "updatesHandler.h"
#import "VKCaptchaHandler.h"
@interface PhotoCopyViewController : NSViewController{
    
    __weak IBOutlet NSSearchField *searchBar;
    __weak IBOutlet NSSegmentedControl *searchSwitcher;
    __weak IBOutlet NSButton *captureText;
    __weak IBOutlet NSTextField *publicId;
    __weak IBOutlet NSTextField *albumFromId;
    __weak IBOutlet NSTextField *albumToId;
    __weak IBOutlet NSTextField *count;
    __weak IBOutlet NSButton *showAlbumsFrom;
    __weak IBOutlet NSTextField *progressLabel;
    __weak IBOutlet NSButton *copy;
    __weak IBOutlet NSButton *stop;
    __weak IBOutlet NSButton *reset;
    __weak IBOutlet NSProgressIndicator *progress;
    __weak IBOutlet NSTableView *fromTableView;
    __weak IBOutlet NSComboBox *privacyList;
    __weak IBOutlet NSTableView *toTableView;
    NSMutableArray *personalAlbums;
    NSMutableArray *fromOwnerAlbums;
    NSString *albumToCopyTo;
    NSString *albumToCopyFrom;
    NSString *publicIdFrom;
    NSInteger countPhotos;
    NSString *targetAlbumId;
    NSString *urlPhotoCopy;
    NSString *urlPhotoEdit;
    NSString *updateDate;
    NSString *photoIdToCopy;
    NSString *capturedText;
    NSString *newAlbumName;
    updatesHandler *handleUpdate;
    BOOL captchaOpened;
    BOOL stoppedAttachLoop;
    VKCaptchaHandler *captchaHandler;
    NSString *privacy_view;
    int publicIdIntTemp;
    NSInteger step;
    BOOL stopped;
    __weak IBOutlet NSPopUpButton *groupsPopupList;
    NSMutableArray *groupsPopupData;
    BOOL runPhotoCopy;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    dispatch_semaphore_t semaphore;
    NSString *ownerID;
    NSString *albumFromTitle;
    
}


@property(nonatomic) appInfo *app;
@property (strong) IBOutlet NSArrayController *arrayController1;
@property (strong) IBOutlet NSArrayController *arrayController2;

@end
