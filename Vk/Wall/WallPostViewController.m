//
//  WallPostViewController.m
//  vkapp
//
//  Created by sim on 20.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "WallPostViewController.h"
#import "WallPostRecentGroupsCustomCell.h"
#import "ShowVideoViewController.h"
#import "ShowPhotoViewController.h"
#import "DocsPersonalViewcontroller.h"
#import "SmilesViewController.h"
#import "TasksViewController.h"
#import <EventKit/EventKit.h>
@interface WallPostViewController () <NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate,NSCollectionViewDataSource, NSCollectionViewDelegate>

@end

@implementation WallPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    textView.delegate=self;
    groupsToPost = [[NSMutableArray alloc]init];
    messagesToPost = [[NSMutableArray alloc]init];
    _app = [[appInfo alloc]init];
//    self.view.wantsLayer=YES;
    recentGroups.delegate = self;
    recentGroups.dataSource = self;
    listOfMessages.dataSource = self;
    listOfMessages.delegate = self;
    attachmentsCollectionView.delegate=self;
    attachmentsCollectionView.dataSource=self;
    indexPaths = [[NSMutableArray alloc]init];
    queuePostsInSession = [[NSMutableArray alloc]init];
    [textView setRichText:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertSmile:) name:@"InsertSmileWall" object:nil];
    
//    attachmentsCollectionView.wantsLayer=YES;
    attachmentsData = [[NSMutableArray alloc]init];
//   attachmentsCollectionView.layer.backgroundColor = [NSColor clearColor];
//   attachmentsCollectionView.backgroundView = [[NSView alloc] initWithFrame:CGRectZero];
    groupsData = [[NSMutableArray alloc]init];
    _captchaHandler = [[VKCaptchaHandler alloc]init];
    [groupsList removeAllItems];
    [groupsData addObject:_app.person];

//    [groupsList addItemWithTitle:@"Title1"];

    messagesToPost = [[NSMutableArray alloc]initWithArray:[self ReadMessages]];
    [listOfMessages reloadData];
    groupsToPost = [[NSMutableArray alloc]initWithArray:[self ReadGroups]];
    [recentGroups reloadData];

    startedSessionStatusLabel.wantsLayer=YES;
    startedSessionStatusLabel.layer.masksToBounds=YES;
    startedSessionStatusLabel.layer.cornerRadius=5;
    
    [self loadGroups];
    _twitterClient = [[TwitterClient alloc]initWithTokensFromCoreData];
    _tumblrClient = [[TumblrClient alloc]initWithTokensFromCoreData];
    afterPost.hidden = postRadio.state==1 ? YES : NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addToAttachments:) name:@"addToAttachments" object:nil];
    preparedAttachmentsString = [[NSMutableArray alloc]init];
     postTargetSourceSelector = [[NSMutableDictionary alloc]initWithDictionary:@{@"vk":@0, @"tumblr":@0, @"twitter":@0}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeItemFromAttachments:) name:@"removeItemFromAttachments" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeScheduledPost:) name:@"DoScheduledPost" object:nil];
   
    [self setSelectorsButtonsState];
    
}
-(void)viewDidAppear{
    
    if(![self parentViewController]){
        self.view.window.level = NSFloatingWindowLevel;
    }
    
}

-(void)textDidChange:(NSNotification *)notification{
    
    charCount.stringValue=[NSString stringWithFormat:@"Characters count: %li", [textView.string length]];
    [self setSelectorsButtonsState];
}

