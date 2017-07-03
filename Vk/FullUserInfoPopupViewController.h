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
    __weak IBOutlet NSImageView *profilePhoto;
    __weak IBOutlet NSProgressIndicator *imageProgress;
    __weak IBOutlet NSTextField *userIdField;
    __weak IBOutlet NSTextField *fullName;
    __weak IBOutlet NSTextField *friendsCount;
    __weak IBOutlet NSTextField *books;
    __weak IBOutlet NSTextField *site;
    __weak IBOutlet NSTextField *mobile;
    __weak IBOutlet NSTextField *about;
    __weak IBOutlet NSImageView *verified;
    __weak IBOutlet NSTextField *Music;
    __weak IBOutlet NSTextField *education;
    __weak IBOutlet NSTextField *school;
    __weak IBOutlet NSTextField *quotes;
    __weak IBOutlet NSTextField *blacklisted;
    

    __weak IBOutlet NSTextField *relation;
    __weak IBOutlet NSTextField *lastSeen;
    __weak IBOutlet NSTextField *city;
    __weak IBOutlet NSTextField *country;
    __weak IBOutlet NSTextField *age;
    __weak IBOutlet NSTextField *subscribersCount;
//    NSInteger friendsCount;
    __weak IBOutlet NSTextField *lastSeenLabel;
    __weak IBOutlet NSTextField *photosCount;
    __weak IBOutlet NSTextField *groupsCount;
    __weak IBOutlet NSTextField *videosCount;
    __weak IBOutlet NSTextField *page;
    NSWindow *mainWindow;
}

@property(nonatomic)appInfo *app;
@property(nonatomic, readwrite)NSDictionary *receivedData;
@property(nonatomic) StringHighlighter *stringHighlighter;
@property(nonatomic, strong)NSWindowController *windowController;
-(void)setToViewController;
@end
