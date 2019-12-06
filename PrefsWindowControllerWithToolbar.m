//
//  PrefsWindowControllerWithToolbar.m
//  MasterAPI
//
//  Created by sim on 18/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "PrefsWindowControllerWithToolbar.h"

@interface PrefsWindowControllerWithToolbar ()

@end

@implementation PrefsWindowControllerWithToolbar

- (void)windowDidLoad {
    [super windowDidLoad];
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Third" bundle:nil];
    contrGeneral  = [story instantiateControllerWithIdentifier:@"GeneralPrefsController"];
    contrAppsPrefs = [story instantiateControllerWithIdentifier:@"appPrefs"];
    self.window.toolbar.selectedItemIdentifier=@"Tokens";
    currentController = [[NSViewController alloc]init];
    contrGeneral.preferredContentSize = NSMakeSize(self.window.frame.size.width,117);
    contrAppsPrefs.preferredContentSize = contrAppsPrefs.view.frame.size;
    currentController = contrAppsPrefs;
    
    
    //    [self updateFrame];
//    [contrGeneral.view setAutoresizesSubviews:NO];
//  [contrGeneral.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

}
- (IBAction)showTokensPrefs:(id)sender {
    oldController=currentController;
//    [[currentController view] removeFromSuperview];
    currentViewRect = NSMakeRect(0,0,contrAppsPrefs.view.frame.size.width, contrAppsPrefs.preferredContentSize.height);
//     NSLog(@"%f", contrAppsPrefs.preferredContentSize.height);
   
    currentController = contrAppsPrefs;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SwitchPrefsViews" object:nil userInfo:@{@"name":@"Tokens"}];
//    [self updateFrame];
//    self.contentViewController=contrAppsPrefs;
}
- (IBAction)showGeneralPrefs:(id)sender {
    oldController=currentController;
//    [[currentController view] removeFromSuperview];
    
    currentViewRect = NSMakeRect(0,0,contrGeneral.view.frame.size.width, contrGeneral.preferredContentSize.height);
//     NSLog(@"%f", contrGeneral.preferredContentSize.height);
  
    currentController = contrGeneral;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SwitchPrefsViews" object:nil userInfo:@{@"name":@"General"}];

//    [self updateFrame];
}
-(void)updateFrame{
    
//    currentViewRect = currentController.view.frame;
    mainWindow = self.window;
    windowRect = mainWindow.frame;
    NSLog(@"%f", windowRect.size.height);
    NSLog(@"%f", currentViewRect.size.height);
    NSLog(@"%f", windowRect.origin.y);
    windowRect.origin.y = windowRect.origin.y + (windowRect.size.height - currentViewRect.size.height);
    windowRect.size.height = currentViewRect.size.height;
    windowRect.size.width = currentViewRect.size.width;
     [[oldController view]removeFromSuperview];
    [mainWindow setFrame:windowRect display:YES animate:YES];
   
     [mainWindow setContentView:currentController.view];
//    [self setContentViewController:currentController];

}
@end
