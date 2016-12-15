//
//  AppStartSettingsMainViewController.h
//  MasterAPI
//
//  Created by sim on 13.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "keyHandler.h"
#import "TwitterRWData.h"
#import "YoutubeRWData.h"
#import "TumblrRWData.h"
#import "InstagramRWD.h"
@interface AppStartSettingsMainViewController : NSViewController{
    
    __weak IBOutlet NSTextField *VKStatusLabel;
    __weak IBOutlet NSTextField *YoutubeStatusLabel;
    __weak IBOutlet NSTextField *TwitterStatusLabel;
    __weak IBOutlet NSTextField *TumblrStatusLabel;
    __weak IBOutlet NSTextField *InstagramStatusLabel;
    InstagramRWD *instaRWD;
}
@property(nonatomic)keyHandler *VKKeyHandler;
@property(nonatomic)TwitterRWData *twitterRWD;
@property(nonatomic)YoutubeRWData *youtubeRWD;
@property(nonatomic)TumblrRWData *tumblrRWD;
@end
