//
//  MyVideoWindowController.m
//  vkapp
//
//  Created by sim on 26.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "MyVideoWindowController.h"

@interface MyVideoWindowController ()<NSWindowDelegate>

@end

@implementation MyVideoWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.delegate=self;
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
-(void)windowWillClose:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeWebView" object:nil];
}
@end