-(void)addToAttachments:(NSNotification *)notification{
    mediaAttachmentType = notification.userInfo[@"type"];
    [indexPaths removeAllObjects];
    NSDictionary *object = @{@"type":mediaAttachmentType, @"data":notification.userInfo[@"data"]};
    if(![attachmentsData containsObject:object]){
        [attachmentsData insertObject:object atIndex:0];
        
        //    [newData addObject:@{@"type":mediaAttachmentType, @"data":notification.userInfo[@"data"]}];
        [indexPaths addObject:[NSIndexPath indexPathForItem: 0 inSection:0]];
        
        [attachmentsCollectionView insertItemsAtIndexPaths:[NSSet setWithArray:indexPaths]];
        //    NSLog(@"%@", indexPaths);
        [attachmentsCollectionView setContent:attachmentsData];
        
        countPhotoInAttachments = 0;
        countVideoInAttachments = 0;
        countDocsInAttachments = 0;
        ////    NSLog(@"%@", attachmentsData);
        preparedAttachmentsString = [[NSMutableArray alloc]init];
        for(NSDictionary *i in attachmentsData){
            if([i[@"type"] isEqual:@"photo"]){
                countPhotoInAttachments++;
            }
            else if([i[@"type"] isEqual:@"video"]){
                countVideoInAttachments++;
            }
            else if([i[@"type"] isEqual:@"doc"]){
                countDocsInAttachments++;
            }
//            NSInteger ownerInAttachString =i[@"data"][@"owner"]?abs([i[@"data"][@"owner"] intValue]):abs([i[@"data"][@"owner_id"]intValue]);
             NSString *ownerInAttachString =i[@"data"][@"owner"]?i[@"data"][@"owner"]:i[@"data"][@"owner_id"];
            [preparedAttachmentsString addObject:[NSString stringWithFormat:@"%@%@_%@", i[@"type"], ownerInAttachString, [i[@"type"] isEqualToString:@"video"] ? i[@"data"][@"id"] : i[@"data"][@"items"][@"id"] ? i[@"data"][@"items"][@"id"] : i[@"data"][@"id"] ]];
            
        }
        //
        attachmentsPostVKString = [preparedAttachmentsString componentsJoinedByString:@","];
        NSLog(@"%@",attachmentsPostVKString);
        attachmentsCountLabel.stringValue = [NSString stringWithFormat:@"Photos:%i Videos:%i Docs:%i", countPhotoInAttachments, countVideoInAttachments, countDocsInAttachments];
        
        [attachmentsCollectionView reloadItemsAtIndexPaths:[NSSet setWithArray:indexPaths]];
        //    [attachmentsCollectionView reloadData];
    }
}
-(void)removeItemFromAttachments:(NSNotification*)notification{
    
    NSIndexPath *indexPath =[NSIndexPath indexPathForItem:[attachmentsData indexOfObject:notification.userInfo[@"data"]] inSection:0];
    
    [attachmentsData removeObjectAtIndex:[attachmentsData indexOfObject:notification.userInfo[@"data"]]];
    [attachmentsCollectionView deleteItemsAtIndexPaths:[NSSet setWithObject:indexPath]];
    attachmentsCollectionView.content=attachmentsData;
    //    [attachmentsCollectionView reloadData];
    //    NSLog(@"%@", attachmentsData);
    countPhotoInAttachments = 0;
    countVideoInAttachments = 0;
    countDocsInAttachments = 0;
    attachmentsPostVKString = nil;
    [preparedAttachmentsString removeAllObjects];
    for(NSDictionary *i in attachmentsData){
        if([i[@"type"] isEqual:@"photo"]){
            countPhotoInAttachments++;
        }
        else if([i[@"type"] isEqual:@"video"]){
            countVideoInAttachments++;
        }
        else if([i[@"type"] isEqual:@"doc"]){
            countDocsInAttachments++;
        }
        [preparedAttachmentsString addObject:[NSString stringWithFormat:@"%@%@_%@", i[@"type"], i[@"data"][@"owner_id"], [i[@"type"] isEqualToString:@"video"] ? i[@"data"][@"id"] : i[@"data"][@"items"][@"id"] ? i[@"data"][@"items"][@"id"] : i[@"data"][@"id"] ]];
        
    }
    //
    attachmentsPostVKString = [preparedAttachmentsString componentsJoinedByString:@","];
    NSLog(@"%@",attachmentsPostVKString);
    
    attachmentsCountLabel.stringValue = [NSString stringWithFormat:@"Photos:%i Videos:%i Docs:%i", countPhotoInAttachments, countVideoInAttachments, countDocsInAttachments];
    
    
    
}

-(void)observeScheduledPost:(NSNotification*)object{
    NSLog(@"%@", object.userInfo);
    NSMutableDictionary *object1 = [object.userInfo mutableCopy];
//       dispatch_after(1, dispatch_get_main_queue(), ^(void){
           [self prepareForPost:object1[@"target_owner"] attachs:object1[@"attachments"] msg:object1[@"message"] repeatPost:NO scheduled:YES];
//       });
}

- (IBAction)closeStartedSessionAction:(id)sender {
    addPostToQueueBut.hidden=YES;
    startedSessionStatusLabel.hidden=YES;
    startedSessionCloseBut.hidden=YES;
    publishingDateForPost.hidden=YES;
    startedSessionCloseBut.enabled=YES;
    newSessionStartBut.enabled=YES;
    savePostsSessionBut.hidden=YES;
    [queuePostsInSession removeAllObjects];
}
- (IBAction)startSession:(id)sender {
    publishingDateForPost.hidden=NO;
    addPostToQueueBut.hidden=NO;
    startedSessionStatusLabel.hidden=NO;
    startedSessionCloseBut.hidden=NO;
    currentPostsSessionName = newSessionNameField.stringValue;
    startedSessionStatusLabel.stringValue=[NSString stringWithFormat:@"Session: %@ Posts: %@", currentPostsSessionName, @0];
    newSessionNameField.stringValue=@"";
    newSessionStartBut.enabled=NO;
//    savePostsSessionBut.hidden=NO;
    publishingDateForPost.datePickerElements = NSHourMinuteDatePickerElementFlag | NSYearMonthDayDatePickerElementFlag | NSHourMinuteSecondDatePickerElementFlag;
    NSCalendar *cal = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitMinute | NSCalendarUnitHour fromDate:[NSDate date]];
    [comps setSecond:0];
    [comps setCalendar:cal];
    [publishingDateForPost setDateValue: [comps date] ];
  
 
}
- (IBAction)saveSession:(id)sender {
 
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Fifth" bundle:nil];
    
    TasksViewController *contr = [story instantiateControllerWithIdentifier:@"TasksView"];
//    contr.view = [[NSView alloc]init];
    [contr loadView];
    [contr viewDidLoad];
    addPostToQueueBut.hidden=YES;
    startedSessionStatusLabel.hidden=YES;
    startedSessionCloseBut.hidden=YES;
    publishingDateForPost.hidden=YES;
    startedSessionCloseBut.enabled=YES;
    newSessionStartBut.enabled=YES;
    savePostsSessionBut.hidden=YES;
   
    dispatch_after(1, dispatch_get_main_queue(), ^(void){
         [[NSNotificationCenter defaultCenter]postNotificationName:@"addNewSessionTask" object:nil userInfo:@{@"session_type":@"post", @"session_name":currentPostsSessionName, @"session_data": [queuePostsInSession mutableCopy]}];
    
    });
    dispatch_after(1, dispatch_get_main_queue(), ^(void){
      [queuePostsInSession removeAllObjects];
    });
    startedSessionStatusLabel.stringValue=[NSString stringWithFormat:@"Session: %@ Posts: %li", @"", [queuePostsInSession count]];
}
- (IBAction)addPostToQueue:(id)sender {
    message=[textView.string isEqualToString:@""] ? nil : [textView.string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] ;
    
    NSDate *selectedDate = publishingDateForPost.dateValue;
    [queuePostsInSession addObject:@{@"target_owner":publicId.stringValue, @"message":message?message:@"", @"attach_urls":[attachmentsData mutableCopy], @"attachments":attachmentsPostVKString?attachmentsPostVKString:@"", @"date":selectedDate}];
  
    startedSessionStatusLabel.stringValue=[NSString stringWithFormat:@"Session: %@ Posts: %li", currentPostsSessionName, [queuePostsInSession count]];
//    NSLog(@"%@", queuePostsInSession);
//    NSLog(@"%@ %@", message, attachmentsPostVKString );
    if([queuePostsInSession count]>0){
        savePostsSessionBut.hidden=NO;
    }
}

