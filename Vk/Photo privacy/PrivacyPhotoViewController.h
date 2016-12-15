//
//  PrivacyPhotoViewController.h
//  vkapp
//
//  Created by sim on 22.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "VKCaptchaHandler.h"
@interface PrivacyPhotoViewController : NSViewController{
    
    __weak IBOutlet NSScrollView *scrollViewAlbumTables;
    NSMutableArray *photoAlbums;
  
    __weak IBOutlet NSProgressIndicator *progressSpin;
    __weak IBOutlet NSTableView *albumsTable;
    __weak IBOutlet NSComboBox *privacyList;
    __weak IBOutlet NSButton *deleteButton;
    __weak IBOutlet NSButton *changePrivacyBut;
    __weak IBOutlet NSButton *filterNobody;
    __weak IBOutlet NSButton *filterFriends;
    __weak IBOutlet NSButton *filterAll;
    NSMutableArray *foundData;
    NSMutableArray *tempData;
    BOOL stopped;
    NSMutableArray *groupsPopupData;
    __weak IBOutlet NSPopUpButton *groupsPopupList;
}
@property (weak) IBOutlet NSTextField *titleLabel;

@property(nonatomic)appInfo *app;
@property (strong) IBOutlet NSArrayController *arrayController;
@property (strong) IBOutlet NSArrayController *SearchResultsController;
@property(nonatomic, readwrite)VKCaptchaHandler *captchaHandler;
@end
