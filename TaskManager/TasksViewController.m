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
//    runLoop = [[NSRunLoop alloc]init];
//    sessionscurrent_task_indexes = [[NSMutableArray alloc]init];
//    NSLog(@"dddd %@", [runLoop currentMode]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeAddNewSessionTask:) name:@"addNewSessionTask" object:nil];
    
    

}
-(void)viewDidAppear{
 
    NSLog(@"%@", sessionsData);
//    [tasksList reloadData];
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
        NSLog(@"FIRE");
        if([timer.userInfo[@"task_index"] intValue] == [sessionsData[[timer.userInfo[@"session_index"] intValue]][@"data"] count]-1){
            NSLog(@"%@",timer.userInfo[@"task_index"]);
             sessionsData[[timer.userInfo[@"session_index"] intValue]][@"info"][@"current_task_index"] =[NSNumber numberWithInteger:[timer.userInfo[@"task_index"]intValue]];
             [tasksList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[timer.userInfo[@"session_index"] intValue]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            [timer invalidate];
            NSLog(@"Timer invalidated");
            
        }else{
            if([sessionsData[[timer.userInfo[@"session_index"] intValue]][@"info"][@"stopped"] intValue]){
                NSLog(@"%@", sessionsData[[timer.userInfo[@"index"] intValue]][@"info"][@"stopped"]);
                [timer invalidate];
            }else{
                timer.userInfo[@"task_index"] = [NSNumber numberWithInteger:[timer.userInfo[@"task_index"]intValue]+1];
                NSLog(@"%@",timer.userInfo[@"task_index"]);
                sessionsData[[timer.userInfo[@"session_index"] intValue]][@"info"][@"current_task_index"] =[NSNumber numberWithInteger:[timer.userInfo[@"task_index"]intValue]];
                NSDate *nextDate = sessionsData[[timer.userInfo[@"session_index"] intValue]][[timer.userInfo[@"task_index"] intValue]][@"data"][@"date"];
                NSString *nextDateString = [self getStringDate:nextDate];
                sessionsData[[timer.userInfo[@"session_index"] intValue]][@"info"][@"next_task_date"] = nextDateString;
                NSDate *currentSessionTaskDate = sessionsData[[timer.userInfo[@"task_index"]intValue]][@"data"][[sessionsData[[timer.userInfo[@"task_index"]intValue]][@"session_data"][@"current_task_index"] intValue]][@"date"];
                NSTimer *timer = [[NSTimer alloc]initWithFireDate:currentSessionTaskDate interval:0.0 target:self selector:@selector(updateTaskProgressInSession:) userInfo:[[NSMutableDictionary alloc]initWithDictionary:@{@"session_index":[NSNumber numberWithInteger:[timer.userInfo[@"index"] intValue]], @"task_index":@0}] repeats:NO];
                [tasksList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[timer.userInfo[@"session_index"] intValue]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                
            }
        }
    }
  
   
//   [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:@"https://google.com"]];
    
}
-(void)startSession{
    NSDate *startSessionTaskDate = sessionsData[newSessionIndex][@"data"][0][@"date"];
//    NSLog(@"%@", sessionsData[newSessionIndex][@"data"][0][@"date"]);
    NSTimer *timer = [[NSTimer alloc]initWithFireDate:startSessionTaskDate interval:0 target:self selector:@selector(updateTaskProgressInSession:) userInfo:[[NSMutableDictionary alloc]initWithDictionary:@{@"session_index":[NSNumber numberWithInteger:newSessionIndex], @"task_index":@0}] repeats:NO];
////    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTaskProgressInSession:) userInfo:[[NSMutableDictionary alloc]initWithDictionary:@{@"index":[NSNumber numberWithInteger:taskIndex], @"seconds":@0}] repeats:YES];
//    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}
-(void)nextTaskInSession{
    
}
- (IBAction)newSession:(id)sender {
//    [self addSession:nil];
}
-(NSString*)getStringDate:(NSDate*)date{
    NSString *dateString;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitMinute | NSCalendarUnitHour fromDate:date];
    dateString = [NSString stringWithFormat:@"%ld.%ld.%ld, %ld:%ld",components.day,components.month,(long)components.year, (long)components.hour, (long)components.minute];
    return dateString;
}
-(void)addSession:(id)data{
    
    NSDate *nextDate;
    NSString *nextDateString;
    totalTasksInSession = [data[@"session_data"] count];
//    NSMutableDictionary *sessionObject = [[NSMutableDictionary alloc]initWithDictionary:@{@"name":[NSString stringWithFormat:@"Task %li", newSessionIndex+1], @"totalPosts":[NSNumber numberWithInteger:totalTasksInSession], @"currentPost":@0, @"state":@"inprogress"}];
    NSMutableDictionary *sessionObject;
    nextDate = data[@"session_data"][0][@"date"];
    nextDateString = [self getStringDate:nextDate];
    
//    NSLog(@"%@", nextDateString);
   NSMutableDictionary *sessionInfoObject = [[NSMutableDictionary alloc]initWithDictionary:@{@"session_name":data[@"session_name"], @"next_task_date":nextDateString, @"totalTasks":[NSNumber numberWithInteger:totalTasksInSession], @"current_task_index":@0, @"state":@"inprogress", @"stopped":@0}];
    sessionObject = [[NSMutableDictionary alloc]initWithDictionary:@{@"info":sessionInfoObject, @"data":data[@"session_data"]}];
    [sessionsData addObject:sessionObject];
    newSessionIndex=[sessionsData count]-1;
    NSLog(@"%@", sessionsData);
    NSLog(@"%li", totalTasksInSession);
    [tasksList insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:newSessionIndex] withAnimation:NSTableViewAnimationSlideDown];
    
//    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//    [dateComponents setYear:2016];
//    [dateComponents setMonth:12];
//    [dateComponents setDay:19];
//    [dateComponents setHour:15];
//    [dateComponents setMinute:20];
//    NSCalendar *calendar = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDate *configuredDate = [calendar dateFromComponents:dateComponents];
    
    
    [self startSession];
    
}








-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [sessionsData count];
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    TasksCellView *cell = (TasksCellView*)[tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.taskName.stringValue=sessionsData[row][@"info"][@"session_name"];
    cell.taskProgress.maxValue=[sessionsData[row][@"info"][@"totalTasks"] intValue];
    cell.taskProgress.doubleValue=[sessionsData[row][@"info"][@"current_task_index"] intValue];
    cell.nextEventDate.stringValue=sessionsData[row][@"info"][@"next_task_date"];
    if([sessionsData[row][@"info"][@"state"] isEqual:@"inprogress"]){
        cell.StopResume.image = [NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate];
        
    }else{
        cell.StopResume.image=[NSImage imageNamed:NSImageNameRefreshFreestandingTemplate];
    }
    return cell;
}
@end
