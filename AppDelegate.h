//
//  AppDelegate.h
//  vkapp
//
//  Created by sim on 19.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "keyHandler.h"
#import "appInfo.h"
#import "TumblrAuth.h"
#import "TumblrClient.h"
#import "TwitterAuth.h"
#import "TwitterClient.h"
#import "YoutubeClient.h"
#import "YoutubeAuth.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic) keyHandler *keyHandle;
@property (nonatomic, strong) NSWindowController *AppsStartSettingsWindowController;
@property (nonatomic, strong) NSWindowController *superWindowController;
@property (nonatomic) appInfo *app;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(readwrite, nonatomic)TumblrAuth *tumblrAuth;
@property(readwrite, nonatomic)TumblrClient *tumblrClient;
@property(readwrite, nonatomic)TwitterAuth *twitterAuth;
@property(readwrite, nonatomic)TwitterClient *twitterClient;
@property(readwrite, nonatomic)YoutubeClient *youtubeClient;
@property(readwrite, nonatomic)YoutubeAuth *youtubeAuth;
@end

