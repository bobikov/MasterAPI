//
//  SubscribersViewController.m
//  vkapp
//
//  Created by sim on 29.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "SubscribersViewController.h"
#import "FullUserInfoPopupViewController.h"
@interface SubscribersViewController ()<NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate>

@end

@implementation SubscribersViewController
@synthesize value, arrayController;
- (void)viewDidLoad {
    [super viewDidLoad];
    subscribersList.delegate = self;
    subscribersList.dataSource = self;
    searchBar.delegate=self;
    [[subscribersScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    subscribersData = [[NSMutableArray alloc]init];
     _app = [[appInfo alloc]init];
    offsetCounter = 0;
    foundData = [[NSMutableArray alloc]init];
    value=[[NSMutableArray alloc]init];
    selectedUsers = [[NSMutableArray alloc]init];
    _stringHighlighter = [[StringHighlighter alloc]init];
//    self.view.wantsLayer=YES;
//    [self.view.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VisitUserPageFromSubscribers:) name:@"VisitUserPageFromSubscribers" object:nil];
    
}
-(void)VisitUserPageFromSubscribers:(NSNotification*)notification{
    
        NSInteger row = [notification.userInfo[@"row"] intValue];
        NSLog(@"%@", subscribersData[row]);
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/id%@",subscribersData[row][@"id"]]]];
    
}
- (void)viewDidAppear{
    [self loadSubscribers:NO :NO];
    
}
- (IBAction)friendsListPopupSelect:(id)sender {
    
    
}
-(void)viewDidScroll:(NSNotification *)notification{
    if([notification.object isEqual:subscribersClipView]){
    NSInteger scrollOrigin = [[subscribersScrollView contentView]bounds].origin.y+NSMaxY([subscribersScrollView visibleRect]);
//    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
    NSInteger boundsHeight = subscribersList.bounds.size.height;
//    NSInteger frameHeight = subscribersList.frame.size.height;
    if (scrollOrigin == boundsHeight+2) {
        //Refresh here
        //         NSLog(@"The end of table");
        if([foundData count] <=0){
            [self loadSubscribers:NO :YES];
        }
    }
//        NSLog(@"%ld", scrollOrigin);
//        NSLog(@"%ld", boundsHeight);
    //    NSLog(@"%fld", frameHeight-300);
    //
    }
}
-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    [self loadSearchSubscribers];
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    subscribersData = subscribersDataCopy;
    [subscribersList reloadData];
}
-(void)loadSearchSubscribers{
    
    NSInteger counter=0;
    NSMutableArray *subscribersDataTemp=[[NSMutableArray alloc]init];
    subscribersDataCopy = [[NSMutableArray alloc]initWithArray:subscribersData];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
    [subscribersDataTemp removeAllObjects];
    for(NSDictionary *i in subscribersData){
        
        NSArray *found = [regex matchesInString:i[@"full_name"]  options:0 range:NSMakeRange(0, [i[@"full_name"] length])];
        if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
            counter++;
            [subscribersDataTemp addObject:i];
        }
        
    }
    //     NSLog(@"Start search %@", banlistDataTemp);
    if([subscribersDataTemp count]>0){
        subscribersData = subscribersDataTemp;
        [subscribersList reloadData];
    }
    
}
-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"subscribersMessageSeague"]){
        FriendsMessageSendViewController *controller = (FriendsMessageSendViewController *)segue.destinationController;
        NSInteger row = [subscribersList selectedRow];
        NSDictionary *receiverDataForMessage = subscribersData[row];
        NSLog(@"%@", receiverDataForMessage);
        controller.recivedDataForMessage=receiverDataForMessage;
    }
}
- (IBAction)selectAllAction:(id)sender {
    [subscribersList selectAll:self];
    
}
- (IBAction)showPopupProfileFullInfo:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Third" bundle:nil];
    FullUserInfoPopupViewController *popuper = [story instantiateControllerWithIdentifier:@"profilePopup"];
    NSPoint mouseLoc = [NSEvent mouseLocation];
    //    int x = mouseLoc.x;
    int y = mouseLoc.y;
    //    int scrollPosition = [[scrollView contentView] bounds].origin.y+120;
    
    NSView *parentCell = [sender superview];
    NSInteger row = [subscribersList rowForView:parentCell];
    CGRect rect=CGRectMake(0, y, 0, 0);
    popuper.receivedData = subscribersData[row];
