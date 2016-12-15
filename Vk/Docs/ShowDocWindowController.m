//
//  ShowDocWindowController.m
//  vkapp
//
//  Created by sim on 09.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "ShowDocWindowController.h"

@interface ShowDocWindowController ()

@end

@implementation ShowDocWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.titleVisibility=NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    self.window.styleMask|=NSFullSizeContentViewWindowMask;
    self.window.movableByWindowBackground=YES;
    [self.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantDark]];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSLog(@"%@", _receivedData);
}

@end
