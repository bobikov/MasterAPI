//
//  DialogsViewController.m
//  vkapp
//
//  Created by sim on 25.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "DialogsViewController.h"
#import "SmilesViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface DialogsViewController ()<NSTableViewDataSource, NSTableViewDelegate>

@end

@implementation DialogsViewController
@synthesize dialogsListData;
- (void)viewDidLoad {
    [super viewDidLoad];
    dialogsList.delegate = self;
    dialogsList.dataSource = self;
    selectedDialog.delegate = self;
    selectedDialog.dataSource = self;
    _app = [[appInfo alloc]init];
    dialogsListData = [[NSMutableArray alloc]init];
    dialogsMessageData = [[NSMutableArray alloc]init];
    userMessageHistoryData = [[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(display:) name:@"reloadDialog" object:nil];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints"];
    [[dialogsListScrollView contentView] setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertSmile:) name:@"insertSmileDialogs" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ShowDialogsContextMenu:) name:@"ShowDialogsContextMenu" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userBanAndDeleteDialog:) name:@"userBanAndDeleteDialog" object:nil];
    [deleteDialogs setEnabled:NO];
//    self.view.wantsLayer=YES;
//    [self.view.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    countReload = 0;
    bodies = [[NSMutableArray alloc]init];
    fullNames = [[NSMutableArray alloc]init];
    profileImages = [[NSMutableArray alloc]init];
    userOnlineStatuses = [[NSMutableArray alloc]init];
    unreadStatuses = [[NSMutableArray alloc]init];
    userIdsForHistory = [[NSMutableArray alloc]init];
    tempIds = [[NSMutableArray alloc]init];
    fromIds = [[NSMutableArray alloc]init];
    dates = [[NSMutableArray alloc]init];
   

}
-(void)insertSmile:(NSNotification*)notification{
    textOfNewMessage.string=[NSString stringWithFormat:@"%@%@", textOfNewMessage.string, notification.userInfo[@"smile"]];
    
}
-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"SmilesViewSegue"]){
        SmilesViewController *contr = (SmilesViewController*)segue.destinationController;
        contr.source=@"dialogs";
    }
}
-(void)userBanAndDeleteDialog:(NSNotification*)notification{
    NSInteger row = [notification.userInfo[@"row"] intValue];
    NSLog(@"%@", dialogsListData[row]);
    [self addToBanSelectedUserInDialog:dialogsListData[row][@"user_id"] rowIndex:[notification.userInfo[@"row"] intValue]];
                     
}
-(void)ShowDialogsContextMenu:(NSNotification*)notification{
    NSInteger row = [notification.userInfo[@"row"] intValue];
    NSLog(@"%@", dialogsListData[row]);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/id%@",dialogsListData[row][@"user_id"]]]];
    
}
- (void)addToBanSelectedUserInDialog:(id)userId rowIndex:(int)rowIndex{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/account.banUser?user_id=%@&v=%@&access_token=%@", userId ,_app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *addToBanResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
        NSLog(@"%@", addToBanResponse);
        dispatch_async(dispatch_get_main_queue(), ^{
            [dialogsList deselectRow:rowIndex];
        });
        if(addToBanResponse[@"response"] ){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/messages.deleteDialog?user_id=%@&v=%@&access_token=%@", userId ,_app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *deleteDialogsResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
                NSLog(@"%@", deleteDialogsResponse);
                if([deleteDialogsResponse[@"response"] intValue] == 1){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self loadDialogs:NO :NO];
                    });
                   
                }
                
            }]resume];

        }
    }]resume];
}
- (void)viewDidAppear{
    
//    if([selectedDialog numberOfRows] > 0){
//        NSIndexSet *index=[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [userMessageHistoryData count])];
//        [selectedDialog removeRowsAtIndexes:index withAnimation:0];
//    }
    logoMessagesOfDialog.hidden=NO;
    selectedDialog.hidden = YES;
    textOfNewMessage.editable=NO;

    [sendMessageButton setEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadDialogs:NO :NO];
    });
   