//    NSLog(@"%@", subscribersData[row]);
    [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:subscribersList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadUserFullInfo" object:self userInfo:dataForUserInfo];

    
    
}
- (IBAction)addToFriendsActions:(id)sender {
    NSIndexSet *rows;
    rows=[subscribersList selectedRowIndexes];
    [selectedUsers removeAllObjects];
    void(^addToFriendsBlock)()=^void(){
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            [selectedUsers addObject:@{@"id":subscribersData[i][@"id"], @"index":[NSNumber numberWithInteger:i]}];
        }
        for(NSDictionary *i in selectedUsers){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/friends.add?user_id=%@&v=%@&access_token=%@", i[@"id"] ,_app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *addToBanResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
                NSLog(@"%@", addToBanResponse);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [subscribersList deselectRow:[i[@"index"] intValue]];
                });
                
            }]resume];
            sleep(1);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [subscribersData removeObjectsAtIndexes:rows];
//            arrayController.content = subscribersData;
//            [foundData removeAllObjects];
            [subscribersList reloadData];
        });
       
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        addToFriendsBlock();
    });

    
}
- (IBAction)addToBanAction:(id)sender {
    NSIndexSet *rows;
    rows=[subscribersList selectedRowIndexes];
    [selectedUsers removeAllObjects];
    
   void(^addToBanBlock)()=^void(){
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            [selectedUsers addObject:@{@"id":subscribersData[i][@"id"], @"index":[NSNumber numberWithInteger:i]}];
            
           
        }
       for(NSDictionary *i in selectedUsers){
           [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/account.banUser?user_id=%@&v=%@&access_token=%@", i[@"id"] ,_app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
               NSDictionary *addToBanResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
               NSLog(@"%@", addToBanResponse);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [subscribersList deselectRow:[i[@"index"] intValue]];
                 });
           }]resume];
           sleep(1);
           
       }
       dispatch_async(dispatch_get_main_queue(), ^{
           [subscribersData removeObjectsAtIndexes:rows];
//           arrayController.content = subscribersData;
           //            [foundData removeAllObjects];
           [subscribersList reloadData];
       });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        addToBanBlock();
    });
//    NSLog(@"%@", selectedUsers);
    
}

- (IBAction)leaveAction:(id)sender {
    
    
}
- (IBAction)womenFilterAction:(id)sender {
    [self loadSubscribers:NO :NO];
    
}
- (IBAction)menFilterAction:(id)sender {
    [self loadSubscribers:NO :NO];
}

- (IBAction)FriendsFilterOfflineAction:(id)sender {
    
    [self loadSubscribers:NO :NO];
    
}
- (IBAction)FriendsFilterOnlineAction:(id)sender {
    
    [self loadSubscribers:NO :NO];
}
- (IBAction)FriendsFilterActiveAction:(id)sender {
    if(subscribersFilterActive.state == 0){
        subscribersFilterOffline.state=1;
        subscribersFilterOnline.state=0;
    }
    else{
        subscribersFilterOnline.state=1;
    }
    [self loadSubscribers:NO :NO];
}
- (IBAction)goUpAction:(id)sender {
    [subscribersList scrollToBeginningOfDocument:self];
}
- (IBAction)goDownAction:(id)sender {
    [subscribersList scrollToEndOfDocument:self];
    
}


