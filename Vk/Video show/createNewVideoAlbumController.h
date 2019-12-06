//
//  createNewVideoAlbumController.h
//  vkapp
//
//  Created by sim on 06.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "VKCaptchaHandler.h"

@interface createNewVideoAlbumController : NSViewController{
    
    __weak IBOutlet NSTextField *newAlbumTitle;
    
    __weak IBOutlet NSBox *radioBox;
    __weak IBOutlet NSButton *createButton;
    __weak IBOutlet NSButton *radioAll;
    __weak IBOutlet NSButton *radioFriends;
    __weak IBOutlet NSButton *radioNobody;
    __weak IBOutlet NSPopUpButton *groupsByAdminPopupSelector;
    NSMutableArray *groupsByAdminSelectorData;
    NSString *owner;
    NSArray *albumNames;
    NSInteger albumNamesCounter;
    __weak IBOutlet NSButton *multiple;
    dispatch_semaphore_t semaphore;
    BOOL stopFlag;
    NSString *albumName;
    __weak IBOutlet NSProgressIndicator *progressBar;
}

@property(nonatomic)appInfo *app;
@property(nonatomic) NSDictionary *receivedDataForNewAlbum;
@property(nonatomic)VKCaptchaHandler *captchaHandle;
@property(nonatomic)NSString *ownerInMainVideoController;
@property(nonatomic)NSString *selectedAlbumNames;
@end
