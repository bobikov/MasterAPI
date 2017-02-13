//
//  ShowDocViewController.m
//  vkapp
//
//  Created by sim on 09.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "ShowDocViewController.h"

@interface ShowDocViewController ()

@end

@implementation ShowDocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
//    self.view.window.titleVisibility=NSWindowTitleVisible;
//    self.view.window.titlebarAppearsTransparent = YES;
//    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
//    self.view.window.movableByWindowBackground=YES;
//    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];

     NSLog(@"%@", _receivedData);
    
}
-(void)viewDidAppear{
    self.view.window.titleVisibility=NSWindowTitleVisible;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    self.view.window.movableByWindowBackground=YES;
    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    self.title =_receivedData[@"title"];
    AVPlayer *player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:_receivedData[@"video"]]];
    _mainPlayer.player=player;
    player.actionAtItemEnd=AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player currentItem]];
    [player play];
}
-(void)playerItemDidReachEnd:(NSNotification *)notification {
    
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}
@end