-(void)loadSubscribers:(BOOL)searchByName :(BOOL)makeOffset{
    __block NSDictionary *object;
    if(makeOffset){
        offsetLoadSubscribers=offsetLoadSubscribers+500;
    }else{
        [subscribersData removeAllObjects];
        offsetLoadSubscribers=0;
         offsetCounter=0;
    }
     [progressSpin startAnimation:self];
//    __block NSMutableArray *tempSubscribers = [[NSMutableArray alloc]init];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.getFollowers?user_id=%@&count=500&offset=%i&suggested=0&need_viewed=1&fields=city,domain,photo_100,photo_200,status,last_seen,bdate,online,country,sex,about,site,contacts,books,music,schools,education,quotes,relation&v=%@&access_token=%@", _app.person, offsetLoadSubscribers, _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *responseGetFollowers = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(error){
                NSLog(@"responseGetFollowers error:%@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressSpin stopAnimation:self];
                });
                return;
          
            }
            if([response isKindOfClass:[NSHTTPURLResponse class]]){
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                if(statusCode != 200){
                    NSLog(@"responseGetFollowers response error %lu", statusCode );
                    return;
                }
                else{
                    
                    
                    NSString *city;
                    NSString *status;
                    NSString *bdate;
                    NSString *online;
                    NSString *firstName;
                    NSString *lastName;
                    NSString *fullName;
                    NSString *countryName;
                    NSString *last_seen;
                    NSString *sex;
                    NSString *books;
                    NSString *site;
                    NSString *mobilePhone;
//                    NSString *phone;
                    NSString *photoBig;
                    NSString *photo;
                    NSString *about;
                    NSString *music;
                    NSString *schools;
                    NSString *education;
                    NSString *quotes;
                    NSString *relation;
                    NSString *relation_partner;
                    NSString *domain;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        subscribersTotalCount.title=[NSString stringWithFormat:@"%i",[responseGetFollowers[@"response"][@"count"] intValue]];
                        
                        
                        
                    });
                    for(NSDictionary *a in responseGetFollowers[@"response"][@"items"]){
                        firstName = a[@"first_name"];
                        lastName=a[@"last_name"];
                        fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                        city = a[@"city"] && a[@"city"][@"title"]!=nil ? a[@"city"][@"title"] : @"";
                        sex = a[@"sex"] && [a[@"sex"] intValue]==1? @"W" :[a[@"sex"] intValue]==2 ?  @"M" : [a[@"sex"] intValue]==0 ? @"n/a" : @"";
                        status = a[@"status"] && a[@"status"]!=nil ? a[@"status"] : @"";
                        music = a[@"music"] && a[@"music"]!=nil ? a[@"music"] : @"";
                        online = [NSString stringWithFormat:@"%@", a[@"online"]];
                        domain = a[@"domain"] && a[@"domain"]!=nil ? a[@"domain"] : @"";
                        if(a[@"bdate"] && a[@"bdate"] && a[@"bdate"]!=nil){
                            bdate = a[@"bdate"];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            NSString *templateLateTime2 = @"yyyy";
                            NSString *templateLateTime1 = @"d.M.yyyy";
                            //                            NSString *todayTemplate =@"d",
                            [formatter setLocale:[[NSLocale alloc ] initWithLocaleIdentifier:@"ru"]];
                            [formatter setDateFormat:templateLateTime1];
                            NSDate *date = [formatter dateFromString:bdate];
                            [formatter setDateFormat:templateLateTime2];
                            if(![bdate isEqual:@""]){
                                bdate = [NSString stringWithFormat:@"%d лет", 2016 - [[formatter stringFromDate:date] intValue]];
                            }
                            if([bdate isEqual:@"2016 лет" ]){
                                bdate=@"";
                            }
                        }
                        else{
                            bdate=@"";
                        }
                       
                        
                        if(a[@"last_seen"] && a[@"last_seen"]!=nil){
                            double timestamp = [a[@"last_seen"][@"time"] intValue];
                            NSDate *gotDate = [[NSDate alloc] initWithTimeIntervalSince1970: timestamp];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            NSString *templateLateTime= @"dd.MM.yy HH:mm";
                            //                            NSString *todayTemplate =@"d",
                            [formatter setLocale:[[NSLocale alloc ] initWithLocaleIdentifier:@"ru"]];
                            [formatter setDateFormat:templateLateTime];
                            last_seen = [NSString stringWithFormat:@"%@", [formatter stringFromDate:gotDate]];
                            
                        }
                        else{
                            last_seen = @"";
                        }
                        if([online intValue] == 1){
                            last_seen=@"";
                        }
                        countryName = a[@"country"] && a[@"country"]!=nil ? a[@"country"][@"title"] : @"";
                      
                        site = a[@"site"] && a[@"site"]!=nil ? a[@"site"] :  @"";
                        photoBig = a[@"photo_200"] ? a[@"photo_200"] : a[@"photo_100"];
                        photo = a[@"photo_100"];
                        mobilePhone = a[@"mobile_phone"] && a[@"mobile_phone"]!=nil ? a[@"mobile_phone"] : @"";
                        sex = a[@"sex"] && [a[@"sex"] intValue]==1 ? @"W" :[a[@"sex"] intValue]==2 ?  @"M" : [a[@"sex"] intValue]==0 ? @"n/a" : @"";
                        books = a[@"books"] && a[@"books"]!=nil ? a[@"books"] : @"";
                        about = a[@"about"] && a[@"about"]!=nil ? a[@"about"] : @"";
                        education = a[@"university_name"] && a[@"university_name"]!=nil ? a[@"university_name"] : @"";
                        schools = a[@"schools"] && a[@"schools"]!=nil &&  [a[@"schools"] count] > 0  ? a[@"schools"][0][@"name"] : @"";
                        quotes = a[@"quotes"] && a[@"quotes"]!=nil ? a[@"quotes"] : @"";
                        relation = a[@"relation"] && a[@"relation"]!=nil? a[@"relation"] : @"";
                        relation_partner = a[@"relation_partner"] && a[@"relation_partner"]!=nil ? a[@"relation_partner"] : @"";
//                        NSLog(@"%@", [a[@"schools"] count] > 0 ? a[@"schools"][0] : @"nnn");
                        object = @{@"id":a[@"id"], @"full_name":fullName, @"city":city, @"status":status, @"user_photo":photo,@"user_photo_big":photoBig, @"country":countryName, @"bdate":bdate, @"online":online, @"last_seen":last_seen, @"sex":sex, @"about":about, @"site":site, @"books":books, @"mobile":mobilePhone, @"music":music, @"schools":schools, @"university_name":education, @"quotes":quotes, @"relation":relation, @"relation_partner":relation_partner,@"domain":domain};
                        
                        if(subscribersFilterOnline.state==1 && subscribersFilterOffline.state ==1 && subscribersFilterActive.state == 1){
                            
                            
                            if(searchByName){
                                NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:searchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
                                fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                                NSArray *found = [regex matchesInString:fullName  options:0 range:NSMakeRange(0, [fullName length])];
                                
                                if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
                                    offsetCounter++;
                                    [subscribersData addObject:object];
                                }
                                
                            }
                            else{
                    
                                if (!a[@"deactivated"]){
                                    if(womenFilter.state==1 && menFilter.state==1){
                                        if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                            offsetCounter++;
                                            [subscribersData addObject:object];
                                        }
                                    }
                                    else if(womenFilter.state==1 && menFilter.state==0){
                                        if([a[@"sex"] intValue]==1){
                                            offsetCounter++;
                                            [subscribersData addObject:object];
                                        }
                                    }
                                    else if(womenFilter.state==0 && menFilter.state==1){
                                        if([a[@"sex"] intValue]==2){
                                            offsetCounter++;
                                            [subscribersData addObject:object];
                                        }
                                        
                                    }
                                    else if(womenFilter.state==0 && menFilter.state==0){
                                        if([a[@"sex"] intValue]==0){
                                            offsetCounter++;
                                            [subscribersData addObject:object];
                                        }
                                        
                                    }
                                }
                                
                            }
                        }
                        else if(subscribersFilterOnline.state==0 && subscribersFilterOffline.state ==1 && subscribersFilterActive.state == 1 ) {
                            
                        
                            if (![online  isEqual: @"1"]){
                                if(womenFilter.state==1 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==1 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==1){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==2){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                    
                                }
                                else if(womenFilter.state==0 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==0){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                    
                                }
                            }
                        }
                        else if(subscribersFilterOnline.state==1 && subscribersFilterOffline.state ==0 && subscribersFilterActive.state == 1) {
                            
                            if ([online  isEqual: @"1"]){
                                if(womenFilter.state==1 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==1 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==1){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==2){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                    
                                }
                                else if(womenFilter.state==0 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==0){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                    
                                }
                            }
                        }
                        else if(subscribersFilterOnline.state==0 && subscribersFilterOffline.state == 1 && subscribersFilterActive.state == 0) {
                            
                            if (a[@"deactivated"]){
                                if(womenFilter.state==1 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==1 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==1){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==2){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                    
                                }
                                else if(womenFilter.state==0 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==0){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                }
                            }
                        }
                        else if(subscribersFilterOnline.state==1 && subscribersFilterOffline.state == 1 && subscribersFilterActive.state == 0) {
                            
                            if (a[@"deactivated"] && ([online intValue]==1 || [online intValue]==0)){
                                if(womenFilter.state==1 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==1 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==1){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==2){
                                        offsetCounter++;
                                        [subscribersData addObject:object];
                                    }
                                    
                                }
                                else if(womenFilter.state==0 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==0){
                                        offsetCounter++;
                                       [subscribersData addObject:object];
                                    }
                                }
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [progressSpin stopAnimation:self];
                        if([subscribersData count]>0){
                            
                            [subscribersList reloadData];
                            //                        [FriendsData removeAllObjects];
                            //                        [ActionProgress1 stopAnimation:(id)self];
                            subscribersCountInline.title=[NSString stringWithFormat:@"%lu",offsetCounter];
                        }
                        //                        [progressSpin stopAnimation:self];
                        //                        NSLog(@"%@", FriendsData);
                    });
                    
                    
                }
            }
        }
    }] resume];
}

