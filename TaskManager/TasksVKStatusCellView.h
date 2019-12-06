//
//  TasksVKStatusCellView.h
//  MasterAPI
//
//  Created by sim on 08.01.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TasksVKStatusCellView : NSTableCellView
@property (weak) IBOutlet NSTextField *status;
@property (weak) IBOutlet NSTextField *sessionName;
@property (weak) IBOutlet NSTextField *sessionType;
@property (weak) IBOutlet NSButton *StopResume;
@end
