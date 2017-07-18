//
//  Preferences.h
//  MasterAPI
//
//  Created by sim on 18/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <DBPrefsWindowController/DBPrefsWindowController.h>

@interface Preferences : DBPrefsWindowController{
     NSArray *appsData;
}
@property (strong) IBOutlet NSView *tokensView;
@property (strong) IBOutlet NSView *generalsView;

@end
