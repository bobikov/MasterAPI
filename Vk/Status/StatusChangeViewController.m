//
//  StatusChangeViewController.m
//
//  Created by sim on 24.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "StatusChangeViewController.h"


@interface StatusChangeViewController ()<NSTextViewDelegate, NSTableViewDataSource, NSTableViewDelegate,NSTextFieldDelegate>

@end

@implementation StatusChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    textNewStatus.delegate = self;
    listOfStatus.delegate = self;
    listOfStatus.dataSource = self;
    _app=[[appInfo alloc]init];
    currentStatus.wantsLayer=YES;
    statusListData = [[NSMutableArray alloc]init];
    currentStatus.layer.borderWidth=0.5f;
    currentStatus.layer.borderColor = (__bridge CGColorRef _Nullable)([NSColor grayColor]);
    currentStatus.layer.cornerRadius = 10.0f;
    [currentStatus.layer setMasksToBounds:YES];
    moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(doScheduledStatus:) name:@"DoScheduledStatus" object:nil];
//    self.view.wantsLayer=YES;
//    [self.view.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    [self loadCurrentStatus];
    [self ReadStatusList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionNameDidChange:) name:NSTextDidChangeNotification object:nil];
 
    
}
- (void)viewDidAppear{
//    [self loadCurrentStatus];
 
}

- (void)doScheduledStatus:(NSNotification*)notification{
    NSLog(@"Sheduled status %@", notification.userInfo[@"status"]);
    scheduledStatusText = [notification.userInfo[@"status"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    [self setStatus:YES];
}
- (void)sessionNameDidChange:(NSNotification*)notification{
//    startedSessionStatusLabel.stringValue = [NSString stringWithFormat:@"Count: %li", [statusListData count]];
    currentSessionName = newSessionNameField.stringValue;
//    startedSessionStatusLabel.stringValue=[NSString stringWithFormat:@"Session: %@ Posts: %@", currentSessionName, @0];
    if([newSessionNameField.stringValue length]>0){
        saveStatusSession.enabled=YES;
        
    }else{
        saveStatusSession.enabled=NO;
    }
  
}
- (IBAction)scheduleStatus:(id)sender {
    
    [self startSheduleSession];
}
- (void)startSheduleSession{
    

    
    sessionWrapper.hidden=NO;
     stepperSessionInterval.integerValue=1;
//    sessionWrapper.wantsLayer=YES;
//    sessionWrapper.layer.masksToBounds=YES;
//    sessionWrapper.layer.cornerRadius=5;
//    startedSessionStatusLabel.hidden=NO;
//    startedSessionCloseBut.hidden=NO;
//    newSessionNameField.hidden=NO;
//    sessionInterval.hidden=NO;
//    newSessionStartBut.enabled=NO;
//    saveStatusSession.hidden=NO;
    if([newSessionNameField.stringValue length]>0){
        saveStatusSession.enabled=YES;
    }else{
        saveStatusSession.enabled=NO;
    }
    startedSessionStatusLabel.stringValue = [NSString stringWithFormat:@"Count: %li", [statusListData count]];
    [self setDefaultInterval];
  
}
- (IBAction)closeSession:(id)sender {
    sessionWrapper.hidden=YES;
//    addPostToQueueBut.hidden=YES;
//    startedSessionStatusLabel.hidden=YES;
//    startedSessionCloseBut.hidden=YES;
//    sessionInterval.hidden=YES;
//    newSessionStartBut.enabled=YES;
//    saveStatusSession.hidden=YES;
//    newSessionNameField.hidden=YES;
    newSessionNameField.stringValue=@"";
    stepperSessionInterval.integerValue=1;
//  [queuePostsInSession removeAllObjects];
}
- (IBAction)stepperValueUpdater:(id)sender {
    sessionInterval.integerValue=stepperSessionInterval.integerValue;
}
- (IBAction)saveStatusSession:(id)sender {
//    NSDate *date = [sessionInterval dateValue];
    
//    nt referenceTimeInterval = (int)[dt timeIntervalSinceReferenceDate];
//    int remainingSeconds = referenceTimeInterval % (minutes*60);
//    int timeRoundedTo5Minutes = referenceTimeInterval - remainingSeconds;
//    NSLog(@"%lu", (unsigned long)[sessionInterval datePickerElements]);
//    NSLog(@"%f", )
    sessionWrapper.hidden=YES;
    newSessionNameField.stringValue=@"";
    newSessionStartBut.enabled=YES;
     [[NSNotificationCenter defaultCenter]postNotificationName:@"preloadTaskView" object:nil userInfo:@{@"session_type":@"status", @"session_name":currentSessionName, @"session_data": [statusListData mutableCopy], @"session_interval":[NSNumber numberWithInteger:sessionInterval.integerValue]}];
    stepperSessionInterval.integerValue=0;
    sessionInterval.integerValue=0;
}

- (IBAction)saveStatusAction:(id)sender {
//    [self writeStatusToFile:currentStatus.stringValue];
    [self saveCurrentStatus];
}
-(void)setDefaultInterval{
//    sessionInterval.datePickerElements = NSHourMinuteSecondDatePickerElementFlag;
//    NSCalendar *cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
//    
//    
//    NSDateComponents *comps = [cal components:NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitSecond fromDate:[NSDate date]];
//    [comps setSecond:0];
//    [comps setCalendar:cal];
//    [comps setHour:0];
//    [comps setMinute:1];
//    NSDate *defaultDate = [comps date];
//    [sessionInterval setDateValue: defaultDate];
    
    

}
- (IBAction)removeStatusFromList2:(id)sender {
    NSView *view = [sender superview];
    NSInteger index = [listOfStatus rowForView:view];
    NSString *status = statusListData[index][@"status"];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"VKStatusList"];
    [request setReturnsObjectsAsFaults:NO];
    //    [request setResultType:NSDictionaryResultType];
    [request setPredicate:[NSPredicate predicateWithFormat:@"status == %@", status]];
    NSError *fetchError;
    NSError *delError;
    NSArray *array = [moc executeFetchRequest:request error:&fetchError];
    for(NSManagedObject *object in array){
        [moc deleteObject:object];
        if(![moc save:&delError]){
            NSLog(@"Delete object error");
        }else{
            NSLog(@"Status is successfully deleted");
            [self ReadStatusList];
            [listOfStatus reloadData];
        }
    }
}

- (IBAction)removeStatusFromList:(id)sender {
    NSInteger row = [listOfStatus selectedRow];
    NSString *status =  statusListData[row][@"status"];
    NSLog(@"%@", status);
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"VKStatusList"];
    [request setReturnsObjectsAsFaults:NO];
//    [request setResultType:NSDictionaryResultType];
    [request setPredicate:[NSPredicate predicateWithFormat:@"status == %@", status]];
    NSError *fetchError;
    NSError *delError;
    NSArray *array = [moc executeFetchRequest:request error:&fetchError];
    for(NSManagedObject *object in array){
        [moc deleteObject:object];
        if(![moc save:&delError]){
            NSLog(@"Delete object error");
        }else{
            NSLog(@"Status is successfully deleted");
            [self ReadStatusList];
            [listOfStatus reloadData];
        }
    }
}
- (void)loadCurrentStatus{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/status.get?user_id=%@&v=%@&access_token=%@", _app.person, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            currentStatus.stringValue = jsonData[@"response"][@"text"];
        });
    }] resume];
