//
//  AppsPreferencesController.h
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppsPreferencesController : NSViewController{
    NSArray *appsData;
    __weak IBOutlet NSTableView *appsList;
    __weak IBOutlet NSBox *wrapSideMenu;
}

@end
