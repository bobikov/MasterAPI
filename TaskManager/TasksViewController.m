//
//  TasksViewController.m
//  MasterAPI
//
//  Created by sim on 16.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TasksViewController.h"
#import "TasksCellView.h"
#import "SessionTasksDetailsView.h"
@interface TasksViewController ()<NSTableViewDelegate,NSTableViewDataSource>

@end

@implementation TasksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    sessionsData = [[NSMutableArray alloc]init];
    tasksList.delegate=self;
    tasksList.dataSource=self;
    app = [[appInfo alloc]init];
    timers = [[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeAddNewSessionTask:) name:@"addNewSessionTask" object:nil];
}

-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    NSView *view=[sender superview];
    NSInteger sessionIndex = [tasksList rowForView:view];
    if([segue.identifier isEqual:@"SessionDetails"]){
        SessionTasksDetailsView *contr = (SessionTasksDetailsView*)segue.destinationController;
        contr.receivedData = sessionsData[sessionIndex];
    }
}

-(void)observeAddNewSessionTask:(NSNotification*)notification{
    
//    NSLog(@"%@", notification.userInfo);
//       [self loadView];
    NSMutableDictionary *object = [notification.userInfo mutableCopy ];
//    NSMutableDictionary *object = [[NSMutableDictionary alloc]initWithDictionary:oo];
    [self addSession:object];
}

- (IBAction)stopResume:(id)sender {
    NSView *view=[sender superview];
    NSInteger sessionIndex = [tasksList rowForView:view];
    if([sessionsData[sessionIndex][@"info"][@"state"] isEqual:@"stopped"]){
        sessionsData[sessionIndex][@"info"][@"state"] =@"inprogress";
        sessionsData[sessionIndex][@"info"][@"stopped"]=@0;
//        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSessionProgress:) userInfo:[[NSMutableDictionary alloc] initWithDictionary:@{@"index":[NSNumber numberWithInteger:index] , @"seconds":[NSNumber numberWithInteger:[sessionsData[index][@"currentPost"]intValue]]}] repeats:YES];
        NSInteger taskIndex =  [sessionsData[sessionIndex][@"info"][@"current_task_index"] intValue];
        NSDate *currentSessionTaskDate = sessionsData[sessionIndex][@"data"][taskIndex][@"date"];
        NSTimer *timer = [[NSTimer alloc]initWithFireDate:currentSessionTaskDate interval:0.0 target:self selector:@selector(updateSessionProgress:) userInfo:[[NSMutableDictionary alloc]initWithDictionary:@{@"session_index":[NSNumber numberWithInteger:sessionIndex], @"task_index":[NSNumber numberWithInteger:taskIndex]}] repeats:NO];
//        NSLog(@"%@", sessionsData[index]);
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        [timers insertObject:timer atIndex:sessionIndex];
        
    }else{
        sessionsData[sessionIndex][@"info"][@"state"]=@"stopped";
        sessionsData[sessionIndex][@"info"][@"stopped"]=@1;
    dispatch_async(dispatch_get_main_queue(), ^{
//
//        NSLog(@"%@", timers);
            NSLog(@"Timer invalidated by user");
        NSTimer *stopTimer =  (NSTimer*)timers[sessionIndex];
        [stopTimer invalidate];
        stopTimer = nil;
//        [timers removeObjectAtIndex:sessionIndex];
    
    });
  
        
    }
    [tasksList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:sessionIndex] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
}

