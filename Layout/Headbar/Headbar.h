//
//  Headbar.h
//  vkapp
//
//  Created by sim on 02.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
//#import <AVFoundation/AVAudioSession.h>
#import "VolumeView.h"
#import "appInfo.h"
#import "keyHandler.h"
#import "KBButton.h"
@interface Headbar : NSViewController{
    
    __weak IBOutlet NSImageView *appIcon;
    __weak IBOutlet KBButton *globalSearch;
//    __weak IBOutlet NSButton *globalSearch;
    BOOL isPlaying;
    __weak IBOutlet NSButton *playImageButton;
    __weak IBOutlet NSImageView *mainProfilePhoto;
    __weak IBOutlet NSSlider *audioProgress;
    __weak IBOutlet NSTextField *nameOfCurrentTrack;
    __weak IBOutlet NSTextField *audioTimer;
    __weak IBOutlet KBButton *postButton;
    NSString *currentUrl;
    NSString *currentDuration;
    NSString *elapsedTime;
    NSTimer *playTimer;
    NSString *nameOfCurrentPlaying;
    NSMutableDictionary *playlist;
    __weak IBOutlet KBButton *tasksButton;
   
}
@property(nonatomic)appInfo *app;
@property (strong, nonatomic) AVPlayer *player;
@property (nonatomic) keyHandler *keyHandle;
-(void)loadMainInfo;
-(void)setProfileImage:(id)url;
@end
