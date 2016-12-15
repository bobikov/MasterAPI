//
//  VideoPlayerViewController.h
//  vkapp
//
//  Created by sim on 26.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <WebKit/WebKit.h>
#import "appInfo.h"
//@import AVFoundation;
//@import AVKit;
@interface VideoPlayerViewController : NSViewController{
    NSString *coverURL;
 
//    __weak IBOutlet NSButton *closeWindow;
}

@property (nonatomic, readwrite) NSDictionary *recivedData;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerView *playerView;
@property (weak) IBOutlet WebView *WebView;
@property (nonatomic)appInfo *app;

@end