//    [self setButtonStyle:sendMessageButton];
    
}
- (void)viewDidDisappear{
    if([selectedDialog numberOfRows]>0){
        [selectedDialog removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [selectedDialog numberOfRows])] withAnimation:NSTableViewAnimationEffectNone];
    }
  
}
- (void)viewDidScroll:(NSNotification *)notification{
    if([notification.object isEqual:dialogsListClipView]){
        NSInteger scrollOrigin = [[dialogsListScrollView contentView]bounds].origin.y+NSMaxY([dialogsListScrollView visibleRect]);
//        NSInteger numberRowHeights = [dialogsList numberOfRows] * [dialogsList rowHeight];
        NSInteger boundsHeight = dialogsList.bounds.size.height;
//        NSInteger frameHeight = dialogsList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            //Refresh here
            //         NSLog(@"The end of table");
//            if([foundData count] <=0){
                [self loadDialogs:NO :YES];
//            }
        }
        //        NSLog(@"%ld", scrollOrigin);
        //        NSLog(@"%ld", boundsHeight);
        //    NSLog(@"%fld", frameHeight-300);
        //
    }
}
- (void)setButtonStyle:(id)button{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    NSAttributedString *attrString = [[NSAttributedString alloc]initWithString:[button title] attributes:attrsDictionary];
    [button setAttributedTitle:attrString];
}
- (IBAction)deleteDialogsAction:(id)sender {
    
    NSIndexSet *rows;
    rows=[dialogsList selectedRowIndexes];
    __block NSInteger rowIndex=0;
    NSMutableArray *selectedDialogs=[[NSMutableArray alloc]init];
    void(^deleteDialogsBlock)()=^void(){
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            [selectedDialogs addObject:@{@"user_id":dialogsListData[i][@"user_id"], @"index": [NSNumber numberWithInteger:i]}];
  
        }
//        NSLog(@"%@", selectedDialogs);
        for(NSDictionary *i in selectedDialogs){
            NSLog(@"%@ %@", i[@"user_id"], i[@"index"]);
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/messages.deleteDialog?user_id=%@&v=%@&access_token=%@", i[@"user_id"] ,_app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *deleteDialogsResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
                NSLog(@"%@", deleteDialogsResponse);
                if([deleteDialogsResponse[@"response"] intValue] == 1){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        removeDialog=YES;
//                        [dialogsList removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:[i[@"index"] intValue]] withAnimation:NSTableViewAnimationEffectFade];
                        [dialogsList deselectRow:[i[@"index"] intValue]];
                        
                        removeDialog=NO;
                    });
//                    [dialogsListData removeObjectAtIndex:[i[@"index"] intValue]];
                }
            
            }]resume];
            sleep(1);
            rowIndex++;
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
//
//            [dialogsMessageData  removeObjectsAtIndexes:rows];
            [dialogsListData removeObjectsAtIndexes:rows];
//            [self loadDialogs:NO :NO];
//            [dialogsMessageData removeObjectsAtIndexes:rows];
//            [bodies removeObjectsAtIndexes:rows];
//            [fullNames removeObjectsAtIndexes:rows];
//            [profileImages removeObjectsAtIndexes:rows];
//            [userOnlineStatuses removeObjectsAtIndexes:rows];
//            [unreadStatuses removeObjectsAtIndexes:rows];
//            [userIdsForHistory removeObjectsAtIndexes:rows];
//              [tempIds removeObjectsAtIndexes:rows];
            [dialogsList removeRowsAtIndexes:rows withAnimation:NSTableViewAnimationEffectNone];
            [self loadDialogs:NO :NO];
//
        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        deleteDialogsBlock();
    });

}

