//
//  VideoPrivacyViewController.h
//  vkapp
//
//  Created by sim on 03.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "VKCaptchaHandler.h"
@interface VideoPrivacyViewController : NSViewController{
    
    __weak IBOutlet NSProgressIndicator *progressLoad;
    NSMutableArray *videoAlbums;
    __weak IBOutlet NSTableView *videoAlbumsList;
    __weak IBOutlet NSButton *change;
    __weak IBOutlet NSComboBox *privacyList;
    NSMutableArray *groupsPopupData;
    __weak IBOutlet NSPopUpButton *groupsPopupList;
    __weak IBOutlet NSButton *filterNobody;
    __weak IBOutlet NSButton *filterFriends;
    __weak IBOutlet NSButton *filterAll;
    NSMutableArray *foundData;
    NSMutableArray *tempData;
}
@property(nonatomic) appInfo *app;
@property (strong) IBOutlet NSArrayController *arrayController;
@property(nonatomic,readwrite)VKCaptchaHandler *captchaHandler;
@end