-(void)insertSmile:(NSNotification*)notification{
    textView.string = [NSString stringWithFormat:@"%@%@", textView.string, notification.userInfo[@"smile"]];
}

-(void)setSelectorsButtonsState{
    if([textView.string isEqualToString:@""]){
        [PostTwitter setEnabled:NO];
        
        [postTumblr setEnabled:NO];
    }else{
        [PostTwitter setEnabled:YES];
        [postTumblr setEnabled:YES];
    }
}

- (IBAction)newPost:(id)sender {
    
    textView.string = @"";
    [attachmentsData removeAllObjects];
    [attachmentsCollectionView setContent:attachmentsData];
    [attachmentsCollectionView reloadData];
    [preparedAttachmentsString removeAllObjects];
    [indexPaths removeAllObjects];

}

- (IBAction)deleteMessage:(id)sender {
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication]delegate] managedObjectContext];
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext=moc;
    NSView *parentCell = [sender superview];
    NSInteger row = [listOfMessages rowForView:parentCell];
    [temporaryContext performBlock:^{
    
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKMessagesToPost"];
        
        [request setReturnsObjectsAsFaults:NO];
        //    [request setResultType:NSDictionaryResultType];
        NSError *readError;
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[temporaryContext executeFetchRequest:request error:&readError]];
        [temporaryContext deleteObject:array[row]];
        NSError *saveError;
        if(![temporaryContext save:&saveError]){
            NSLog(@"Error");
        }
        [moc performBlock:^{
            NSError *error = nil;
            if (![moc save:&error]) {
                NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
                abort();
            }else{
                [temporaryContext performBlock:^{
                    
                    
                    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKMessagesToPost"];
                    //    temporaryContext.parentContext = moc;
                    //              NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"VKMessagesToPost" inManagedObjectContext:moc];
                    
                    
                    [request setReturnsObjectsAsFaults:NO];
                    [request setResultType:NSDictionaryResultType];
                    NSError *readError;
                    messagesToPost = [[NSMutableArray alloc]initWithArray: [temporaryContext executeFetchRequest:request error:&readError]];
                  
                    [listOfMessages reloadData];
                }];
                
            }
        }];
    }];
}
- (IBAction)removeGroupsToPost:(id)sender {
    NSInteger row = [recentGroups selectedRow];
    NSString *groupId =  groupsToPost[row][@"id"];
//    NSLog(@"%@", groupId);
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"VKGroupsToPost"];
    [request setReturnsObjectsAsFaults:NO];
    //    [request setResultType:NSDictionaryResultType];
    [request setPredicate:[NSPredicate predicateWithFormat:@"id == %@", groupId]];
    NSError *fetchError;
    NSError *delError;
    NSArray *array = [moc executeFetchRequest:request error:&fetchError];
    for(NSManagedObject *object in array){
        [moc deleteObject:object];
        if(![moc save:&delError]){
            NSLog(@"Delete groups to post object error.");
        }else{
            NSLog(@"Group is successfully deleted");
            [self reloadRecentGroups];
        }
    }
//    [self removeAllGroups];
    
    
}
-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"videosForAttachments"]){
        ShowVideoViewController *controller = (ShowVideoViewController *)segue.destinationController;
        controller.loadFromWallPost=YES;
        controller.recivedDataForMessage=@{@"loadVideosForAttachments":@"yes"};
    }
    else if([segue.identifier isEqualToString:@"photosForAttachment"]){
        ShowPhotoViewController *controller = (ShowPhotoViewController *)segue.destinationController;
        controller.receivedData=@{@"loadPhotosForAttachments":@"yes"};
    }
    else if([segue.identifier isEqualToString:@"ShowDocsForAttachSegue"]){
        DocsPersonalViewcontroller *controller = (DocsPersonalViewcontroller*)segue.destinationController;
        controller.recivedData = @{@"loadDocsForAttachments":@"yes"};
    }
    else if([segue.identifier isEqualToString:@"SmilesViewSegue"]){
        SmilesViewController *contr = (SmilesViewController *)segue.destinationController;
        contr.source = @"wall";
    }
    
}