- (void)display:(NSNotification *)notification{

    if([self.parentViewController.childViewControllers[0].title isEqual:@"Dialogs"]){
        
        if([userMessageHistoryData count]>0){
            NSLog(@"OKOOK");
            [self loadHistoryOfSelectedDialog:notification.userInfo[@"user_id"] fullReload:NO oneRowReload:YES message:notification.userInfo[@"message"]];
        }
        else{
//            [self loadHistoryOfSelectedDialog:notification.userInfo[@"user_id"] :YES :NO :nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self loadDialogs:NO :NO];
                
            });
//
//            [self loadHistoryOfSelectedDialog:notification.userInfo[@"user_id"] :YES :NO :nil];
        }
    }
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self loadDialogs:NO :NO];
//
//    });
}
- (IBAction)sendMessageAction:(id)sender {
    if(receiverOfNewMessage && ![textOfNewMessage.string isEqual: @""]){
        NSString *textOfMessage = [textOfNewMessage.string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/messages.send?user_id=%@&message=%@&random_id=%u&v=%@&access_token=%@", receiverOfNewMessage,  textOfMessage, 0+arc4random() % 100000, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSDictionary *dataResponseOfNewMessage = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            personFlag=YES;
//            if(dataResponseOfNewMessage[@"error"]){
//                NSLog(@"%@", dataResponseOfNewMessage[@"error"][@"error_msg"]);
//            }
//            else{
//                NSNotification *notification = [[NSNotification alloc]init];
//                if(!notification.userInfo[@"user_id"]){
////                    [self loadHistoryOfSelectedDialog:receiverOfNewMessage :NO :YES];
//                }
//            }
//        NSLog(@"%@", dataResponseOfNewMessage);
    }] resume];
    }
//    NSLog(@"%@", receiverOfNewMessage);
}

