//
//  VKCaptchaHandler.m
//  MasterAPI
//
//  Created by sim on 16.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "VKCaptchaHandler.h"

@implementation VKCaptchaHandler
-(id)init{
    self = [super self];
    _mainView=[[NSView alloc]initWithFrame:NSMakeRect(0, 0, 300, 100)];
   _image = [[NSImageView alloc] initWithFrame:NSMakeRect(0,50,200,50)];
    _enterCode = [[NSTextField alloc]initWithFrame:NSMakeRect(0,0, 200, 30)];
    [_enterCode setFont:[NSFont fontWithName:@"Helvetica" size:16]];
    _enterCode.alignment=NSTextAlignmentCenter;
    
    
    return self;
}
-(id)handleCaptcha:(id)img{
//    NSLog(@"%@", imageURL);
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _img=[[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:img]];
//        });
//    dispatch_async(dispatch_get_main_queue(), ^{
    
    
        [_mainView addSubview:_image];
        [_mainView addSubview:_enterCode];
        _enterCode.stringValue=@"";
        [_image setImage: _img];
        NSAlert *capAlert = [[NSAlert alloc]init];
        capAlert.accessoryView=_mainView;
        [capAlert addButtonWithTitle:@"Send"];
        [capAlert addButtonWithTitle:@"Cancel"];
    
        capAlert.window.titleVisibility=NSWindowTitleHidden;
        capAlert.window.titlebarAppearsTransparent = YES;
        capAlert.window.styleMask|=NSFullSizeContentViewWindowMask;
        capAlert.window.movableByWindowBackground = YES;
        capAlert.window.showsToolbarButton = NO;
        NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:capAlert.window.contentView.frame];
        vibrantView.material=NSVisualEffectMaterialSidebar;
        vibrantView.blendingMode=NSVisualEffectBlendingModeBehindWindow;
        [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [capAlert.window.contentView addSubview:vibrantView positioned:NSWindowBelow relativeTo:capAlert.window.contentView];
        [capAlert.window setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
        capAlert.messageText = @"Captcha";
        
//        NSInteger result = [capAlert runModal];
//        if (result == NSAlertFirstButtonReturn){
////            NSLog(@"%@", enterCode.stringValue);
//            _code =[NSString stringWithFormat:@"%@", enterCode.stringValue];
////            [capAlert modal];
//            return YES;
//           
//            
//        }
//        if (result == NSAlertSecondButtonReturn){
//            return NO;
//    dispatch_semaphore_signal(semaphore);
//        }
//    });
    return capAlert;

}
-(id)readCode{
    _code = _enterCode.stringValue;
    return _code;
}
@end