-(NSArray*)ReadGroups{
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication]delegate] managedObjectContext];
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext=moc;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKGroupsToPost"];
    [request setReturnsObjectsAsFaults:NO];
    [request setResultType:NSDictionaryResultType];
    NSError *readError;
    NSArray *array = [temporaryContext executeFetchRequest:request error:&readError];
    
    return array;
}
-(void)writeGroup{
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication]delegate] managedObjectContext];
       NSMutableArray *tempArray = [[NSMutableArray alloc]init];
//    [self removeAllGroups];
    if([self ReadGroups]!=nil){
     
        for(NSDictionary *i in [self ReadGroups]){
            [tempArray addObject:i[@"id"]];
        }
     }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([publicId.stringValue intValue]<0){
            [self getGroupInfo:^(NSData *data) {
                if(data){
                    NSDictionary *getGroupResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if(!getGroupResponse[@"error"]){
                        groupAvatar = getGroupResponse[@"response"][0][@"photo_50"];
                        groupDescription = getGroupResponse[@"response"][0][@"description"];
                        groupDeactivated = getGroupResponse[@"response"][0][@"deactivated"] ? getGroupResponse[@"response"][0][@"deactivated"] : @"";
                        groupName = getGroupResponse[@"response"][0][@"name"];
                        if(![tempArray containsObject:publicId.stringValue]){
                            NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"VKGroupsToPost" inManagedObjectContext:moc];
                            [object setValue:publicId.stringValue forKey:@"id"];
                            [object setValue:groupAvatar forKey:@"photo"];
                            [object setValue:groupDeactivated forKey:@"deactivated"];
                            [object setValue:groupDescription forKey:@"desc"];
                            [object setValue:groupName forKey:@"name"];
                            NSError *saveError;
                            if(![moc save:&saveError]){
                                NSLog(@"Error");
                            }else{
                                NSLog(@"Saved");
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    [self reloadRecentGroups];
                                });
                            }
                        }

                    }
                }
            }];
        }
        else{
            [self getUserInfo:^(NSData *data) {
                if(data){
                    NSDictionary *getUserResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if(!getUserResponse[@"error"]){
                        groupAvatar = getUserResponse[@"response"][0][@"photo_50"];
                        groupDescription = getUserResponse[@"response"][0][@"description"];
                        groupDeactivated = getUserResponse[@"response"][0][@"deactivated"] ? getUserResponse[@"response"][0][@"deactivated"] : @"";
                        groupName = [NSString stringWithFormat:@"%@ %@", getUserResponse[@"response"][0][@"first_name"], getUserResponse[@"response"][0][@"last_name"]];
                        if(![tempArray containsObject:publicId.stringValue]){
                            NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"VKGroupsToPost" inManagedObjectContext:moc];
                            [object setValue:publicId.stringValue forKey:@"id"];
                            [object setValue:groupAvatar forKey:@"photo"];
                            [object setValue:groupDeactivated forKey:@"deactivated"];
                            [object setValue:groupDescription forKey:@"desc"];
                            [object setValue:groupName forKey:@"name"];
                            NSError *saveError;
                            if(![moc save:&saveError]){
                                NSLog(@"Error");
                            }else{
                                NSLog(@"Saved");
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    [self reloadRecentGroups];
                                });
                            }
                        }
                        
                    }
                }
            }];
            
        }
    });
    }
