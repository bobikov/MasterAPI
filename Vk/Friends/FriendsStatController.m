//
//  FriendsStatController.m
//  vkapp
//
//  Created by sim on 18.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "FriendsStatController.h"

@implementation FriendsStatController

-(void)viewDidLoad{
//    NSLog(@"%@", _receivedData);
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
//    self.view.wantsLayer = YES;
//    self.view.layer.masksToBounds=YES;
    NSColor *gray1 = [NSColor colorWithRed:0.90 green:0.90 blue:0.90 alpha:1.0];
    NSColor *gray2 = [NSColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)[gray1 CGColor], (id)[gray2 CGColor], nil];
//    [self.view.layer insertSublayer:gradient atIndex:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"friendsGraphsData" object:nil userInfo:_receivedData];
}

-(void)viewDidAppear{
//    self.view.window.titleVisibility=NSWindowTitleVisible;
//    self.view.window.titlebarAppearsTransparent = YES;
//    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
//    self.view.window.movableByWindowBackground=YES;
//    [self.view.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
//    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:self.view.frame];
//    vibrantView.appearance = [NSAppearance
//                              appearanceNamed:NSAppearanceNameVibrantLight];
//    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
//    [self.view addSubview:vibrantView];
}
@end