//    [loadStatus resume];
//    sleep(1);
//    currentStatus.stringValue = currentStatusData;
}
- (IBAction)setStatusAction:(id)sender {
    [self setStatus:NO];

}

-(void)setStatus:(BOOL)scheduled{
    if(([textNewStatus.string length]<=160 && [textNewStatus.string length]!=0) || scheduled){
        NSString *statusText=[textNewStatus.string  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/status.set?text=%@&v=%@&access_token=%@", scheduled ? scheduledStatusText : statusText, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if([jsonData[@"response"] intValue]){
                NSLog(@"Sucessfuly status set.");
                dispatch_async(dispatch_get_main_queue(), ^{
                    currentStatus.stringValue=textNewStatus.string;
                    [self loadCurrentStatus];
                });
            }
        }]resume];
        //        [self writeStatusToFile:textNewStatus.string];
        if(!scheduled){
            [self saveStatusCore];
        }
        
    }

}
- (void)saveCurrentStatus{
    if([currentStatus.stringValue length]<=160 && [currentStatus.stringValue length]!=0){
        
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for(NSDictionary *i in [self ReadStatusList]){
            [tempArray addObject:i[@"status"]];
        }
        if(![tempArray containsObject:currentStatus.stringValue]){
            NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"VKStatusList" inManagedObjectContext:moc];
            [object setValue:currentStatus.stringValue forKey:@"status"];
            NSError *saveError;
            if(![moc save:&saveError]){
                NSLog(@"Error save current status.");
            }else{
                NSLog(@"Current status is saved.");
                [self ReadStatusList];
                [listOfStatus reloadData];
            }
        }
    }
}
- (void)saveStatusCore{

    if([textNewStatus.string length]<=160 && [textNewStatus.string length]!=0){
    
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for(NSDictionary *i in [self ReadStatusList]){
            [tempArray addObject:i[@"status"]];
        }
        if(![tempArray containsObject:textNewStatus.string]){
            NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"VKStatusList" inManagedObjectContext:moc];
            [object setValue:textNewStatus.string forKey:@"status"];
            NSError *saveError;
            if(![moc save:&saveError]){
                NSLog(@"Error");
            }else{
                NSLog(@"Saved");
                [self ReadStatusList];
                [listOfStatus reloadData];
                
            }
            
            
        }
        
    }

}
- (NSArray*)ReadStatusList{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"VKStatusList"];
    [request setReturnsObjectsAsFaults:NO];
    [request setResultType:NSDictionaryResultType];
    NSError *fetchError;
    NSArray *array = [moc executeFetchRequest:request error:&fetchError];
    
    if([array count]>0 && array != nil){
        statusListData = [[NSMutableArray alloc]initWithArray:array];
        
        [listOfStatus reloadData];
    }else{
        [statusListData removeAllObjects];
        NSLog(@"Error load statuses from core data.");
    }
    return array;
}


- (void)textDidChange:(NSNotification *)notification{
    symbolCounter.stringValue=[NSString stringWithFormat:@"Characters count:%lu", [textNewStatus.string length]];
}



- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row = [listOfStatus selectedRow];
    NSString *item;
    item = statusListData[row][@"status"];
    textNewStatus.string = item;
    
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([statusListData count]>0){
        return [statusListData count];
    }
    return 0;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([statusListData count]>0){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    [cell.textField setStringValue:statusListData[row][@"status"]];
        return cell;
    }
    return nil;
}

@end
