//
//  VideoCopyViewController.h
//  vkapp
//
//  Created by sim on 20.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "VKCaptchaHandler.h"
@interface VideoCopyViewController : NSViewController{
    
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
    NSMutableArray *videoAlbums;
    NSMutableArray *videoAlbums2;
    NSString *targetVideoAlbumId;
    BOOL stopFlag;
    NSString *title1;
    NSString *title2;
    NSString *videoPublicTitleNewAlbum;

   
    __weak IBOutlet NSTextField *progressLabel;
    __weak IBOutlet NSProgressIndicator *progressSpin;
}
@property(nonatomic)appInfo *app;
@property(nonatomic, readwrite)VKCaptchaHandler *captchaHandler;
@end
