//
//  AboutAppViewController.h
//  MasterAPI
//
//  Created by sim on 05.02.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "StringHighlighter.h"
#import "appInfo.h"
@interface AboutAppViewController : NSViewController{
    StringHighlighter *stringHighlighter;
    appInfo *app;
    __weak IBOutlet NSTextField *productNameLabel;
    __weak IBOutlet NSTextField *bundleVersionLabel;
    __weak IBOutlet NSTextField *copyrightsLabel;
    __weak IBOutlet NSImageView *AppIconView;
    NSTrackingArea *trackingArea;
    NSPoint mouseLocation;
    IBOutlet NSTextField *nameLabel;
    IBOutlet NSTextField *versionLabel;
}

@end
