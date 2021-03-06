//
//  TasksCellView.h
//  MasterAPI
//
//  Created by sim on 19.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TasksCellView : NSTableCellView
@property (weak) IBOutlet NSTextField *taskName;
@property (weak) IBOutlet NSProgressIndicator *taskProgress;
@property (weak) IBOutlet NSButton *StopResume;
@property (weak) IBOutlet NSTextField *nextEventDate;
@property (weak) IBOutlet NSTextField *countTasksLabel;
@property (weak) IBOutlet NSTextField *sessionType;
@property (weak) IBOutlet NSTextField *startSessionDate;
@property (weak) IBOutlet NSTextField *targetOwner;
@property (weak) IBOutlet NSImageView *completed;

@end
