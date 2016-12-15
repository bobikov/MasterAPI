//
//  YoutubeVideoPlayerController.m
//  MasterAPI
//
//  Created by sim on 14.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "YoutubeVideoPlayerController.h"

@interface YoutubeVideoPlayerController ()<WebFrameLoadDelegate>

@end

@implementation YoutubeVideoPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView.frameLoadDelegate=self;
    [_webView setDrawsBackground:NO];
//    NSLog(@"%@", _receivedData);
//    NSString *html = [NSString stringWithFormat:@"<html><header><style>body{padding:0;margin:0;}.container{position: relative; width: 100%%; height: 100%%; }.video{position: absolute; top: 0; left: 0; width: 100%%; height: 100%%;}</style></header><body><div class=\"container\"><iframe id=\"ytplayer\" type=\"text/html\" width=\"640\" height=\"390\"src=\"http://www.youtube.com/embed/%@?autoplay=1&origin=http://example.com\"frameborder=\"0\"/ class=\"video\" allowfullscreen></div></body></html>", _receivedData[@"video_id"]];
    NSString *html = [NSString stringWithFormat:@"<html><header><style>body{padding:0;margin:0;}#player{position: relative; width: 100%%; height: 100%%; }.video{position: absolute; top: 0; left: 0; width: 100%%; height: 100%%;}</style></header><body><div id=\"player\"></div><script>var tag = document.createElement('script');tag.src = \"https://www.youtube.com/iframe_api\";var firstScriptTag = document.getElementsByTagName('script')[0];firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);var player;function onYouTubeIframeAPIReady() {player = new YT.Player('player', {height: '390', width: '640',playerVars: { 'iv_load_policy':'3'}, videoId: '%@', events: {'onReady': onPlayerReady, 'onStateChange': onPlayerStateChange } });} function onPlayerReady(event) { event.target.playVideo();event.target.setPlaybackQuality('medium');} var done = false;function onPlayerStateChange(event) {event.target.setPlaybackQuality('medium');}function stopVideo() {player.stopVideo();}</script></body></html>", _receivedData[@"video_id"]];
    [[_webView mainFrame]loadHTMLString:html baseURL:[NSURL URLWithString:@"http://localhost"]];
    
}
-(void)viewDidAppear{
    self.view.wantsLayer=YES;
    self.view.layer.masksToBounds=YES;
    self.view.layer.backgroundColor=[[NSColor blackColor]CGColor];
    
    self.view.window.titleVisibility=NSWindowTitleHidden;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    self.view.window.movableByWindowBackground=YES;
    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
}
-(void)viewDidDisappear{
    [_webView close];
    
}
@end
