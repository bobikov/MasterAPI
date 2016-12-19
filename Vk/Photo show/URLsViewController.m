//
//  URLsViewController.m
//  MasterAPI
//
//  Created by sim on 07.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "URLsViewController.h"

@interface URLsViewController ()

@end

@implementation URLsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

   
}
-(void)viewDidAppear{
    self.view.window.titleVisibility=NSWindowTitleHidden;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    self.view.window.movableByWindowBackground=YES;
    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
    self.view.window.level = NSFloatingWindowLevel;
    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:self.view.frame];
    vibrantView.material=NSVisualEffectMaterialLight;
    
    vibrantView.blendingMode=NSVisualEffectBlendingModeBehindWindow;
    
    
    //    vibrantView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    //    vibrantView.wantsLayer=YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self.view addSubview:vibrantView positioned:NSWindowBelow relativeTo:self.view];
}
- (IBAction)acceptURLs:(id)sender {
    if([_mediaType isEqual:@"photo"]){
        [[NSNotificationCenter defaultCenter]postNotificationName:@"uploadPhotoURLs" object:nil userInfo:@{@"urls_string":fieldWithURLsString.stringValue}];
    }else{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"uploadVideoURLs" object:nil userInfo:@{@"urls_string":fieldWithURLsString.stringValue}];
    }
    [self dismissController:self];
//    NSLog(@"%@", fieldWithURLsString.stringValue);
}

@end