-(void)updateSessionProgress:(NSTimer*)timer{
    
    if([timer isValid]){
//        if([sessionsData[[timer.userInfo[@"session_index"] intValue]][@"info"][@"stopped"] intValue]){
//            NSLog(@"%@", sessionsData[[timer.userInfo[@"session_index"] intValue]][@"info"][@"stopped"]);
//            NSLog(@"Timer stopped by user");
//            [timer invalidate];
//        }else{
            if([timer.userInfo[@"task_index"] intValue] == [sessionsData[[timer.userInfo[@"session_index"] intValue]][@"data"] count]-1){
                NSLog(@"%@",timer.userInfo[@"task_index"]);
                
                [[NSNotificationCenter defaultCenter]postNotificationName:@"DoScheduledPost" object:nil userInfo:[sessionsData[[timer.userInfo[@"session_index"]intValue]][@"data"][[timer.userInfo[@"task_index"]intValue]] mutableCopy]];
                
                sessionsData[[timer.userInfo[@"session_index"] intValue]][@"info"][@"current_task_index"] =[NSNumber numberWithInteger:[timer.userInfo[@"task_index"]intValue]+1];
                sessionsData[[timer.userInfo[@"session_index"] intValue]][@"info"][@"completed"]=@1;
                [tasksList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[timer.userInfo[@"session_index"] intValue]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            
                NSLog(@"Session %@ complete.", sessionsData[[timer.userInfo[@"session_index"] intValue]][@"info"][@"session_name"]);
                
            }else{
                
               [[NSNotificationCenter defaultCenter]postNotificationName:@"DoScheduledPost" object:nil userInfo:[sessionsData[[timer.userInfo[@"session_index"]intValue]][@"data"][[timer.userInfo[@"task_index"]intValue]] mutableCopy]];

                
                timer.userInfo[@"task_index"] = [NSNumber numberWithInteger:[timer.userInfo[@"task_index"]intValue]+1];
                NSLog(@"%@",timer.userInfo[@"task_index"]);
                sessionsData[[timer.userInfo[@"session_index"] intValue]][@"info"][@"current_task_index"] =[NSNumber numberWithInteger:[timer.userInfo[@"task_index"]intValue]];
                NSDate *nextDate = sessionsData[[timer.userInfo[@"session_index"] intValue]][@"data"][[timer.userInfo[@"task_index"] intValue]][@"date"];
                NSString *nextDateString = [self getStringDate:nextDate];
                sessionsData[[timer.userInfo[@"session_index"] intValue]][@"info"][@"next_task_date"] = nextDateString;
                NSDate *currentSessionTaskDate = sessionsData[[timer.userInfo[@"session_index"]intValue]][@"data"][[timer.userInfo[@"task_index"]intValue]][@"date"];
                [tasksList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[timer.userInfo[@"session_index"] intValue]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
              
                NSTimer *timer2 = [[NSTimer alloc]initWithFireDate:currentSessionTaskDate interval:0.0 target:self selector:@selector(updateSessionProgress:) userInfo:[[NSMutableDictionary alloc]initWithDictionary:@{@"session_index":[NSNumber numberWithInteger:[timer.userInfo[@"session_index"] intValue]], @"task_index":[NSNumber numberWithInteger:[timer.userInfo[@"task_index"] intValue]]}] repeats:NO];
                
                
                [[NSRunLoop currentRunLoop] addTimer:timer2 forMode:NSDefaultRunLoopMode];
                if(timers[[timer.userInfo[@"session_index"] intValue]]){
                    [timers removeObjectAtIndex:[timer.userInfo[@"session_index"] intValue]];
                }
                [timers insertObject:timer2 atIndex:[timer.userInfo[@"session_index"] intValue]];
                
            }
//        }
    }
}

-(void)startSession{
    NSDate *startSessionTaskDate = sessionsData[newSessionIndex][@"data"][0][@"date"];
//    NSLog(@"%@", sessionsData[newSessionIndex][@"data"][0][@"date"]);
    NSTimer *timer = [[NSTimer alloc]initWithFireDate:startSessionTaskDate interval:0 target:self selector:@selector(updateSessionProgress:) userInfo:[[NSMutableDictionary alloc]initWithDictionary:@{@"session_index":[NSNumber numberWithInteger:newSessionIndex], @"task_index":@0}] repeats:NO];
    [timers addObject:timer];
////    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateSessionProgress:) userInfo:[[NSMutableDictionary alloc]initWithDictionary:@{@"index":[NSNumber numberWithInteger:taskIndex], @"seconds":@0}] repeats:YES];
//    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
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
    NSMutableDictionary *sessionInfoObject = [[NSMutableDictionary alloc]initWithDictionary:@{@"session_start_date":[self getStringDate:nextDate], @"session_name":data[@"session_name"],@"session_type":data[@"session_type"], @"next_task_date":nextDateString, @"totalTasks":[NSNumber numberWithInteger:totalTasksInSession], @"current_task_index":@0, @"state":@"inprogress", @"stopped":@0, @"completed":@0}];
    sessionObject = [[NSMutableDictionary alloc]initWithDictionary:@{@"info":sessionInfoObject, @"data":data[@"session_data"]}];
    [sessionsData addObject:sessionObject];
    newSessionIndex=[sessionsData count]-1;
    NSLog(@"%@", sessionsData);
    NSLog(@"%li", totalTasksInSession);
    
    [tasksList insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:newSessionIndex] withAnimation:NSTableViewAnimationSlideDown];
    [self startSession];
    
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [sessionsData count];
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    TasksCellView *cell = (TasksCellView*)[tableView makeViewWithIdentifier:@"MainCell" owner:self];
    NSInteger taskIndex =[sessionsData[row][@"info"][@"current_task_index"] intValue];
    cell.taskName.stringValue=[NSString stringWithFormat:@"Session name: %@", sessionsData[row][@"info"][@"session_name"]];
    cell.taskProgress.maxValue=[sessionsData[row][@"info"][@"totalTasks"] intValue];
    cell.taskProgress.doubleValue=taskIndex;
    cell.nextEventDate.stringValue=[NSString stringWithFormat:@"Next: %@", sessionsData[row][@"info"][@"next_task_date"]];
    cell.countTasksLabel.stringValue = [NSString stringWithFormat:@"%@ / %@", sessionsData[row][@"info"][@"current_task_index"], sessionsData[row][@"info"][@"totalTasks"]];
    cell.targetOwner.stringValue = [NSString stringWithFormat:@"%@", sessionsData[row][@"data"][taskIndex==0?0:taskIndex-1][@"target_owner"]];
    cell.sessionType.stringValue = [NSString stringWithFormat:@"Type: %@",sessionsData[row][@"info"][@"session_type"]];
    cell.startSessionDate.stringValue = [NSString stringWithFormat:@"Session start: %@", sessionsData[row][@"info"][@"session_start_date"]];
    if([sessionsData[row][@"info"][@"state"] isEqual:@"inprogress"]){
        cell.StopResume.image = [NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate];
        
    }else{
        cell.StopResume.image=[NSImage imageNamed:NSImageNameRefreshFreestandingTemplate];
    }
    if([sessionsData[row][@"info"][@"completed"] intValue]){
        cell.completed.hidden=NO;
    }
    return cell;
}
@end
