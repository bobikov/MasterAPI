//
//  VideoPlayerViewController.m
//  vkapp
//
//  Created by sim on 26.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "VideoPlayerViewController.h"

@interface VideoPlayerViewController ()<WebFrameLoadDelegate, NSWindowDelegate>

@end

@implementation VideoPlayerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playVideo:) name:@"playVideo" object:nil];
//     _WebView.wantsLayer=YES;
//    _WebView.layer.masksToBounds=YES;
//    [_WebView.layer setBackgroundColor:[[NSColor blackColor]CGColor]];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor=[[NSColor blackColor]CGColor];
    _app = [[appInfo alloc]init];
    _WebView.frameLoadDelegate=self;
    self.view.window.delegate=self;
    [_WebView setDrawsBackground:NO];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeWebView:) name:@"closeWebView" object:nil];
//    [closeWindow setKeyEquivalent:@"\033"];
    
   
}
-(void)viewDidAppear{
    self.view.window.titleVisibility=NSWindowTitleVisible;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    self.view.window.movableByWindowBackground=YES;
    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
//         self.view.window.level = NSFloatingWindowLevel;
}
-(void)closeWebView:(NSNotification*)notification{
    NSLog(@"WebView should be closed here");
    [_WebView close];
}

- (IBAction)windowCloseAction:(id)sender {
//    [self dismissViewController:self];
//    [self.view.window close];
    [_WebView close];
}
-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
    NSString *url240;
    NSString *url360;
    NSString *url480;
    NSString *url720;
    NSString *flv;
    NSString *html = [_WebView stringByEvaluatingJavaScriptFromString:
                      @"document.body.innerHTML"];
