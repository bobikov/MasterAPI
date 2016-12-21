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
//    NSLog(@"dddd %@", [runLoop currentMode]);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeAddNewSessionTask:) name:@"addNewSessionTask" object:nil];
    
    

}
-(void)observeAddNewSessionTask:(NSNotification*)notification{
//    NSLog(@"%@", notification.userInfo);
    [self addSession:notification.userInfo];
}
- (IBAction)stopResume:(id)sender {
    NSView *view=[sender superview];
    NSInteger index = [tasksList rowForView:view];
    if([sessionsData[index][@"state"] isEqual:@"stopped"]){
        sessionsData[index][@"state"] =@"inprogress";
        sessionsData[index][@"stopped"]=@0;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTaskProgressInSession:) userInfo:[[NSMutableDictionary alloc] initWithDictionary:@{@"index":[NSNumber numberWithInteger:index] , @"seconds":[NSNumber numberWithInteger:[sessionsData[index][@"currentPost"]intValue]]}] repeats:YES];
        NSLog(@"%@", sessionsData[index]);
        [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
        
    }else{
        sessionsData[index][@"state"]=@"stopped";
        sessionsData[index][@"stopped"]=@1;
        
    }
    [tasksList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}
-(void)updateTaskProgressInSession:(NSTimer*)timer{
    if(timer){
        if([timer.userInfo[@"seconds"] intValue] == 5){
            NSLog(@"%@",timer.userInfo[@"seconds"]);
            [timer invalidate];
            NSLog(@"Timer invalidated");
            
        }else{
            if([sessionsData[[timer.userInfo[@"index"] intValue]][@"stopped"] intValue]){
                NSLog(@"%@", sessionsData[[timer.userInfo[@"index"] intValue]][@"stopped"]);
                [timer invalidate];
            }else{
                timer.userInfo[@"seconds"] = [NSNumber numberWithInteger:[timer.userInfo[@"seconds"]intValue]+1];
                NSLog(@"%@",timer.userInfo[@"seconds"]);
                sessionsData[[timer.userInfo[@"index"] intValue]][@"currentPost"] =[NSNumber numberWithInteger:[timer.userInfo[@"seconds"]intValue]];
                [tasksList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[timer.userInfo[@"index"] intValue]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            }
            //        TasksCellView *cell = (TasksCellView*)[tasksList relo
//             NSLog(@"%@", sessionsData[[timer.userInfo[@"index"] intValue]][@"stop"]);
            
        }
    }
  
   
//   [[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:@"https://google.com"]];
    
}
-(void)startSession{
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTaskProgressInSession:) userInfo:[[NSMutableDictionary alloc]initWithDictionary:@{@"index":[NSNumber numberWithInteger:taskIndex], @"seconds":@0}] repeats:YES];
    
//    [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
}
-(void)nextTaskInSession{
    
}
- (IBAction)newSession:(id)sender {
    [self addSession:nil];
}
-(void)addSession:(id)data{
    sessionIndex=[sessionsData count];
    totalTasksInSession = [data[@"session_data"] count];
//    NSMutableDictionary *sessionObject = [[NSMutableDictionary alloc]initWithDictionary:@{@"name":[NSString stringWithFormat:@"Task %li", sessionIndex+1], @"totalPosts":[NSNumber numberWithInteger:totalTasksInSession], @"currentPost":@0, @"state":@"inprogress"}];
    NSMutableDictionary *sessionObject = [[NSMutableDictionary alloc]initWithDictionary:data];
    
    [sessionObject addEntriesFromDictionary:@{@"totalTasks":[NSNumber numberWithInteger:totalTasksInSession], @"currentTaskIndex":@0, @"state":@"inprogress"}];
    
    [sessionsData addObject:sessionObject];
    NSLog(@"%@", sessionsData);
//    [tasksList insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[sessionsData count]-1] withAnimation:NSTableViewAnimationSlideDown];
    
//    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//    [dateComponents setYear:2016];
//    [dateComponents setMonth:12];
//    [dateComponents setDay:19];
//    [dateComponents setHour:15];
//    [dateComponents setMinute:20];
//    NSCalendar *calendar = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDate *configuredDate = [calendar dateFromComponents:dateComponents];
    
    
  
    
}








-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [sessionsData count];
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    TasksCellView *cell = (TasksCellView*)[tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.taskName.stringValue=sessionsData[row][@"name"];
    cell.taskProgress.maxValue=[sessionsData[row][@"totalPosts"] intValue];
    cell.taskProgress.doubleValue=[sessionsData[row][@"currentPost"] intValue];
    if([sessionsData[row][@"state"] isEqual:@"inprogress"]){
        cell.StopResume.image = [NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate];
        
    }else{
        cell.StopResume.image=[NSImage imageNamed:NSImageNameRefreshFreestandingTemplate];
    }
    return cell;
}
@end