-(void)removeAllGroups{

    NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc ] initWithEntityName:@"VKGroupsToPost"];
    
    NSError *error;
    NSArray *items = [moc executeFetchRequest:fetchRequest error:&error];
    //    fetchRequest = nil;
    
    if ([items count]>0){
        for (NSManagedObject *managedObject in items) {
            [moc deleteObject:managedObject];
            
        }
        if (![moc save:&error]) {
        }
    }

}
-(NSArray *)ReadMessages{
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication]delegate] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKMessagesToPost"];
    temporaryContext.parentContext = moc;
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"VKMessagesToPost" inManagedObjectContext:temporaryContext];

    [request setEntity:entityDesc];
    [request setReturnsObjectsAsFaults:NO];
    [request setResultType:NSDictionaryResultType];
    NSError *readError;
    NSArray *array = [temporaryContext executeFetchRequest:request error:&readError];
    
    return array;
}
-(void)writeMessage{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    if([self ReadMessages]!=nil){
        
        for(NSDictionary *i in [self ReadMessages]){
            [tempArray addObject:i[@"message"]];
        }
    }
   
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication]delegate] managedObjectContext];
     NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext=moc;
   
    //    [self removeAllGroups];
  [temporaryContext performBlock:^{
      if(![tempArray containsObject:textView.string]){
          NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"VKMessagesToPost" inManagedObjectContext:temporaryContext];
          
          [object setValue:textView.string forKey:@"message"];
          NSError *saveError;
          if(![temporaryContext save:&saveError]){
              NSLog(@"Error");
          }
          [moc performBlockAndWait:^{
              NSError *error = nil;
              if (![moc save:&error]) {
                  NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
                  abort();
              }else{
                  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKMessagesToPost"];
                  //    temporaryContext.parentContext = moc;
                  //              NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"VKMessagesToPost" inManagedObjectContext:moc];
                  [request setReturnsObjectsAsFaults:NO];
                  [request setResultType:NSDictionaryResultType];
                  NSError *readError;
                  messagesToPost = [[NSMutableArray alloc]initWithArray: [moc executeFetchRequest:request error:&readError]];
                  //              [listOfMessages reloadData];
                  NSLog(@"%@", messagesToPost);
                  //                  [self reloadMessages];
                  [listOfMessages reloadData];
              }
          }];
      }
  }];
}
-(void)reloadRecentGroups{
    groupsToPost = [[NSMutableArray alloc]initWithArray:[self ReadGroups]];
    [recentGroups reloadData];
}
-(void)reloadMessages{
    messagesToPost = [[NSMutableArray alloc]initWithArray:[self ReadMessages]];
          [listOfMessages reloadData];
}
-(void)loadGroups{
    [groupsList addItemWithTitle:@"Personal"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
                [groupsData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [groupsList addItemWithTitle:i[@"name"]];
                });
            }
        }]resume];
    });
}
- (IBAction)groupsListAction:(id)sender {
    publicId.stringValue =[NSString stringWithFormat:@"%@", [groupsData objectAtIndex:[groupsList indexOfSelectedItem]]];
    NSLog(@"%@", [groupsData objectAtIndex:[groupsList indexOfSelectedItem]]);
    
}
- (IBAction)stopPost:(id)sender {
    stopFlag=YES;
    [progressSpin stopAnimation:self];
}
- (IBAction)radioAction:(id)sender {
//    NSLog(@"%@", sender);
    if(postRadio.state==1){
//        NSLog(@"Post");
        afterPost.hidden=YES;
        
    }
    if(commentRadio.state==1){
//        NSLog(@"Comment");
        afterPost.hidden=NO;
    }
}
- (IBAction)removeText:(id)sender {
    
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication]delegate] managedObjectContext];
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext=moc;
    [temporaryContext performBlock:^{
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKMessagesToPost"];
        
        [request setReturnsObjectsAsFaults:NO];
        //    [request setResultType:NSDictionaryResultType];
        
        NSError *readError;
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[temporaryContext executeFetchRequest:request error:&readError]];
        [temporaryContext deleteObject:array[selectedObject]];
        NSError *saveError;
        if(![temporaryContext save:&saveError]){
            NSLog(@"Error");
        }
        [moc performBlockAndWait:^{
            NSError *error = nil;
            if (![moc save:&error]) {
                NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
                abort();
            }else{
                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"VKMessagesToPost"];
                //    temporaryContext.parentContext = moc;
                //              NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"VKMessagesToPost" inManagedObjectContext:moc];
                [request setReturnsObjectsAsFaults:NO];
                [request setResultType:NSDictionaryResultType];
                NSError *readError;
                messagesToPost = [[NSMutableArray alloc]initWithArray: [moc executeFetchRequest:request error:&readError]];
                //              [listOfMessages reloadData];
                NSLog(@"%@", messagesToPost);
                //                  [self reloadMessages];
                [listOfMessages reloadData];
            }
        }];
    }];
}
-(void)prepareForPost:(NSString*)ownerID attachs:(NSString*)attachs msg:(NSString*)msg repeatPost:(BOOL)repeatPost scheduled:(BOOL)scheduled{
    
    alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    guId = [NSMutableString stringWithCapacity:20];
    postAfter =  [afterPost.stringValue intValue]-1;
    if(scheduled){
         postTargetSourceSelector[@"vk"]=@1;
        owner = [NSString stringWithFormat:@"%@",ownerID];
//        attachmentsPostVKString = attachs;
        attachmentsPostVKStringScheduled = [attachs mutableCopy];
        message = [msg isEqual:@""]?nil:[msg stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [self postWithoutRepeat:YES];
        NSLog(@"%@, %@, %@", owner, attachmentsPostVKStringScheduled, message);
   

    }else{
        owner = publicId.stringValue;
        message=[textView.string isEqualToString:@""] ? nil : [textView.string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] ;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if(PostVK.state==0 && PostTwitter.state==0 && postTumblr.state==0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    cautionImage.hidden=NO;
                    cautionLabel.hidden=NO;
                    cautionLabel.stringValue=@"Select social network";
                    [progressSpin stopAnimation:self];
                });
            }
            
            else{
                if (repeatPost){
                    
                    
                    if(postRadio.state){
                        [self postWithRepeat];
                    }else if(commentRadio.state){
                        [self addCommentWithRepeat];
                    }
                    
                }
                else{
                    if(postRadio.state){
                        [self postWithoutRepeat:NO];
                    }else if(commentRadio.state){
                        [self addCommentWithoutRepeat];
                    }
                }
            }
            
        });

    }
}
- (IBAction)makePostAction:(id)sender {
    repeatState = repeat.state;
    if(PostVK.state){
        postTargetSourceSelector[@"vk"]=@1;
    }
    if(PostTwitter.state){
        postTargetSourceSelector[@"twitter"]=@1;
    }
    if(postTumblr.state){
        postTargetSourceSelector[@"tumblr"]=@1;
    }
    [self prepareForPost:nil attachs:nil msg:nil repeatPost:repeatState scheduled:NO];
}
-(void)postWithRepeat{
    stopFlag = NO;
    while(1){
        if(!stopFlag){
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&message=%@&access_token=%@&v=%@", owner, message, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *postResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if (postResponse[@"error"]){
                    if([postResponse[@"error"][@"error_code"] intValue] == 14){
                        NSLog(@"%@:%@", postResponse[@"error"][@"error_code"], postResponse[@"error"][@"error_msg"]);
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSInteger result = [[_captchaHandler handleCaptcha:postResponse[@"error"][@"captcha_img"]] runModal];
                            if (result == NSAlertFirstButtonReturn){
                                //                                        NSLog(@"%@", enterCode.stringValue);
                                //                                        NSLog(@"%@", postResponse[@"error"][@"captcha_sid"]);
                                NSURLSessionDataTask *addComment2 = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&v=%@&access_token=%@&message=%@&captcha_sid=%@&captcha_key=%@", owner, _app.version, _app.token, message, postResponse[@"error"][@"captcha_sid"], [_captchaHandler readCode]]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                    if(data){
                                        NSDictionary *jsonData2 = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                        NSLog(@"%@", jsonData2);
                                    }
                                    dispatch_semaphore_signal(semaphore);
                                    
                                }];
                                [addComment2 resume];
                                
                            }
                            if (result == NSAlertSecondButtonReturn){
                                stopFlag = YES;
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [progressSpin stopAnimation:self];
                                });
                                //                                                dispatch_semaphore_signal(semaphore);
                            }
                        });
                    }
                    else{
                        NSLog(@"%@:%@", postResponse[@"error"][@"error_code"], postResponse[@"error"][@"error_msg"]);
                        
                        
                    }
                }else{
                    dispatch_semaphore_signal(semaphore);
                    NSLog(@"%@", postResponse);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressSpin stopAnimation:self];
                });
                
                
            }]resume];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_signal(semaphore);
            sleep(1);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressSpin stopAnimation:self];
            });
            break;
        }
        
    }
    
}
-(void)addCommentWithoutRepeat{
    __block NSString *post_id;
    NSURLSessionDataTask *getPostId = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.get?owner_id=%@&count=1&v=%@&access_token=%@&offset=%ld", owner, _app.version, _app.token, postAfter ]]completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for (NSDictionary *i in jsonData[@"response"][@"items"]){
            post_id = i[@"id"];
            
            
        }
        sleep(1);
        NSURLSessionDataTask *addComment1 = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.addComment?owner_id=%@&post_id=%@&v=%@&access_token=%@&text=%@", owner, post_id, _app.version, _app.token, message]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (jsonData[@"error"]){
                
                NSLog(@"%@:%@", jsonData[@"error"][@"error_code"], jsonData[@"error"][@"error_msg"]);
            }
            else{
                NSLog(@"%@", jsonData);
            }
        }];
        [addComment1 resume];
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressSpin stopAnimation:self];
            
        });
    }];
    [getPostId resume];

}
-(void)addCommentWithRepeat{
    stopFlag=NO;
    __block NSString *post_id;
    NSString *afterPostFieldString = afterPostIdField.stringValue;
    if(![afterPostFieldString isEqualToString:@""]){
        post_id = afterPostFieldString;
        NSLog(@"POST ID %@", post_id);
    }else{
        NSURLSessionDataTask *getPostId = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.get?owner_id=%@&count=1&v=%@&access_token=%@&offset=%ld", owner, _app.version, _app.token, postAfter ]]completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(data){
                NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                for (NSDictionary *i in jsonData[@"response"][@"items"]){
                    post_id = i[@"id"];
                }
                
            }
        }];
        [getPostId resume];
        sleep(1);
    }
    while(1){
        if(!stopFlag){
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            [guId setString:@""];
            for (NSUInteger i = 0U; i < 20; i++) {
                u_int32_t r = arc4random() % [alphabet length];
                unichar c = [alphabet characterAtIndex:r];
                [guId appendFormat:@"%C", c];
            }
            NSURLSessionDataTask *addComment1 = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.createComment?owner_id=%@&post_id=%@&v=%@&access_token=%@&text=%@&guid=%@", owner, post_id, _app.version, _app.token, message, guId]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if(data){
                    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@", jsonData);
                    if (jsonData[@"error"]){
                        if([jsonData[@"error"][@"error_code"] intValue] == 14){
                            NSLog(@"%@:%@", jsonData[@"error"][@"error_code"], jsonData[@"error"][@"error_msg"]);
                            //                                    NSLog(@"%@", jsonData[@"error"]);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSInteger result = [[_captchaHandler handleCaptcha:jsonData[@"error"][@"captcha_img"]] runModal];
                                if ( result == NSAlertFirstButtonReturn){
                                    NSURLSessionDataTask *addComment2 = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.createComment?owner_id=%@&post_id=%@&v=%@&access_token=%@&text=%@&captcha_sid=%@&captcha_key=%@&guid=%@", owner, post_id, _app.version, _app.token, message, jsonData[@"error"][@"captcha_sid"], _captchaHandler.enterCode.stringValue, guId]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                        if(data){
                                            NSDictionary *jsonData2 = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                            NSLog(@"%@", jsonData2);
                                        }
                                        dispatch_semaphore_signal(semaphore);
                                    }];
                                    [addComment2 resume];
                                }
                                if (result == NSAlertSecondButtonReturn){
                                    stopFlag = YES;
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [progressSpin stopAnimation:self];
                                    });
                                    //                                                dispatch_semaphore_signal(semaphore);
                                }
                                
                            });
                        }
                        else{
                            NSLog(@"%@:%@", jsonData[@"error"][@"error_code"], jsonData[@"error"][@"error_msg"]);
                        }
                    }
                    else{
                        //                                NSLog(@"%@", jsonData);
                        
                        dispatch_semaphore_signal(semaphore);
                        
                    }
                }
            }];
            [addComment1 resume];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_signal(semaphore);
            //
            sleep(1);
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressSpin stopAnimation:self];
            });
            break;
        }
    }
}
-(void)postWithoutRepeat:(BOOL)scheduled{
    if([postTargetSourceSelector[@"vk"] intValue]){
        NSString *vkURL;
        __block NSString *messageForVk;
        void (^startPostVk)(NSString *)=^(NSString *url){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if(data){
                    NSDictionary *postResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@", postResponse);
                    
                    if([postResponse[@"response"][@"post_id"] intValue]!=0){
                        NSLog(@"New post in Vkontakte successfully done");
                       
                    }
                    else{
                        NSLog(@"New post in Vkontakte is not done");
                        
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [progressSpin stopAnimation:self];
                        
                    });
                    postTargetSourceSelector[@"vk"]=@0;
                }
            }]resume];
        };
        if(message && ([attachmentsData count]>0 || scheduled)){
            //                    messageForVk = [message stringByReplacingOccurrencesOfString:@"%20" withString:@"%26%2312288;"];
            messageForVk=message;
            vkURL = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&message=%@&attachments=%@&access_token=%@&v=%@%@",owner, messageForVk, scheduled ? attachmentsPostVKStringScheduled : attachmentsPostVKString, _app.token, _app.version, [owner intValue]<0?[NSString stringWithFormat:@"&from_group=%li", fromGroup.state ]:@""];
            startPostVk(vkURL);
        }
        else if(!message  && ([attachmentsData count]>0 || scheduled)){
    
            vkURL = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&attachments=%@&access_token=%@&v=%@%@",owner,scheduled ? attachmentsPostVKStringScheduled : attachmentsPostVKString, _app.token, _app.version,[owner intValue]<0?[NSString stringWithFormat:@"&from_group=%li", fromGroup.state ]:@""];
            NSLog(@"%@", vkURL);
            startPostVk(vkURL);
        }
        else if(message  && ([attachmentsData count]==0 || scheduled)){
            //                    messageForVk = [message stringByReplacingOccurrencesOfString:@"%20" withString:@"%26%2312288;"];
            messageForVk=message;
            vkURL = [NSString stringWithFormat:@"https://api.vk.com/method/wall.post?owner_id=%@&message=%@&access_token=%@&v=%@%@",owner, messageForVk, _app.token, _app.version,[owner intValue]<0?[NSString stringWithFormat:@"&from_group=%li", fromGroup.state ]:@""];
            startPostVk(vkURL);
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                cautionImage.hidden=NO;
                cautionLabel.hidden=NO;
                cautionLabel.stringValue=@"Textfield is empty and not attachments.";
                [progressSpin stopAnimation:self];
            });
        }
        NSLog(@"%@", vkURL);
        
        
    }
    if([postTargetSourceSelector[@"twitter"] intValue]){
        if([attachmentsData count]>0){
            
            [_twitterClient APIRequest:@"statuses" rmethod:@"update.json" query:@{@"image":attachmentsData,@"status":message} handler:^(NSData *data) {
                if(data){
                    NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if(resp[@"id"]){
                        NSLog(@"New post with media in Twitter successfully done");
                       
                    }
                    else{
                        NSLog(@"New post with media in Twitter is not done");
                        
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressSpin stopAnimation:self];
                    
                });
                postTargetSourceSelector[@"twitter"]=@0;
            }];
            
        }else{
            
            [_twitterClient APIRequest:@"statuses" rmethod:@"update.json" query:@{@"status":message} handler:^(NSData *data) {
                NSDictionary *twittResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", twittResp);
                if(twittResp[@"id"])
                    NSLog(@"New post in Twitter successfully done");
                else
                    NSLog(@"New post in Twitter is not done");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressSpin stopAnimation:self];
                });
            }];
            
        }
    }
    if([postTargetSourceSelector[@"tumblr"] intValue]){
        if([attachmentsData count]>0){
            [_tumblrClient APIRequest:@"blog/hfdui2134.tumblr.com" rmethod:@"post" query:@{@"type":@"photo", @"caption":message, @"data64":attachmentsData} handler:^(NSData *data) {
                if(data){
                    NSDictionary *tumblrPhotoPostResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if(tumblrPhotoPostResp[@"response"]){
                        NSLog(@"Tumblr post with media is successfully done. Post Id:%@", [NSString stringWithFormat:@"%@", tumblrPhotoPostResp[@"response"][@"id"]]);
                     
                    }else{
                        NSLog(@"Tumblr post with media is not  done. Something wrong.");
                       
                    }
                    //                           NSString *tumblrResp = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                    //                           NSLog(@"%@", tumblrResp);
                }else{
                    NSLog(@"Tumblr post data not recieved");
                   
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressSpin stopAnimation:self];
                   
                });
                 postTargetSourceSelector[@"tumblr"]=@0;
            }];
            
        }else{
            [_tumblrClient APIRequest:@"blog/hfdui2134.tumblr.com" rmethod:@"post" query:@{@"type":@"text", @"body":message} handler:^(NSData *data) {
                if(data){
                    NSDictionary *tumblrTextPostResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if(tumblrTextPostResp[@"response"][@"id"]){
                        NSLog(@"Tumblr post without media is successfully done. Post Id:%@", [NSString stringWithFormat:@"%@", tumblrTextPostResp[@"response"][@"id"]]);
                    }else{
                        NSLog(@"Tumblr post without media is not  done. Something wrong.");
                    }
                    //                           NSString *tumblrResp = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
                    //                           NSLog(@"%@", tumblrResp);
                }else{
                    NSLog(@"Tumblr post data not recieved");
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressSpin stopAnimation:self];
                });
            }];
        }
    }
}