//    NSLog(@"HTML : %@", html);
//    sleep(3);
    if(html!=nil){
       
        NSRegularExpression *regxp240 = [NSRegularExpression regularExpressionWithPattern:@"https:.{4}cs\\d{1,6}.vk.me.{2}(\\d.{2})?u\\d{1,9}.{2}videos.{2}.{1,10}.240.mp4" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *found240 = [regxp240 firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
        NSRange group240 = [found240 rangeAtIndex:0];
        url240 = [[html substringWithRange:group240] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        NSRegularExpression *regxp360 = [NSRegularExpression regularExpressionWithPattern:@"https:.{4}cs\\d{1,6}.vk.me.{2}(\\d.{2})?u\\d{1,9}.{2}videos.{2}.{1,10}.360.mp4" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *found360 = [regxp360 firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
        NSRange group360 = [found360 rangeAtIndex:0];
        url360 = [[html substringWithRange:group360] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        NSRegularExpression *regxp480 = [NSRegularExpression regularExpressionWithPattern:@"https:.{4}cs\\d{1,6}.vk.me.{2}(\\d.{2})?u\\d{1,9}.{2}videos.{2}.{1,10}.480.mp4" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *found480 = [regxp480 firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
        NSRange group480 = [found480 rangeAtIndex:0];
        url480 = [[html substringWithRange:group480] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        NSRegularExpression *regxp720 = [NSRegularExpression regularExpressionWithPattern:@"https:.{4}cs\\d{1,6}.vk.me.{2}(\\d.{2})?u\\d{1,9}.{2}videos.{2}.{1,10}.720.mp4" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *found720 = [regxp720 firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
        NSRange group720 = [found720 rangeAtIndex:0];
        url720 = [[html substringWithRange:group720] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
//        https:\/\/psv4.vk.me\/v89\/assets\/video\/f9cbd973fd3f-32818570.vk.flv
        NSRegularExpression *flvRegexp = [NSRegularExpression regularExpressionWithPattern:@"https:.{4}psv4.vk.me.{2}v\\d{2}.{2}assets.{2}video.{2}[0-9a-zA-Z]+-\\d+\\.vk\\.flv" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *flvVideo = [flvRegexp firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
        NSRange flvRange = [flvVideo rangeAtIndex:0];
        flv = [[html substringWithRange:flvRange] stringByReplacingOccurrencesOfString:@"\\" withString:@""];

//        @"https:\/\/cs508603.vk.me\/7\/u335296018\/videos\/4c975bfeb3.720.mp4";
//        NSRegularExpression *regxp360_2 = [NSRegularExpression regularExpressionWithPattern:@"https:.{8}cs\\d{6}.vk.me.{4}\\d.{4}u\\d{1,9}.{4}videos.{4}.{1,10}.360.mp4" options:NSRegularExpressionCaseInsensitive error:nil];
//        NSTextCheckingResult *found360_2 = [regxp360 firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
//        NSRange group360_2 = [found360 rangeAtIndex:0];
//        url360 = [[html substringWithRange:group360] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
//        NSRegularExpression *regxp480_2 = [NSRegularExpression regularExpressionWithPattern:@"https:.{8}cs\\d{6}.vk.me.{4}\\d.{4}u\\d{1,9}.{4}videos.{4}.{1,10}.480.mp4" options:NSRegularExpressionCaseInsensitive error:nil];
//        NSTextCheckingResult *found480 = [regxp480 firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
//        NSRange group480 = [found480_2 rangeAtIndex:0];
//        url480 = [[html substringWithRange:group480] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
//        NSRegularExpression *regxp720_2 = [NSRegularExpression regularExpressionWithPattern:@"https:.{8}cs\\d{6}.vk.me.{4}\\d.{4}u\\d{1,9}.{4}videos.{4}.{1,10}.720.mp4" options:NSRegularExpressionCaseInsensitive error:nil];
//        NSTextCheckingResult *found720 = [regxp720 firstMatchInString:html options:0 range:NSMakeRange(0, [html length])];
//        NSRange group720 = [found720 rangeAtIndex:0];
//        url720 = [[html substringWithRange:group720] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        //    NSLog(@"%@", [[html substringWithRange:group8] stringByReplacingOccurrencesOfString:@"\\" withString:@""]);
        //        NSLog(@"%@", page);
        NSString *source720 = [url720 containsString:@"720.mp4"] ? [NSString stringWithFormat:@"<source src='%@' type='video/mp4' label='720' />", url720] : @"";
        NSString *source480 = [url480 containsString:@"480.mp4"] ?  [NSString stringWithFormat:@"<source src='%@' type='video/mp4' label='480' />", url480] : @"";
        NSString *source360 = [url360 containsString:@"360.mp4"] ? [NSString stringWithFormat:@"<source src='%@' type='video/mp4' label='360'/> ", url360] : @"";
         NSString *source240 = [url240 containsString:@"240.mp4"] ? [NSString stringWithFormat:@"<source src='%@' type='video/mp4' label='240' />", url240] : @"";
         NSString *sourceFLV = [flv containsString:@".flv"] ? [NSString stringWithFormat:@"<source src='%@' type='video/flv'/>", flv] : @"";
        NSLog(@"Url240 %@", url240);
        NSLog(@"Url360 %@", url360);
        NSLog(@"url480 %@", url480);
        NSLog(@"url720 %@", url720);
        NSLog(@"FLV %@", flv);
        if([url360 containsString:@"360.mp4"] || [url480 containsString:@"480.mp4"]  || [url720 containsString:@"720.mp4"] || [url240 containsString:@"240.mp4"] || [flv containsString:@".flv"]){
           
            //        sleep(3);
            //        [self.view.window close];
            //        [_WebView close];
            //        [self.view.window setFrame:NSMakeRect(self.view.window.frame.origin.x   , self.view.window.frame.origin.y/2+100 , 660.f, 400.f) display:YES animate:YES];
           NSBundle *mainBundle = [NSBundle mainBundle];
            NSString *path = [[NSBundle mainBundle] bundlePath];
            NSURL *baseURL = [NSURL fileURLWithPath:path];
            NSString *body=[NSString stringWithFormat:@"<video id='my_video' class='video-js vjs-big-play-centered' loop controls data-setup='{}' poster='%@' >%@ %@ %@ %@ %@</video>",  coverURL,  source240, source360, source480,   source720, sourceFLV];
//            <p class='vjs-no-js'>To view this video please enable JavaScript, and consider upgrading to a web browser that <a href='http://videojs.com/html5-video-support/' target='_blank'>supports HTML5 video</a></p>
//            NSString *body=@"<video id='my_video' class='video-js'></video>";
//            NSString *linkCSS = @"<link rel='stylesheet' type='text/css' href='http://vjs.zencdn.net/5.10.7/video-js.css'></link>";
//            NSString *linkCSS = @"<link rel='stylesheet' type='text/css' href='/video-js.css'></link>";
            NSString *injectHTML;
            NSURL *cssURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"video-js.css" ofType:nil]];
            NSURL *videoJSURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"video.js" ofType:nil]];
            NSURL *videoJSResSwitchJS = [NSURL fileURLWithPath:[mainBundle pathForResource:@"videojs-resolution-switcher.js" ofType:nil]];
            NSURL *videoJSResSwitchCSS = [NSURL fileURLWithPath:[mainBundle pathForResource:@"videojs-resolution-switcher.css" ofType:nil]];
            NSString *videoJSRes =  @"videojs('my_video').videoJsResolutionSwitcher()";
            NSLog(@"cover url %@", coverURL);
//            NSLog(@"Rsulution switcher %@", [NSString stringWithContentsOfURL:videoJSResSwitchJS encoding:NSUTF8StringEncoding error:nil]);
            injectHTML = [NSString stringWithFormat:@"<html><head><style>body{position:relative;margin:0;}#my_video{position:relative;width:100%%;height:100%%;}%@ %@</style><script>%@</script><script>%@</script></head><body>%@<script>%@</script></body></html>", [NSString stringWithContentsOfURL:cssURL encoding:NSUTF8StringEncoding error:nil], [NSString stringWithContentsOfURL:videoJSResSwitchCSS encoding:NSUTF8StringEncoding error:nil], [NSString stringWithContentsOfURL:videoJSURL encoding:NSUTF8StringEncoding error:nil],[NSString stringWithContentsOfURL:videoJSResSwitchJS encoding:NSUTF8StringEncoding error:nil],  body, videoJSRes];
            
//            [[_WebView mainFrame]loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:injectHTML]]];
//            [[_WebView mainFrame] loadHTMLString:injectHTML baseURL:[NSURL URLWithString:@"http://localhost/"]];
            
            [[_WebView mainFrame] loadHTMLString:injectHTML baseURL:baseURL];
//            sleep(1);
            
          
//            NSString *location = [NSString stringWithFormat:@"window.location='%@'", url];
//            [_WebView stringByEvaluatingJavaScriptFromString:
//             @"window.location='https://google.com'"];
            
            //        finalUrl = nil;
        }
    }
   

}
- (void)webView:(WebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"could not load the website caused by error: %@", error);
}
-(void)playVideo:(NSNotification *)notification{
 
    NSLog(@"%@", notification.userInfo[@"url"]);
    coverURL = notification.userInfo[@"cover"];
//    WebView = [WebView initWithFrame:self.view.frame];
    NSString *url=notification.userInfo[@"url"];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"ntv.ru" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *found = [regex matchesInString:url  options:0 range:NSMakeRange(0,[url length])];
    NSRegularExpression *regex3 = [NSRegularExpression regularExpressionWithPattern:@"video_ext" options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *found3 = [regex3 matchesInString:url  options:0 range:NSMakeRange(0,[url length])];
    if([found count]>0){
       
          NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"(?<=embed/)\\d+" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *found2 = [regex2 firstMatchInString:url options:0 range:NSMakeRange(0, [url length])];
        NSRange group1 = [found2 rangeAtIndex:0];
//        NSLog(@"%@", [url substringWithRange:group1] );
        
        [self.view.window setFrame:NSMakeRect(self.view.window.frame.origin.x   , self.view.window.frame.origin.y/2+100 , 780.f, 670.f) display:YES animate:YES];
        [[_WebView mainFrame]loadHTMLString:[NSString stringWithFormat:@"<html><head><style>body{position:relative;margin:0;}#video_ntv_frame{position:relative;width:100%%;height:100%%;}</style></head><body><iframe id='video_ntv_frame' 'width='640' height='360' src='//www.ntv.ru/video/embed/%@' frameborder='0' allowfullscreen></iframe></body></html>", [url substringWithRange:group1] ] baseURL:[NSURL URLWithString:@"http://localhost/"]];
    }
    else if([found3 count]>0){
        //        NSString *testString = [NSString stringWithFormat:@"%@", @"https://life.ru/t/%D0%BD%D0%BE%D0%B2%D0%BE%D1%81%D1%82%D0%B8" ];

            NSURL *urlString = [NSURL URLWithString: url];
        //        NSLog(@"%@", urlString.query);
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            for (NSString *param in [urlString.query componentsSeparatedByString:@"&"]) {
                NSArray *elts = [param componentsSeparatedByString:@"="];
                if([elts count] < 2) continue;
                [params setObject:[elts lastObject] forKey:[elts firstObject]];
            }
        NSString *videoAlbumString =[NSString stringWithFormat:@"https://vk.com/video%@_%@", params[@"oid"], params[@"id"]];
        NSLog(@"vk link %@", videoAlbumString);

        [self.view.window setFrame:NSMakeRect(self.view.window.frame.origin.x   , self.view.window.frame.origin.y/2+100 , 770.f, 630.f) display:YES animate:YES];
                [[_WebView mainFrame]loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoAlbumString]]];

        
    }
    else if([url containsString:@"1tv.ru"]){
        NSLog(@"1tv");
        NSRegularExpression *regex1tv = [NSRegularExpression regularExpressionWithPattern:@"(?<=embed/)\\d+:\\d{2}" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *found1tv = [regex1tv firstMatchInString:url options:0 range:NSMakeRange(0, [url length])];
        NSRange group1tv = [found1tv rangeAtIndex:0];
        //        NSLog(@"%@", [url substringWithRange:group1] );
        [self.view.window setFrame:NSMakeRect(self.view.window.frame.origin.x   , self.view.window.frame.origin.y/2+100 , 770.f, 630.f) display:YES animate:YES];
        [[_WebView mainFrame] loadHTMLString:[NSString stringWithFormat:@"<iframe width='640' height='360' src='//www.1tv.ru/embed/%@' frameborder='0' allowfullscreen></iframe>", [url substringWithRange:group1tv] ] baseURL:[NSURL URLWithString:@"http://localhost/"]];
    }
    else{
//        NSString *testString = [NSString stringWithFormat:@"%@", @"https://life.ru/t/новости" ];
//
//                [[_app.session dataTaskWithURL:[NSURL URLWithString:[testString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                    NSString *returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                    NSLog(@"returnString : %@",returnString);
//                    
//                  }]resume];
//        NSLog(@"dsf");
        [self.view.window setFrame:NSMakeRect(self.view.window.frame.origin.x   , self.view.window.frame.origin.y/2+100 , 770.f, 630.f) display:YES animate:YES];
        [[_WebView mainFrame]loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
        
        
    }
//     [[_WebView mainFrame]loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://vk.com/video_ext.php?oid=-41041067&id=456240347&hash=59a0078581ee37da&__ref=vk.api&api_hash=1464364070fbd31121806478e8aa_GE3TSMZUHEZTCNY"]]];
    
//    NSString *jsFile = @"jquery.js";
//    NSString *jsFilePath = [[NSBundle mainBundle] pathForResource:jsFile ofType:nil];
//    NSURL *jsURL = [NSURL fileURLWithPath:jsFilePath];
//    NSString *javascriptCode = [NSString stringWithContentsOfFile:jsURL.path encoding:NSUTF8StringEncoding error:nil];
//    [_WebView stringByEvaluatingJavaScriptFromString:@" <script src='https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js'></script>"];
//    NSString *jsFile2 = @"fix.js";
//    NSString *jsFilePath2 = [[NSBundle mainBundle] pathForResource:jsFile2 ofType:nil];
//    
//    NSURL *jsURL2 = [NSURL fileURLWithPath:jsFilePath2];
//    NSString *javascriptCode2 = [NSString stringWithContentsOfFile:jsURL2.path encoding:NSUTF8StringEncoding error:nil];
//    [_WebView stringByEvaluatingJavaScriptFromString:@" <script src='//tiaplex.com/vkvideo.js'></script>"];
//    NSLog(@"Loadedddd");
   
   
    
    self.view.window.title = notification.userInfo[@"title"];

    
}

-(void)playVideoInPlayer:(id)videoUrl{
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSMoviesDirectory, NSUserDomainMask, YES);
    NSURL *url = [NSURL URLWithString:videoUrl];
    
    //    NSURL *url = [NSURL fileURLWithPath:[paths[0] stringByAppendingPathComponent:@"tina-HD.mp4"]];
    NSLog(@"%@", url);
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    //    _player = [[AVPlayer alloc ]initWithURL:url];
    _player = [[AVPlayer alloc ] initWithPlayerItem:playerItem];
    _playerView = [[ AVPlayerView alloc]init];
    _playerView.controlsStyle=AVPlayerViewControlsStyleInline;
    [_playerView showsFrameSteppingButtons];
    _playerView.frame = self.view.frame;
    
    //    [_player setAllowsExternalPlayback:YES];
    _playerView.player=_player;
    //    [playerView.player play];
    [self.view addSubview: _playerView];
    //    NSError *error;
    [_player play];
    _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
}
@end
