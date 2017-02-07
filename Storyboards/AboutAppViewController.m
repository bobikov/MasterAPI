//
//  AboutAppViewController.m
//  MasterAPI
//
//  Created by sim on 05.02.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "AboutAppViewController.h"
#import "NSImage+Resizing.h"
@interface AboutAppViewController ()<NSWindowDelegate>

@end

@implementation AboutAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    app = [[appInfo alloc]init];
  
    
    
   
 
    stringHighlighter = [[StringHighlighter alloc]init];
    self.view.wantsLayer=YES;
    self.view.layer.backgroundColor = [[NSColor whiteColor] CGColor];
    productNameLabel.stringValue = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    copyrightsLabel.allowsEditingTextAttributes=YES;
    copyrightsLabel.selectable=YES;
    bundleVersionLabel.stringValue =  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
//    copyrightsLabel.attributedStringValue = [stringHighlighter createLinkFromSubstring:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSHumanReadableCopyright"] URL:[NSString stringWithFormat:@"https://vk.com/id%@",app.person ] subString:@"digitalpenetrator"];
       copyrightsLabel.attributedStringValue = [stringHighlighter createLinkFromSubstring:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSHumanReadableCopyright"] URL:@"https://vk.com/fruitapi" subString:@"MasterAPI"];
    //https://vk.com/fruitapi
    NSImage *appIconImage = [NSImage imageNamed:@"masterapi_icon_about.png"];
    appIconImage = [appIconImage resizeImageToNewSize:NSMakeSize(128, 127)];
    AppIconView.image=appIconImage;
    NSLog(@"%@", [[NSBundle mainBundle] infoDictionary]);
    NSLog(@"%@",[NSString stringWithFormat:@"Icon %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIconFile"]]);
    
}
- (void)viewDidAppear{
    NSLog(@"%@", self.view.window);
    self.view.window.delegate = self;
//    [self.view.window setLevel:NSFloatingWindowLevel];
//    [self.view.window makeKeyAndOrderFront:self];
//    [NSApp activateIgnoringOtherApps:NO];
    
    self.view.window.maxSize=NSMakeSize(432, 315);
    self.view.window.minSize=NSMakeSize(432, 315);
    self.view.window.titleVisibility=NSWindowTitleHidden;
 
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    self.view.window.movableByWindowBackground=NO;
    [self.view.window standardWindowButton:NSWindowMiniaturizeButton].hidden=YES;
    [self.view.window standardWindowButton:NSWindowZoomButton].hidden=YES;
    [self.view.window standardWindowButton:NSWindowCloseButton].hidden=YES;
//    [self.view.window standardWindowButton:NSWindowCloseButton].enabled=YES;
}
- (void)windowDidResignKey:(NSNotification *)notification{
    NSLog(@"%@", notification.object);
    if(notification.object == self.view.window){
        [self.view.window performClose:self];
    }
}
- (void)windowDidBecomeKey:(NSNotification *)notification{
    NSLog(@"Active");
}

- (void)createTrackingArea{
    trackingArea = [[NSTrackingArea alloc] initWithRect:self.view.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp owner:self userInfo:nil];
    [self.view addTrackingArea:trackingArea];
    
    mouseLocation = [self.view.window mouseLocationOutsideOfEventStream];
    mouseLocation = [self.view convertPoint: mouseLocation
                                   fromView: nil];
    
}
//- (void)mouseDown:(NSEvent *)theEvent{
//    NSLog(@"%f", mouseLocation.x);
//    if (!NSPointInRect(mouseLocation, self.view.bounds)){
//        
//        [self dismissController:self];
//    }
//    
//}
@end