//-(void)tableViewSelectionDidChange:(NSNotification *)notification{
//    
//    
//}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if ([subscribersData count]>0){
        return [subscribersData count];
    }
    return 0;
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([subscribersData count]>0){
        SubscribersCustomCell *cell = [[SubscribersCustomCell alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.fullName.stringValue = subscribersData[row][@"full_name"];
        cell.city.stringValue = subscribersData[row][@"city"];
        cell.country.stringValue = subscribersData[row][@"country"];
        cell.bdate.stringValue = subscribersData[row][@"bdate"];
        cell.lastSeen.stringValue = subscribersData[row][@"last_seen"];
//        cell.status.stringValue = subscribersData[row][@"status"];
        [cell.status setAllowsEditingTextAttributes:YES];
        cell.status.attributedStringValue = [_stringHighlighter highlightStringWithURLs:subscribersData[row][@"status"] Emails:YES fontSize:12];
        [cell.status setFont:[NSFont fontWithName:@"Helvetica" size:12]];
        cell.sex.stringValue = subscribersData[row][@"sex"];
        cell.photo.wantsLayer=YES;
        cell.photo.layer.masksToBounds=YES;
        cell.photo.image.size = NSMakeSize(80, 80);
        cell.photo.layer.cornerRadius=80/2;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", subscribersData[row][@"user_photo"]]]];
            NSImageRep *rep = [[image representations] objectAtIndex:0];
            NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
            image.size=imageSize;
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.photo setImage:image];
            });
        });
        if([subscribersData[row][@"online"] intValue] == 1){
            [cell.online setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
//            cell.lastOnline.stringValue = @"";
        }
        else{
            [cell.online setImage:[NSImage imageNamed:NSImageNameStatusNone]];
//              cell.lastOnline.stringValue = subscribersData[row][@"last_seen"];
        }
 
        return cell;
    }

    return nil;
}

@end
