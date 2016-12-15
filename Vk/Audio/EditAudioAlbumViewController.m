//
//  EditAudioAlbumViewController.m
//  MasterAPI
//
//  Created by sim on 14.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "EditAudioAlbumViewController.h"

@interface EditAudioAlbumViewController ()

@end

@implementation EditAudioAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:self.view.frame];
    vibrantView.material=NSVisualEffectMaterialSidebar;
    
    vibrantView.blendingMode=NSVisualEffectBlendingModeBehindWindow;
    
    
    //    vibrantView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    //    vibrantView.wantsLayer=YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self.view addSubview:vibrantView positioned:NSWindowBelow relativeTo:self.view];
    NSLog(@"%@", _receivedData);
    albumName.stringValue = _receivedData[@"title"];
}
-(void)viewDidAppear{
    self.view.window.showsToolbarButton = NO;
    self.view.window.toolbar=nil;
    self.view.window.titleVisibility=NSWindowTitleHidden;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    self.view.window.movableByWindowBackground = YES;
    
}

- (IBAction)save:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"editAudioAlbumName" object:nil userInfo:@{@"title":albumName.stringValue, @"data": _receivedData}];
    [self.view.window close];
}

@end
