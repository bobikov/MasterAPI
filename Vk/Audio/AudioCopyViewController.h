//
//  AudioViewController.h
//  vkapp
//
//  Created by sim on 15.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "updatesHandler.h"
@interface AudioCopyViewController : NSViewController{
    NSMutableArray *audioListData1;
    NSMutableArray *audioListData2;
    NSString *albumToCopyTo;
    NSString *albumToCopyFrom;
    __weak IBOutlet NSSearchField *searchBar;
    __weak IBOutlet NSSegmentedControl *searchSwitcher;
    __weak IBOutlet NSComboBox *privacyList;
    __weak IBOutlet NSTextField *publicId;
    __weak IBOutlet NSTextField *albumFromId;
    __weak IBOutlet NSTextField *albumToId;
    __weak IBOutlet NSTextField *count;
    __weak IBOutlet NSButton *showAlbumsFrom;
    __weak IBOutlet NSButton *copy;
    __weak IBOutlet NSButton *stop;
    __weak IBOutlet NSButton *reset;
    __weak IBOutlet NSProgressIndicator *progress;
    __weak IBOutlet NSTableView *fromTableView;
    __weak IBOutlet NSTableView *toTableView;
    NSString *targetAudioAlbumId;
    BOOL stopFlag;
    NSString *title1;
    NSString *title2;
    NSString *audioTitleNewAlbum;
    BOOL stopped;
    
    __weak IBOutlet NSTextField *progressLabel;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    
}
@property(nonatomic)appInfo *app;
@property (strong) IBOutlet NSArrayController *arrayController;
@property (strong) IBOutlet NSArrayController *arrayController2;

@end