-(void)loadHistoryOfSelectedDialog:(id)user_id fullReload:(BOOL)fullReload oneRowReload:(BOOL)oneRowReload message:(id)message{
    [userMessageHistoryData removeAllObjects];
    receiverOfNewMessage = user_id;
    [fromIds removeAllObjects];
    [userMessageHistoryData removeAllObjects];
    [bodies removeAllObjects];
    [profileImages removeAllObjects];
    [fullNames removeAllObjects];
    [dates removeAllObjects];
//    __block NSMutableArray *fullNames = [[NSMutableArray alloc]init];
    
//    __block NSMutableArray *userOnlineStatuses = [[NSMutableArray alloc]init];
//    __block NSMutableArray *userIdsInDialog = [[NSMutableArray alloc]init];
//   
//    __block NSMutableDictionary *dataHistoryItems =[[NSMutableDictionary alloc]init];
//    __block NSMutableArray *finalDataHistoryInArray = [[NSMutableArray alloc]init];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/messages.getHistory?user_id=%@&rev=1&v=%@&count=59&access_token=%@", user_id, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *getCountDataResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSInteger count = [getCountDataResp[@"response"][@"count"] intValue];
            
            NSInteger offset;
            if(count>20){
                offset = count - 20;
            }
            else{
                offset=0;
            }
            
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/messages.getHistory?user_id=%@&rev=1&v=%@&count=20&offset=%lu&access_token=%@", user_id, _app.version, offset, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (data){
                    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if(error){
                        NSLog(@"dataTaskWithUrl error: %@", error);
                        return;
                    }
                    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                        
                        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                        
                        if (statusCode != 200) {
                            NSLog(@"dataTaskWithRequest HTTP status code: %lu", statusCode);
                            return;
                        }
                    }
                    
                    if(jsonData[@"error"]){
                        
                    }
                    else{
                        for(NSDictionary *i in jsonData[@"response"][@"items"]){
                            //            [bodies addObject:i[@"body"]]
                            
                            NSString *fromId = [NSString stringWithFormat:@"%@", i[@"from_id"]];
                            [fromIds addObject:fromId];
                            [bodies addObject:i[@"body"]];
                            NSDate *messageDateData = [[NSDate alloc]initWithTimeIntervalSince1970:[i[@"date"] intValue]];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                            //                    NSString *templateLateTime= @"d.MM.yy HH:mm";
                            [formatter setLocale:[[NSLocale alloc ] initWithLocaleIdentifier:@"ru"]];
                            [formatter setDateFormat:@"dd.MM.yyyy HH:mm"];
                            messageDate = [ formatter stringFromDate:messageDateData];
                            [dates addObject:messageDate];
                        }
                    }
                    
                    if([bodies count]>0){
                        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@,%@&fields=photo_50,online&v=%@&access_token=%@", _app.person, user_id, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                            if(data){
                                if(error){
                                    NSLog(@"dataTaskWithRequest error: %@", error);
                                    return;
                                }
                                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                    
                                    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                                    
                                    if (statusCode != 200) {
                                        NSLog(@"dataTaskWithRequest HTTP status code: %lu", statusCode);
                                        return;
                                    }
                                }
                                
                                NSDictionary *jsonData2 = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                if(jsonData2[@"response"]){
                                    NSString *fn;
                                    NSString *ln;
                                    NSString *me;
                                    NSString *user;
                                    NSString *fullName;
                                    
                                    for (NSDictionary *d in jsonData2[@"response"]){
                                        fn = d[@"first_name"];
                                        ln =d[@"last_name"];
                                        fullName = [NSString stringWithFormat:@"%@ %@", fn, ln];
                                        if([d[@"id"] isEqual:_app.person]){
                                            me = fullName;
                                            [fullNames addObject:me];
                                            [profileImages addObject:[NSString stringWithFormat:@"%@",d[@"photo_50"]]];
                                        }
                                        else{
                                            receiverOfNewMessage=d[@"id"];
                                            user = fullName;
                                            [fullNames addObject:user];
                                            [profileImages addObject:[NSString stringWithFormat:@"%@",d[@"photo_50"]]];
                                        }
                                    }
                                    
                                    if([bodies count]>0 && [profileImages count]>0 && [fullNames count]>0){
                                        
                                        for(int i = 0; i<[fromIds count];i++){
                                            if(![fromIds[i] isEqual: _app.person]){
                                                [userMessageHistoryData addObject:@{@"from_name":fullNames[1], @"body":bodies[i], @"photo":profileImages[1], @"date": dates[i]}];
                                            }
                                            else{
                                                [userMessageHistoryData addObject:@{@"from_name":fullNames[0], @"body":bodies[i], @"photo":profileImages[0], @"date":dates[i]}];
                                            }
                                        }
                                        NSLog(@"%li", [userMessageHistoryData count]);
                                        NSLog(@"%li", [bodies count]);
                                        NSLog(@"%li", [fromIds count]);
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if ([userMessageHistoryData count]==[bodies count]){
                                                
                                                
                                                
                                                if(oneRowReload){
                                                    if([selectedDialog numberOfRows]>0 && [selectedDialog numberOfRows]>=20){
                                                        [selectedDialog removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationEffectFade];
                                                        [selectedDialog reloadData];
                                                    }
                                            
                                                    if([selectedDialog numberOfRows]>0){
                                                        [selectedDialog insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[selectedDialog numberOfRows]] withAnimation:NSTableViewAnimationEffectFade];
                                                        if(personFlag){
                                                            
                                                            [userMessageHistoryData addObject:@{@"from_name":fullNames[0], @"body":message, @"photo":profileImages[0], @"date":messageDate}];
                                                            personFlag=NO;
                                                            
                                                            
                                                        }
                                                        else{
                                                            [userMessageHistoryData addObject:@{@"from_name":fullNames[1], @"body":message, @"photo":profileImages[1], @"date":messageDate}];
//                                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                                                [self loadDialogs:NO :NO];
//                                                                
//                                                            });
                                                        }
                                                    }
                                                    else{
//                                                        [selectedDialog insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[userMessageHistoryData count]] withAnimation:NSTableViewAnimationEffectNone];
//                                                        [selectedDialog reloadData];
                                                    }
                                                   
                                                    
                                                    
                                                }
                                                else{
                                                    [selectedDialog reloadData];
                                                }
                                                //                            if ([selectedDialog numberOfRows] > 0)
                                                [selectedDialog scrollRowToVisible:[selectedDialog numberOfRows] - 1];
                                            }
                                            
                                        });
                                    }
                                }
                            }
                        }] resume];
                    }
                }
                
            }] resume];
        }
    }]resume];
   }

