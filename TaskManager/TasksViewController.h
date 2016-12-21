//
//  TasksViewController.h
//  MasterAPI
//
//  Created by sim on 16.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TasksViewController : NSViewController{
     NSInteger seconds;
    __weak IBOutlet NSTableView *tasksList;
    NSMutableArray *sessionsData;
    NSRunLoop *runLoop;
    NSInteger sessionIndex;
    NSInteger totalTasksInSession;
    NSMutableArray *sessionsCurrentTaskIndexes;
    
}

@end
