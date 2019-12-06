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

#import "APIClientsProtocol.h"
@interface Headbar : NSViewController{
    APIClientsProtocol *protocol;
    __weak IBOutlet NSImageView *appIcon;
    __weak IBOutlet NSButton *globalSearch;
//    __weak IBOutlet NSButton *globalSearch;
    
    __weak IBOutlet NSButton *playImageButton;
    __weak IBOutlet NSImageView *mainProfilePhoto;
    __weak IBOutlet NSSlider *audioProgress;
    __weak IBOutlet NSTextField *nameOfCurrentTrack;
    __weak IBOutlet NSTextField *audioTimer;
    __weak IBOutlet NSButton *postButton;
    __weak IBOutlet NSButton *tasksButton;
    
    NSString
        *currentUrl,
        *currentDuration,
        *elapsedTime,
        *nameOfCurrentPlaying;
    
    NSTimer *playTimer;
    
    BOOL isPlaying;
    NSMutableDictionary
        *playlist,
        *appPhotoURLs;
    
   
}
@property(nonatomic)appInfo *app;
@property (strong, nonatomic) AVPlayer *player;
@property (nonatomic) keyHandler *keyHandle;
-(void)loadVKMainInfo;
-(void)setProfileImage:(id)url;
@end
