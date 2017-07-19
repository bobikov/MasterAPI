//
//  PrefsWindowControllerWithToolbar.h
//  MasterAPI
//
//  Created by sim on 18/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PrefsWindowControllerWithToolbar : NSWindowController{
    
    __weak IBOutlet NSToolbarItem *tokensPrefs;
    NSViewController *contrGeneral;
    NSViewController *contrAppsPrefs;
    NSViewController *currentController;
    NSWindow *mainWindow;
    NSRect windowRect;
    NSRect currentViewRect;
    NSViewController *oldController;
}

@end
