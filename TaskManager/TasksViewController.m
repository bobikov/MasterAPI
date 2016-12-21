//
//  TasksViewController.m
//  MasterAPI
//
//  Created by sim on 16.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TasksViewController.h"
#import <EventKit/EventKit.h>
#import "TasksCellView.h"
@interface TasksViewController ()<NSTableViewDelegate,NSTableViewDataSource>

@end

@implementation TasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    sessionsData = [[NSMutableArray alloc]init];
    tasksList.delegate=self;
    tasksList.dataSource=self;
    runLoop = [[NSRunLoop alloc]init];
//    sessionscurrent_task_indexes = [[NSMutableArray alloc]init];
//    NSLog(@"dddd %@", [runLoop currentMode]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeAddNewSessionTask:) name:@"addNewSessionTask" object:nil];
    
    

}
-(void)viewDidAppear{
 
    NSLog(@"%@", sessionsData);
    [tasksList reloadData];
}
-(void)observeAddNewSessionTask:(NSNotification*)notification{
//    NSLog(@"%@", notification.userInfo);
//       [self loadView];
    [self addSession:notification.userInfo];
}
- (IBAction)stopResume:(id)sender {
    NSView *view=[sender superview];
    NSInteger index = [tasksList rowForView:view];
    if([sessionsData[index][@"state"] isEqual:@"stopped"]){
        sessionsData[index][@"state"] =@"inprogress";
        sessionsData[index][@"stopped"]=@0;
//        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTaskProgressInSession:) userInfo:[[NSMutableDictionary alloc] initWithDictionary:@{@"index":[NSNumber numberWithInteger:index] , @"seconds":[NSNumber numberWithInteger:[sessionsData[index][@"currentPost"]intValue]]}] repeats:YES];
        NSDate *currentSessionTaskDate = sessionsData[index][@"session_data"][[sessionsData[index][@"session_data"][@"current_task_index"] intValue]][@"date"];
        NSTimer *timer = [[NSTimer alloc]initWithFireDate:currentSessionTaskDate interval:0.0 target:self selector:@selector(updateTaskProgressInSession:) userInfo:[[NSMutableDictionary alloc]initWithDictionary:@{@"session_index":[NSNumber numberWithInteger:index], @"task_index":@0}] repeats:NO];
//        NSLog(@"%@", sessionsData[index]);
//        [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
        
    }else{
        sessionsData[index][@"state"]=@"stopped";
        sessionsData[index][@"stopped"]=@1;
        
    }
    [tasksList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}
-(void)updateTaskProgressInSession:(NSTimer*)timer{
    if(timer){
        if([timer.userInfo[@"task_index"] intValue] == [sessionsData[[timer.userInfo[@"session_index"] intValue]][@"session_data"] count]-1){
            NSLog(@"%@",timer.userInfo[@"task_index"]);
            [timer invalidate];
            NSLog(@"Timer invalidated");
            
        }else{
            if([sessionsData[[timer.userInfo[@"session_index"] intValue]][@"stopped"] intValue]){
                NSLog(@"%@", sessionsData[[timer.userInfo[@"index"] intValue]][@"stopped"]);
                [timer invalidate];
            }else{
                timer.userInfo[@"task_index"] = [NSNumber numberWithInteger:[timer.userInfo[@"task_index"]intValue]+1];
                NSLog(@"%@",timer.userInfo[@"seconds"]);
                sessionsData[[timer.userInfo[@"session_index"] intValue]][@"current_task_index"] =[NSNumber numberWithInteger:[timer.userInfo[@"task_index"]intValue]];
                NSDate *currentSessionTaskDate = sessionsData[[timer.userInfo[@"task_index"]intValue]][@"session_data"][[sessionsData[[timer.userInfo[@"task_index"]intValue]][@"session_data"][@"current_task_index"] intValue]][@"date"];
                NSTimer *timer = [[NSTimer alloc]initWithFireDate:currentSessionTaskDate interval:0.0 target:self selector:@selector(updateTaskProgressInSession:) userInfo:[[NSMutableDictionary alloc]initWithDictionary:@{@"session_index":[NSNumber numberWithInteger:[timer.userInfo[@"index"] intValue]], @"task_index":@0}] repeats:NO];
                [tasksList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[timer.userInfo[@"session_index"] intValue]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                
            }
            //        TasksCellView *cell = (TasksCellView*)[tasksList relo
//             NSLog(@"%@", sessionsData[[timer.userInfo[@"index"] intValue]][@"stop"]);
            
        }
    }
  
   
//   [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:@"https://google.com"]];
    
}
-(void)startSession{
    
    NSDate *currentSessionTaskDate = sessionsData[0][@"session_data"][@"date"];
    
    NSTimer *timer = [[NSTimer alloc]initWithFireDate:currentSessionTaskDate interval:0.0 target:self selector:@selector(updateTaskProgressInSession:) userInfo:[[NSMutableDictionary alloc]initWithDictionary:@{@"session_index":[NSNumber numberWithInteger:sessionIndex], @"task_index":@0}] repeats:NO];
    
    
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTaskProgressInSession:) userInfo:[[NSMutableDictionary alloc]initWithDictionary:@{@"index":[NSNumber numberWithInteger:taskIndex], @"seconds":@0}] repeats:YES];
    
//    [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
}
-(void)nextTaskInSession{
    
}
- (IBAction)newSession:(id)sender {
    [self addSession:nil];
}
-(void)addSession:(id)data{
    
    NSDate *nextDate;
    NSString *nextDateString;
    sessionIndex=[sessionsData count];
    
    totalTasksInSession = [data[@"session_data"] count];
//    NSMutableDictionary *sessionObject = [[NSMutableDictionary alloc]initWithDictionary:@{@"name":[NSString stringWithFormat:@"Task %li", sessionIndex+1], @"totalPosts":[NSNumber numberWithInteger:totalTasksInSession], @"currentPost":@0, @"state":@"inprogress"}];
    NSMutableDictionary *sessionObject = [[NSMutableDictionary alloc]initWithDictionary:data];
    if(totalTasksInSession>1){
        nextDate = data[1][@"session_data"][@"date"];
        NSCalendar*calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents* components = [calendar components:NSCalendarUnitDay fromDate:nextDate];
         nextDateString = [NSString stringWithFormat:@"%ld.%ld.%ld, %ld:%ld",components.day,components.month,(long)components.year, (long)components.hour, (long)components.minute];
    }else{
         nextDateString =  @"no next date";
    }

   
    [sessionObject addEntriesFromDictionary:@{@"next_task_date":nextDateString, @"totalTasks":[NSNumber numberWithInteger:totalTasksInSession], @"current_task_index":@0, @"state":@"inprogress", @"stopped":@0}];
    
    [sessionsData addObject:sessionObject];
    NSLog(@"%@", sessionsData);
    NSLog(@"%li", totalTasksInSession);
    [tasksList insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[sessionsData count]-1] withAnimation:NSTableViewAnimationSlideDown];
    
//    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//    [dateComponents setYear:2016];
//    [dateComponents setMonth:12];
//    [dateComponents setDay:19];
//    [dateComponents setHour:15];
//    [dateComponents setMinute:20];
//    NSCalendar *calendar = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDate *configuredDate = [calendar dateFromComponents:dateComponents];
    
    
//    [self startSession];
    
}








-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [sessionsData count];
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    TasksCellView *cell = (TasksCellView*)[tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.taskName.stringValue=sessionsData[row][@"session_name"];
    cell.taskProgress.maxValue=[sessionsData[row][@"totalTasks"] intValue];
    cell.taskProgress.doubleValue=[sessionsData[row][@"current_task_index"] intValue];
    cell.nextEventDate.stringValue=sessionsData[row][@"next_task_date"];
    if([sessionsData[row][@"state"] isEqual:@"inprogress"]){
        cell.StopResume.image = [NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate];
        
    }else{
        cell.StopResume.image=[NSImage imageNamed:NSImageNameRefreshFreestandingTemplate];
    }
    return cell;
}
@end
