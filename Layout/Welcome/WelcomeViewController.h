//
//  WelcomeViewController.h
//  vkapp
//
//  Created by sim on 20.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LongPoll.h"
#import "appInfo.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface WelcomeViewController : NSViewController{
    NSString *serverTs;
    NSString *serverBaseUrl;
    NSString *serverKey;
    NSString *serverUrl;
    int counterd ;
    int longPollSecs;
    
   
    __weak IBOutlet NSButton *radio;
}
@property(nonatomic) LongPoll *longPollingConnection;
@property (nonatomic) appInfo *app;
@property (strong, nonatomic) AVAudioPlayer *player;
@end