-(void)getGroupInfo:(OnComplete)completion{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.getById?group_id=%i&access_token=%@&v=%@", abs([publicId.stringValue intValue]), _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completion(data);
        
    }]resume];
    
}
-(void)getUserInfo:(OnComplete)completion{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_id=%i&fields=photo_50&access_token=%@&v=%@", [publicId.stringValue intValue], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completion(data);
        
    }]resume];
}


-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    if([notification.object isEqual:recentGroups]){
        NSInteger row = [recentGroups selectedRow] ?  [recentGroups selectedRow] : 0;
        if(row+1<=[groupsToPost count]){
            NSString *item = [NSString stringWithFormat:@"%@", groupsToPost[row][@"id"]];
            publicId.stringValue = item;
        }
    }
    else if([notification.object isEqual:listOfMessages]){
        
        NSInteger row = [listOfMessages selectedRow];
//        if(row){
            NSString *item = [NSString stringWithFormat: @"%@", messagesToPost[row][@"message"]];
            textView.string = item;
            selectedObject = row;
//        }
    }
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if ([tableView isEqual:recentGroups]){
        if ([groupsToPost count]>0) {
            return [groupsToPost count];
        }
    }
    else if([tableView isEqual:listOfMessages]){
        return [messagesToPost count];
    }
    return 0;
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
     if ([tableView isEqual:recentGroups]){
         if ([groupsToPost count]>0) {
             WallPostRecentGroupsCustomCell*cell=[[WallPostRecentGroupsCustomCell alloc]init];
             cell=[tableView makeViewWithIdentifier:@"MainCell" owner:self];
             [cell.groupId setStringValue:groupsToPost[row][@"id"]];
             //    [cell.textField setStringValue:@"opk"];
             NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:groupsToPost[row][@"photo"]]];
             cell.photo.wantsLayer=YES;
             cell.photo.layer.cornerRadius=30/2;
             cell.photo.layer.masksToBounds=TRUE;
             [cell.photo setImage:image];
             return cell;
         }
     }
    else if ([tableView isEqual:listOfMessages]){
        if([messagesToPost count]>0){
            NSTableCellView *cell=[tableView makeViewWithIdentifier:@"MainCell" owner:self];
            [cell.textField setStringValue:messagesToPost[row][@"message"]];
            return cell;
        }
    }
    return nil;
}
-(NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if([attachmentsData count]>0){
        return [attachmentsData count];
    }
    return 0;
}

-(NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath{
    
    PostAttachmentsCustomItem *item1 = [[PostAttachmentsCustomItem alloc]init];
    item1 = [collectionView makeItemWithIdentifier:@"PostAttachmentsCustomItem" forIndexPath:indexPath];
    if([attachmentsData count]>0){
//        NSString *itt = [attachmentsData objectAtIndex:indexPath.item][@"cover"];
//        NSString *itt2 = attachmentsData[indexPath.item][@"title"];
        
//        item1.textLabel.stringValue=itt2;
        //    NSLog(@"%@", itt);
//        item1.titleItem.stringValue = itt2;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSImage *image = [[NSImage alloc]init];
            NSString *ph = attachmentsData[indexPath.item][@"data"][@"items"] ? attachmentsData[indexPath.item][@"data"][@"items"][@"photo"] : attachmentsData[indexPath.item][@"data"][@"photo"]?attachmentsData[indexPath.item][@"data"][@"photo"]:attachmentsData[indexPath.item][@"data"][@"cover"];
                image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:ph]];
            

            
                dispatch_async(dispatch_get_main_queue(), ^{
                    [item1.previewItem setImage:image];
                });
          
        });
        
    }
    return item1;
    
    
}
@end