-(void)loadDialogs:(BOOL)searchByName :(BOOL)makeOffset{
    [progressSpin startAnimation:self];
    if(makeOffset){
        [tempIds removeAllObjects];
        [dialogsMessageData removeAllObjects];
//        [unreadStatuses removeAllObjects];
//        [userIdsForHistory removeAllObjects];
        loadDialogsOffset=loadDialogsOffset+30;
  
    }else{
        [dialogsListData removeAllObjects];
        [dialogsMessageData removeAllObjects];
        loadDialogsOffset=0;
        offsetCounter=0;
        [bodies removeAllObjects];
        [fullNames removeAllObjects];
        [profileImages removeAllObjects];
        [userOnlineStatuses removeAllObjects];
        [unreadStatuses removeAllObjects];
        [userIdsForHistory removeAllObjects];
       
       [tempIds removeAllObjects];
    }
    
//    [dialogsListData removeAllObjects];
//
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/messages.getDialogs?count=30&v=%@&access_token=%@&offset=%lu", _app.version, _app.token, loadDialogsOffset]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            if(error){
                NSLog(@"GetDialog error %@", error);
                return;
            }
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                
                if (statusCode != 200) {
                    NSLog(@"GetDialogs error HTTP status code: %lu", statusCode);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [progressSpin stopAnimation:self];
                    });
                    return;
                }
            }
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //        NSLog(@"%@", jsonData[@"resume"]);
            NSString *body;
            NSString *uid;
            if(jsonData[@"error"]){
                NSLog(@"Error load dialogs");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressSpin stopAnimation:self];
                });
            }
           
            else{
                countTotalDialogs.title = [NSString stringWithFormat:@"%@", jsonData[@"response"][@"count"]];
                countUnreadDialogs.title = [NSString stringWithFormat:@"%@", jsonData[@"response"][@"unread_dialogs"]];
                for (NSDictionary *i in jsonData[@"response"][@"items"]){
                    if(i[@"message"][@"body"]!=nil){
                        body = i[@"message"][@"body"];
//                        offsetCounter++;
                    }
                    uid = [NSString stringWithFormat:@"%@", i[@"message"][@"user_id"]];
                    [dialogsMessageData addObject:@{@"uid":uid, @"body":body}];
                    [bodies addObject:body];
                    [unreadStatuses addObject:[NSString stringWithFormat:@"%@", i[@"unread"]]];
                    [userIdsForHistory addObject:uid];
                }
                if([bodies count]>0){
                  
                    for (NSDictionary *a in dialogsMessageData){
                        [tempIds addObject:a[@"uid"]];
                    }
                    
                    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@&fields=photo_50,online&v=%@&access_token=%@", [tempIds componentsJoinedByString:@","], _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if(data){
                            NSDictionary *jsonData2 = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            if(jsonData2[@"error"]){
                                NSLog(@"%@", jsonData2[@"error"][@"error_msg"]);
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [progressSpin stopAnimation:self];
                                });
                            }
                            else{
                                if([jsonData2[@"response"] count]>0){
                                    for (NSDictionary *d in jsonData2[@"response"]){
                                        NSString *fn = d[@"first_name"];
                                        NSString *ln =d[@"last_name"];
                                        NSString *onlineStatus = [NSString stringWithFormat:@"%@", d[@"online"]];
                                        [fullNames addObject:[NSString stringWithFormat:@"%@ %@", fn, ln]];
                                        [profileImages addObject:[NSString stringWithFormat:@"%@",d[@"photo_50"]]];
                                        [userOnlineStatuses addObject:onlineStatus];
                                        
                                    }
                                    for(NSInteger i =  loadDialogsOffset; i < [bodies count]; i++){
                                        
                                        [dialogsListData addObject:@{@"body":bodies[i], @"full_name":fullNames[i], @"img":profileImages[i], @"online":userOnlineStatuses[i], @"unread":unreadStatuses[i], @"user_id":userIdsForHistory[i]}];
                                        offsetCounter++;
                                    }
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [progressSpin stopAnimation:self];
                                    });
                                    if ([dialogsListData count]==[bodies count]){
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            countLoadedDialogs.title = [NSString stringWithFormat:@"%lu", offsetCounter];
                                            [dialogsList reloadData];
                                            
                                        });
                                    }
                                }
                            }
                          
                        }else{
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [progressSpin stopAnimation:self];
                            });
                        }
                    }]resume];
                }
            }
        }
        }] resume];
