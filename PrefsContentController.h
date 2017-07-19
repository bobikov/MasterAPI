//
//  PrefsContentController.h
//  MasterAPI
//
//  Created by sim on 19/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PrefsContentController : NSViewController
{
    
    NSWindow *mainWindow;
    NSRect windowRect;
    NSRect currentViewRect;
    NSViewController *oldController;
    NSViewController *contrGeneral;
    NSViewController *contrAppsPrefs;
    NSViewController *currentController;
    NSView *currentView;
    NSStoryboard *story;
    NSWindowController *win;
    NSView *oldView;
    
}
//@property(nonatomic,strong)NSWindowController *win;
@end
