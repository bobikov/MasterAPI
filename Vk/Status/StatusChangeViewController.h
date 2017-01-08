//
//  StatusChangeViewController.h
//  vkapp
//
//  Created by sim on 24.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface StatusChangeViewController : NSViewController{
    __weak IBOutlet NSTextField *currentStatus;
    __unsafe_unretained IBOutlet NSTextView *textNewStatus;
    __weak IBOutlet NSTableView *listOfStatus;
    __weak IBOutlet NSButton *setNewStatusButton;
    __weak IBOutlet NSTextField *symbolCounter;
    NSMutableArray *statusListData;
    NSString *currentStatusData;
    __weak IBOutlet NSButton *saveStatus;
    NSManagedObjectContext *moc;
    __weak IBOutlet NSButton *newSessionStartBut;
    __weak IBOutlet NSTextField *startedSessionStatusLabel;
    __weak IBOutlet NSButton *startedSessionCloseBut;
    __weak IBOutlet NSTextField *newSessionNameField;
    __weak IBOutlet NSButton *addPostToQueueBut;
//    __weak IBOutlet NSDatePicker *sessionDatePicker;
    __weak IBOutlet NSButton *saveStatusSession;
    NSString *currentSessionName;
    __weak IBOutlet NSTextField *sessionInterval;
    NSString *scheduledStatusText;
    __weak IBOutlet NSStepper *stepperSessionInterval;
    __weak IBOutlet NSBox *sessionWrapper;
    
}

@property (nonatomic)appInfo *app;

@end
