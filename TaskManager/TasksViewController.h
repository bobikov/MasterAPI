//
//  TasksViewController.h
//  MasterAPI
//
//  Created by sim on 16.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface TasksViewController : NSViewController{
     NSInteger seconds;
    __weak IBOutlet NSTableView *tasksList;
    NSMutableArray *sessionsData;
    NSInteger newSessionIndex;
    NSInteger totalTasksInSession;
    appInfo *app;
    NSMutableArray *timers;
    
}

@end
