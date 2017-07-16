//
//  FullUserInfoPopupViewController.h
//  vkapp
//
//  Created by sim on 02.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "StringHighlighter.h"
#import <JNWAnimatableWindow/JNWAnimatableWindow.h>
@interface FullUserInfoPopupViewController : NSViewController{
    NSString *userId;
    __weak IBOutlet NSTableView *userInfoValuesList;
    __weak IBOutlet NSImageView *profilePhoto;
    __weak IBOutlet NSProgressIndicator *imageProgress;
    __weak IBOutlet NSTextField *fullName;
    __weak IBOutlet NSTextField *friendsCount;
    __weak IBOutlet NSImageView *verified;
    __weak IBOutlet NSTextField *blacklisted;
    __weak IBOutlet NSTextField *lastSeen;
    __weak IBOutlet NSTextField *subscribersCount;
    __weak IBOutlet NSTextField *lastSeenLabel;
    __weak IBOutlet NSTextField *photosCount;
    __weak IBOutlet NSTextField *groupsCount;
    __weak IBOutlet NSTextField *videosCount;
    
    NSWindow *mainWindow;
    NSMutableDictionary *userInfoData;
    NSMutableArray *fieldNames;
}

@property(nonatomic)appInfo *app;
@property(nonatomic, readwrite)NSDictionary *receivedData;
@property(nonatomic) StringHighlighter *stringHighlighter;
@property(nonatomic, strong)NSWindowController *windowController;
-(void)setToViewController;
@end