//      usleep(600000);
    NSLog(@"%lu, %lu", [bodies count], [dialogsListData count]);
    }
- (IBAction)removeOneDialog:(id)sender {
    NSView *view = [sender superview];
    NSInteger row = [dialogsList rowForView:view];
    NSLog(@"%@", dialogsListData[row]);

    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/messages.deleteDialog?user_id=%@&access_token=%@&v=%@", dialogsListData[row][@"user_id"], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *deleteDialogResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", deleteDialogResp);
        if(deleteDialogResp[@"response"]){
            dispatch_async(dispatch_get_main_queue(), ^{
                [userMessageHistoryData removeAllObjects];
                [dialogsListData removeObjectAtIndex:row];
                [dialogsList removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationSlideUp];
                [dialogsList reloadData];
            });
        }
    }]resume];
    
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row;
    NSString *item;
    if ([notification.object isEqual:dialogsList]){
        [deleteDialogs setEnabled:YES];
        row = [dialogsList selectedRow];
        if(!removeDialog){
            item = [NSString stringWithFormat:@"%@", dialogsListData[row][@"user_id"]];
            if (item){
                [self loadHistoryOfSelectedDialog:item fullReload:YES oneRowReload:NO message:nil];
               
                logoMessagesOfDialog.hidden=YES;
                selectedDialog.hidden = NO;
                textOfNewMessage.editable=YES;
                [sendMessageButton setEnabled:YES];
            }
            NSLog(@"%@", item);
        }
    }
    else if([notification.object isEqual:selectedDialog]){
        row = [selectedDialog selectedRow];
    }
    
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
  
   
    if([tableView isEqual:dialogsList]){
        if([dialogsListData count]>0){
            return [dialogsListData count];
        }
    }
    else if([tableView isEqual:selectedDialog]){
         countReload++;
        if([userMessageHistoryData count]>0){
            return [userMessageHistoryData count];
        }
    }
    return 0;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
