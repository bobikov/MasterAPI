//
//  StatusChangeViewController.m
//
//  Created by sim on 24.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "StatusChangeViewController.h"


@interface StatusChangeViewController ()<NSTextViewDelegate, NSTableViewDataSource, NSTableViewDelegate>

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
//    self.view.wantsLayer=YES;
//    [self.view.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    [self loadCurrentStatus];
//    [self readStatusFromFile];
    [self ReadStatusList];
    
    

}
-(void)viewDidAppear{
//    [self loadCurrentStatus];
}
- (IBAction)saveStatusAction:(id)sender {
//    [self writeStatusToFile:currentStatus.stringValue];
    [self saveCurrentStatus];
}
- (IBAction)removeStatusFromList:(id)sender {
    
    NSInteger row = [listOfStatus selectedRow];
    NSString *status =  statusListData[row][@"status"];
    NSLog(@"%@", status);
     NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
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
-(void)loadCurrentStatus{
  
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
    
    if([textNewStatus.string length]<=160 && [textNewStatus.string length]!=0){
         NSString *statusText=[textNewStatus.string  stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/status.set?text=%@&v=%@&access_token=%@", statusText, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if([[NSString stringWithFormat:@"%@", jsonData[@"response"]] isEqual:@"1"]){
                NSLog(@"Sucessfuly status set.");
                dispatch_async(dispatch_get_main_queue(), ^{
                    currentStatus.stringValue=currentStatus.stringValue;
                });
            }
        }]resume];
//        [self writeStatusToFile:textNewStatus.string];
        [self saveStatusCore];
        [self loadCurrentStatus];
      
    }
//       NSLog(@"%lu", [statusText length]);
}
-(void)saveCurrentStatus{
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
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
-(void)saveStatusCore{
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
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
-(NSArray*)ReadStatusList{
     NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
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
-(void)writeStatusToFile:(id)text{
    NSFileManager *manager = [[NSFileManager alloc]init];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *path =  [basePath stringByAppendingPathComponent:@"list_of_status.json"];
    NSData *contents;
    NSMutableArray *tempArray;
    NSMutableArray *readData2;
    readData2 = [[NSMutableArray alloc]init];
    NSString *prettyString;
    
    tempArray = [[NSMutableArray alloc]init];
    if([manager fileExistsAtPath:path]){
        contents = [manager contentsAtPath:path];
        readData2=[NSJSONSerialization JSONObjectWithData:contents options:NSJSONReadingMutableContainers  error:nil];
        [listOfStatus reloadData];
        
    }
    else{
        [manager createFileAtPath:path contents:nil attributes:nil];
    }
    if (readData2){
        for(NSDictionary *i in readData2){
            [tempArray addObject:i[@"status"]];
        }
        if(![tempArray containsObject:text]){
            [readData2 addObject:@{@"status":text}];
            NSData *dataToFile = [NSJSONSerialization dataWithJSONObject:readData2 options:NSJSONWritingPrettyPrinted error:nil];
            [dataToFile writeToFile:path atomically:YES];
            statusListData=readData2;
            [listOfStatus reloadData];
        }
    }
    else{
        NSMutableArray *jsonArray = [NSMutableArray arrayWithObjects:@{@"status":text}, nil];
        NSData *finalData  = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
        prettyString = [[NSString alloc]initWithData:finalData encoding:NSUTF8StringEncoding];
        [prettyString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        statusListData = jsonArray;
        [listOfStatus reloadData];
    }
}

-(void)readStatusFromFile{
    NSFileManager *manager = [[NSFileManager alloc]init];
    NSData *contents;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSString *path =  [basePath stringByAppendingPathComponent:@"list_of_status.json"];
    NSMutableArray *readData2;
    readData2 = [[NSMutableArray alloc]init];
    if([manager fileExistsAtPath:path]){
        contents = [manager contentsAtPath:path];
        readData2=[NSJSONSerialization JSONObjectWithData:contents options:NSJSONReadingMutableContainers  error:nil];
        [listOfStatus reloadData];
        if(readData2){
            //             NSLog(@"%@", readData2);
            statusListData = readData2;
            [listOfStatus reloadData];
        }
        else{
            NSLog(@"Status  file is empty");
        }

    }
    else{
         NSLog(@"Status file not exists");
    }

    
}

-(void)textDidChange:(NSNotification *)notification{
    symbolCounter.stringValue=[NSString stringWithFormat:@"Characters count:%lu", [textNewStatus.string length]];
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row = [listOfStatus selectedRow];
    NSString *item;
    item = statusListData[row][@"status"];
    textNewStatus.string = item;
    
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([statusListData count]>0){
        return [statusListData count];
    }
    return 0;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([statusListData count]>0){
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    [cell.textField setStringValue:statusListData[row][@"status"]];
        return cell;
    }
    return nil;
}

@end
