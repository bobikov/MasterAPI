//
//  VKLoginViewController.h
//  vkapp
//
//  Created by sim on 17.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <WebKit/WebKit.h>
#import "appInfo.h"
#import "keyHandler.h"

@interface VKLoginViewController : NSViewController{
    __weak IBOutlet NSTextField *appId;
   
    __weak IBOutlet NSProgressIndicator *progressLoad;
    __weak IBOutlet NSButton *addApp;
    NSString *app_id;
    NSString *user_id;
    NSString *url;
    NSString *currentURL;
    NSString *token;
    NSString *version;
    NSWindow *superWindow;
    NSString *authorUrl;
    NSString *icon;
    NSString *title;
    NSString *screenName;
    NSString *desc;
    NSArray *apps;
    NSManagedObject *prevObject;
    BOOL selected;
    __weak IBOutlet NSPopUpButton *appList;
    __weak IBOutlet NSButton *backToInfoButton;
    NSManagedObjectContext *moc;
    __weak IBOutlet NSPopUpButton *advancedOptions;
}
@property (weak) IBOutlet WebView *WebView;
@property (nonatomic) keyHandler *keyHandle;
@property (nonatomic, strong) NSWindowController *superWindowController;
@property(nonatomic) appInfo *app;

@end