//    CGFloat heightOfRow;
    if([tableView isEqual:selectedDialog]){
//        CGFloat heightOfRow = 100;
        SelectedDialogCustomCellView *cell = [[SelectedDialogCustomCellView alloc]init];

         cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        NSTableColumn *tableColumn = [selectedDialog tableColumnWithIdentifier:@"MainCell"];
        if (tableColumn) {
//             SelectedDialogCustomCellView *cell = [[SelectedDialogCustomCellView alloc]init];
            NSFont *font = [NSFont fontWithName:@"Helvetica" size:12.0];
//            NSFont  *font =  [NSFont systemFontOfSize:12 weight:NSFontWeightRegular];
            NSDictionary *attrsDictionary =
            [NSDictionary dictionaryWithObject:font
                                        forKey:NSFontAttributeName];
            NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:userMessageHistoryData[row][@"body"]
attributes:attrsDictionary];
            
            NSRect frame = NSMakeRect(0, 0,355, MAXFLOAT);
            NSTextView *tv = [[NSTextView alloc] initWithFrame:frame];
           
            
            [[tv textStorage] setAttributedString:attrString];
            
//            [tv setHorizontallyResizable:NO];
            [tv sizeToFit];
           
            
            [cell setNeedsUpdateConstraints:YES];
            [cell updateConstraints];
            [cell setNeedsLayout:YES];
            double height;
//            if(tv.frame.size.height<=30){
//                height = 50;
//            }else{
                height = tv.frame.size.height+42;
//            }
            return height;

        }
        
    }
    return 60;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([tableView isEqual:dialogsList]){
        if([dialogsListData count]>0){
            DialogsListCustomCellView *cell = [[DialogsListCustomCellView alloc]init];
            cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
            [cell.previewText setStringValue:dialogsListData[row][@"body"]];
            [cell.userFullName setStringValue:[NSString stringWithFormat:@"%@", dialogsListData[row][@"full_name"]]];
         
            NSSize imSize=NSMakeSize(45, 45);
           
            cell.profileImage.wantsLayer=YES;
            cell.profileImage.layer.cornerRadius=22.5f;
            cell.profileImage.layer.masksToBounds=TRUE;
            
            [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", dialogsListData[row][@"img"]]] placeholderImage:nil options:SDWebImageRefreshCached completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                    image.size=imSize;
                    [cell.profileImage setImage:image];
            }];
      
                                                                          
            if([dialogsListData[row][@"online"] isEqual:@"1"]){
                [cell.userOnlineImage setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
            }
            
            else{
                [cell.userOnlineImage setImage:[NSImage imageNamed:NSImageNameStatusNone]];
                cell.userOnlineImage.hidden = YES;
            }
            if ([dialogsListData[row][@"unread"] intValue] >0){
                cell.unreadStatus.hidden = NO;
                cell.unreadStatus.wantsLayer=YES;
                cell.unreadStatus.layer.cornerRadius=12.5f;
                cell.unreadStatus.layer.masksToBounds=TRUE;
                cell.unreadStatus.stringValue=[NSString stringWithFormat:@"%@", dialogsListData[row][@"unread"] ];
            }
            else{
                cell.unreadStatus.hidden = YES;
            }
            return cell;
        }
     }
    else if([tableView isEqual:selectedDialog]){
        if([userMessageHistoryData count]>0){
                selectedDialog.translatesAutoresizingMaskIntoConstraints=YES;
            SelectedDialogCustomCellView *cell = [[SelectedDialogCustomCellView alloc]init];
            cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
//            [cell setAutoresizesSubviews:YES];
//            [cell setAutoresizingMask:NSViewHeightSizable];
            cell.userFullName.stringValue = userMessageHistoryData[row][@"from_name"];
//             [cell.textMessage sizeToFit];
//            [cell setRowSizeStyle:NSTableViewRowSizeStyleLarge];
//            [cell.textMessage setAutoresizingMask:NSViewHeightSizable];
//            cell.textMessage.stringValue = userMessageHistoryData[row][@"body"];
            
            
            [cell.textMessage setAllowsEditingTextAttributes:YES];
           
            cell.textMessage.attributedStringValue = [self getAttributedStringWithURLExternSites:userMessageHistoryData[row][@"body"]];
            [cell.textMessage setFont:[NSFont fontWithName:@"Helvetica" size:12]];
            cell.profileImage.wantsLayer=YES;
            cell.profileImage.layer.cornerRadius=20;
            cell.profileImage.layer.masksToBounds=TRUE;
            cell.dateOfMessage.stringValue = userMessageHistoryData[row][@"date"];
            
            [cell.profileImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", userMessageHistoryData[row][@"photo"]]]  placeholderImage:nil options:SDWebImageRefreshCached completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                NSSize imSize=NSMakeSize(40, 40);
                image.size=imSize;
                [cell.profileImage setImage:image];
            
            }];
        
            return cell;
        
        }
    }
    return nil;
}
-(id)getAttributedStringWithURLExternSites:(NSString*)fullString{
   
    NSMutableAttributedString *string;
    string = [[NSMutableAttributedString alloc]initWithString:fullString];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?i)\\b((?:https?|ftp:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[\\w0-9.\\-]+[.][\\w]{2,4}/)(?:[^|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s()<>]+|\\(([^|\\s()<>]+|(\\([^|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s()<>]+\\)))*\\))+(?:\\(([^|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s()<>]+|(\\([^|\\s()<>]+\\)))*\\)|[^|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))" options:NSRegularExpressionCaseInsensitive error:&error];
    //    NSUInteger numberOfMatches = [regex numberOfMatchesInString:fullString options:0 range:NSMakeRange(0, [_receivedData[@"site"] length])];
    NSArray *matches = [regex matchesInString:fullString options:0 range:NSMakeRange(0, [fullString length])];
    //        NSLog(@"%@", matches);
    //        NSLog(@"Found %li",numberOfMatches);
    for (NSTextCheckingResult *match in matches){
        //            NSRange matchRange = match.range;
        
        //        NSLog(@"match: %@", [fullString substringWithRange:range]);
        
        NSRange foundRange = [string.mutableString rangeOfString:[fullString substringWithRange:match.range]  options:NSCaseInsensitiveSearch];
        if (foundRange.location != NSNotFound) {
            //                       NSLog(@"range found");
            [string addAttribute:NSLinkAttributeName value:[[NSURL URLWithString:[fullString substringWithRange:match.range]]absoluteString] range:foundRange];
            [string addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:foundRange];
            [string addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor]  range:foundRange];
            
            
        }
        
    }
    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"(?i)(?<!(//|\\w|(www\\.)|@))(?:[a-z0-9-_\\.])+\\.(?:ru|com|net|info|tv|uk|de|ua)/?(?![^\\w/|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s()<>])" options:NSRegularExpressionCaseInsensitive error:&error];
    //    NSUInteger numberOfMatches = [regex numberOfMatchesInString:fullString options:0 range:NSMakeRange(0, [_receivedData[@"site"] length])];
    NSArray *matches2 = [regex2 matchesInString:fullString options:0 range:NSMakeRange(0, [fullString length])];
    //        NSLog(@"%@", matches);
    //        NSLog(@"Found %li",numberOfMatches);
    for (NSTextCheckingResult *match in matches2){
        //            NSRange matchRange = match.range;
        
        //        NSLog(@"match: %@", [fullString substringWithRange:range]);
        
        NSRange foundRange = [string.mutableString rangeOfString:[fullString substringWithRange:match.range]  options:NSCaseInsensitiveSearch];
        if (foundRange.location != NSNotFound) {
            //                       NSLog(@"range found");
            [string addAttribute:NSLinkAttributeName value:[[NSURL URLWithString:[fullString substringWithRange:match.range]]absoluteString] range:foundRange];
            [string addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:foundRange];
            [string addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor]  range:foundRange];
            
            
        }
        
    }
    NSRegularExpression *regex3 = [NSRegularExpression regularExpressionWithPattern:@"[\\.a-zA-Z0-9_-]*@[a-z0-9-_]+\\.\\w{2,4}" options:NSRegularExpressionCaseInsensitive error:&error];
    //    NSUInteger numberOfMatches = [regex numberOfMatchesInString:fullString options:0 range:NSMakeRange(0, [_receivedData[@"site"] length])];
    NSArray *matches3 = [regex3 matchesInString:fullString options:0 range:NSMakeRange(0, [fullString length])];
    //        NSLog(@"%@", matches);
    //        NSLog(@"Found %li",numberOfMatches);
    for (NSTextCheckingResult *match in matches3){
        //            NSRange matchRange = match.range;
        
        //        NSLog(@"match: %@", [fullString substringWithRange:range]);
        
        NSRange foundRange = [string.mutableString rangeOfString:[fullString substringWithRange:match.range]  options:NSCaseInsensitiveSearch];
        if (foundRange.location != NSNotFound) {
            //                       NSLog(@"range found");
            [string addAttribute:NSLinkAttributeName value:[[NSURL URLWithString:[fullString substringWithRange:match.range]]absoluteString] range:foundRange];
            [string addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:foundRange];
            [string addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor]  range:foundRange];
            
            
        }
        
    }
     [string addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:12] range:NSMakeRange(0, [string length])];
    return string;
    
    
}
@end
