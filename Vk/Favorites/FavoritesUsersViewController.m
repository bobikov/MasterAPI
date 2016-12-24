//
//  FavoritesUsersViewController.m
//  vkapp
//
//  Created by sim on 24.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "FavoritesUsersViewController.h"
#import "FullUserInfoPopupViewController.h"
#import "FriendsMessageSendViewController.h"
#import "FavesUsersCustomCell.h"
#import "FriendsStatController.h"
@interface FavoritesUsersViewController ()<NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate>

@end

@implementation FavoritesUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    favesUsersList.delegate=self;
    favesUsersList.dataSource=self;
    searchBar.delegate=self;
    favesUsersData = [[NSMutableArray alloc]init];
    favesUsersDataCopy = [[NSMutableArray alloc]init];
    selectedUsers = [[NSMutableArray alloc]init];
    favesUsersTemp = [[NSMutableArray alloc]init];
    _app = [[appInfo alloc]init];
      [self loadFavesUsers:NO :NO];
    [[favesScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(VisitUserPageFromFavoriteUsers:) name:@"VisitUserPageFromFavoriteUsers" object:nil];
    offsetLoadFaveUsers=0;
}
-(void)VisitUserPageFromFavoriteUsers:(NSNotification *)notification{
    NSInteger row = [notification.userInfo[@"row"] intValue];
    NSLog(@"%@", favesUsersData[row]);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/id%@", favesUsersData[row][@"id"]]]];
}
-(void)viewDidAppear{
   
    
}
-(void)viewDidScroll:(NSNotification*)notification{
    if([notification.object isEqual:favesClipView]){
        NSInteger scrollOrigin = [[favesScrollView contentView]bounds].origin.y+NSMaxY([favesScrollView visibleRect]);
        //    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
        NSInteger boundsHeight = favesUsersList.bounds.size.height;
        //    NSInteger frameHeight = subscribersList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            //Refresh here
            //         NSLog(@"The end of table");
//            if([foundData count] <=0){
                [self loadFavesUsers:NO :YES];
//            }
        }
        //        NSLog(@"%ld", scrollOrigin);
        //        NSLog(@"%ld", boundsHeight);
        //    NSLog(@"%fld", frameHeight-300);
        //
    }

}
- (IBAction)showFavesUsersStatBut:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
    FriendsStatController *controller = [story instantiateControllerWithIdentifier:@"FriendsStatController"];
    controller.receivedData = @{@"data":favesUsersData};
    [self presentViewController:controller asPopoverRelativeToRect:showFavesUsersStatBut.frame ofView:self.view.subviews[0] preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
}
-(void)loadFavesUsersSearchList{
    
    NSInteger counter=0;
    NSMutableArray *favesUsersDataTemp=[[NSMutableArray alloc]init];
    favesUsersDataCopy = [[NSMutableArray alloc]initWithArray:favesUsersData];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
    [favesUsersDataTemp removeAllObjects];
    for(NSDictionary *i in favesUsersData){
        
        NSArray *found = [regex matchesInString:i[@"full_name"]  options:0 range:NSMakeRange(0, [i[@"full_name"] length])];
        if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
            counter++;
            [favesUsersDataTemp addObject:i];
        }
        
    }
    //     NSLog(@"Start search %@", banlistDataTemp);
    if([favesUsersDataTemp count]>0){
        favesUsersData = favesUsersDataTemp;
        [favesUsersList reloadData];
    }
    
}
- (IBAction)deleteUsersFromFavesAction:(id)sender {
    
    NSIndexSet *rows;
    rows=[favesUsersList selectedRowIndexes];
    [selectedUsers removeAllObjects];
    void(^deleteFromFriendsBlock)()=^void(){
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            [selectedUsers addObject:@{@"id":favesUsersData[i][@"id"], @"index":[NSNumber numberWithInteger:i]}];
            
            
        }
        for(NSDictionary *i in selectedUsers){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/fave.removeUser?user_id=%@&v=%@&access_token=%@", i[@"id"] ,_app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *deleteUsersFromFavesResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
                NSLog(@"%@", deleteUsersFromFavesResponse);
            }]resume];
            dispatch_async(dispatch_get_main_queue(), ^{
                [favesUsersList deselectRow:[i[@"index"] intValue]];
            });
            sleep(1);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [favesUsersData removeObjectsAtIndexes:rows];
            [favesUsersList reloadData];
            
            
        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        deleteFromFriendsBlock();
    });
    
}
- (IBAction)addToBlacklistAction:(id)sender {
    
    NSIndexSet *rows;
    rows=[favesUsersList selectedRowIndexes];
    [selectedUsers removeAllObjects];
    void(^addToBanBlock)()=^void(){
       
        for(NSDictionary *i in [favesUsersData objectsAtIndexes:rows]){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/account.banUser?user_id=%@&v=%@&access_token=%@", i[@"id"] ,_app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *addToBanResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
                NSLog(@"%@", addToBanResponse);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [favesUsersList deselectRow:[favesUsersData indexOfObject:i]];
                    [favesUsersList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[favesUsersData indexOfObject:i]] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
                });
            }]resume];
            sleep(1);
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
//            [favesUsersData removeObjectsAtIndexes:rows];
//            [favesUsersList reloadData];
            
            
        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        addToBanBlock();
    });
    
}
- (IBAction)selectAllAction:(id)sender {
    
    [favesUsersList selectAll:self];
}
-(void)setButtonStyle:(id)button{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    NSAttributedString *attrString = [[NSAttributedString alloc]initWithString:[button title] attributes:attrsDictionary];
    [button setAttributedTitle:attrString];
}
- (IBAction)showFullInfo:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Third" bundle:nil];
    FullUserInfoPopupViewController *popuper = [story instantiateControllerWithIdentifier:@"profilePopup"];
    NSPoint mouseLoc = [NSEvent mouseLocation];
    //    int x = mouseLoc.x;
    int y = mouseLoc.y;
    //    int scrollPosition = [[scrollView contentView] bounds].origin.y+120;
    
    NSView *parentCell = [sender superview];
    NSInteger row = [favesUsersList rowForView:parentCell];
    CGRect rect=CGRectMake(0, y, 0, 0);
    popuper.receivedData = favesUsersData[row];
    
    [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:favesUsersList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadUserFullInfo" object:self userInfo:dataForUserInfo];
}
- (IBAction)sendMessage:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    FriendsMessageSendViewController *controller = [story instantiateControllerWithIdentifier:@"MessageController"];
    controller.recivedDataForMessage=receiverDataForMessage;
    [self presentViewControllerAsSheet:controller];
}


- (IBAction)filterWomenAction:(id)sender {
    [self loadFavesUsers:NO :NO];
    
}
- (IBAction)filterMenAction:(id)sender {
     [self loadFavesUsers:NO :NO];
    
}

- (IBAction)filterOfflineAction:(id)sender {
    
     [self loadFavesUsers:NO :NO];
    
}
- (IBAction)filterOnlineAction:(id)sender {
    
     [self loadFavesUsers:NO :NO];
}
- (IBAction)FavesUsersFilterActiveAction:(id)sender {
    NSInteger counter=0;
    NSMutableArray *favesUsersDataTemp=[[NSMutableArray alloc]init];
    favesUsersDataCopy = [[NSMutableArray alloc]initWithArray:favesUsersData];
    [favesUsersDataTemp removeAllObjects];
    if(filterActive.state == 0){
        filterOffline.state=1;
        filterOnline.state=0;
        
        for(NSDictionary *i in favesUsersData){
            if(![i[@"deactivated"] isEqual:@""]){
                counter++;
                [favesUsersDataTemp addObject:i];
            }
            
        }
        //     NSLog(@"Start search %@", banlistDataTemp);
        if([favesUsersDataTemp count]>0){
            favesUsersData = favesUsersDataTemp;
            [favesUsersList reloadData];
        }
    }else{
        favesUsersData = favesUsersDataCopy;
        [favesUsersList reloadData];
    }

}
-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    [self loadFavesUsersSearchList];
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    
    favesUsersData = favesUsersDataCopy;
    [favesUsersList reloadData];
}

-(void)cleanTable{
    NSIndexSet *index=[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [favesUsersData count])];
    
    [favesUsersList removeRowsAtIndexes:index withAnimation:0];
    //    [favesUsersData removeAllObjects];
    //    if([favesUsersData count]==0){
    //        [favesUsersData removeAllObjects];
    //        [favesUsersList reloadData];
    //        [favesUsersList reloadData];
    ////        sleep(2);
    //          [self loadFavesUsers:NO];
    //    }
    
    
}

-(void)loadFavesUsers:(BOOL)searchByName :(BOOL)makeOffset{
     __block NSDictionary *object;
    __block void (^loadFavesBlock)(BOOL);
    
    loadFavesBlock = ^void(BOOL offset){
        [progressSpin startAnimation:self];
        if(offset){
            offsetLoadFaveUsers=offsetLoadFaveUsers+50;
        }else{
            [favesUsersData removeAllObjects];
            offsetLoadFaveUsers=0;
            offsetCounter=0;
        }
        
        
        __block NSInteger totalCount;
        __block NSInteger startInsertRowIndex = [favesUsersData count];
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/fave.getUsers?count=50&offset=%li&v=%@&access_token=%@", offsetLoadFaveUsers, _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *getFavesUsersResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if(getFavesUsersResponse[@"error"]){
                    NSLog(@"%@", getFavesUsersResponse[@"error"]);
                }else{
                    totalCount = [getFavesUsersResponse[@"response"][@"count"] intValue];
                    [favesUsersTemp removeAllObjects];
                    for(NSDictionary *i in getFavesUsersResponse[@"response"][@"items"]){
                        [favesUsersTemp addObject:i[@"id"]];
                    }
                    //           NSLog(@"%@",favesUsersTemp);
                    
                    [[_app.session dataTaskWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@&fields=photo_100,photo_200,photo_200_orig,country,city,online,last_seen,status,bdate,books,about,sex,site,contacts,verified,music,schools,education,quotes,blacklisted,domain,blacklisted_by_me,relation&access_token=%@&v=%@" , [favesUsersTemp componentsJoinedByString:@","],  _app.token, _app.version]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if(data){
                            if (error){
                                NSLog(@"Check your connection");
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    
                                    [progressSpin stopAnimation:self];
                                    
                                });
                                return;
                            }
                            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                
                                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                                
                                if (statusCode != 200) {
                                    NSLog(@"dataTask HTTP status code: %lu", statusCode);
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        
                                        [progressSpin stopAnimation:self];
                                        
                                    });
                                    return;
                                }
                                else{
                                }
                            }
                            
                            NSDictionary *getUsersResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            //                   NSLog(@"%@", getUsersResponse);
                            if (getUsersResponse[@"error"]){
                                NSLog(@"%@:%@", getUsersResponse[@"error"][@"error_code"], getUsersResponse[@"error"][@"error_msg"]);
                            }
                            else{
                                
                                NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:searchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
                                
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
                                //                       NSString *phone;
                                NSString *photoBig;
                                NSString *photo;
                                NSString *about;
                                NSString *music;
                                NSString *education;
                                NSString *schools;
                                NSString *quotes;
                                NSString *deactivated;
                                NSString *relation;
                                NSString *domain;
                                int blacklisted;
                                int blacklisted_by_me;
                                if([getUsersResponse[@"response"] count]>0){
                                    for (NSDictionary *a in getUsersResponse[@"response"]){
                                        fullName = [NSString stringWithFormat:@"%@ %@", a[@"first_name"], a[@"last_name"]];
                                        firstName = a[@"first_name"];
                                        lastName = a[@"last_name"];
                                        online = [NSString stringWithFormat:@"%@", a[@"online"]];
                                        city = a[@"city"] && a[@"city"][@"title"]!=nil ? a[@"city"][@"title"] : @"";
                                        status = a[@"status"] && a[@"status"]!=nil ? a[@"status"] : @"";
                                        music = a[@"music"] && a[@"music"]!=nil ? a[@"music"] : @"";
                                        domain = a[@"domain"] && a[@"domain"]!=nil ? a[@"domain"] : @"";
                                        deactivated = a[@"deactivated"] && a[@"deactivated"]!=nil ? a[@"deactivated"] : @"";
                                        blacklisted = a[@"blacklisted"] && a[@"blacklisted"]!=nil?  [a[@"blacklisted"] intValue] : 0;
                                        blacklisted_by_me = a[@"blacklisted_by_me"] && a[@"blacklisted_by_me"]!=nil ?  [a[@"blacklisted_by_me"] intValue] : 0;
                                        if(a[@"bdate"] && a[@"bdate"]!=nil){
                                            bdate=a[@"bdate"];
                                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                            NSString *templateLateTime2= @"yyyy";
                                            NSString *templateLateTime1= @"dd.MM.yyyy";
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
                                        
                                        countryName = a[@"country"] && a[@"country"]!=nil ? a[@"country"][@"title"] : @"";
                                        
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
                                        if([online intValue]==1){
                                            last_seen=@"";
                                        }
                                        
                                        site = a[@"site"] && a[@"site"]!=nil ? a[@"site"] :  @"";
                                        photoBig = a[@"photo_200"] ? a[@"photo_200"] : a[@"photo_200_orig"] ? a[@"photo_200_orig"] : a[@"photo_100"];
                                        photo = a[@"photo_100"];
                                        mobilePhone = a[@"mobile_phone"] && a[@"mobile_phone"]!=nil ? a[@"mobile_phone"] : @"";
                                        sex = a[@"sex"] && [a[@"sex"] intValue]==1 ? @"W" :[a[@"sex"] intValue]==2 ?  @"M" : [a[@"sex"] intValue]==0 ? @"n/a" : @"";
                                        books = a[@"books"] && a[@"books"]!=nil ? a[@"books"] : @"";
                                        about = a[@"about"] && a[@"about"]!=nil ? a[@"about"] : @"";
                                        education = a[@"university_name"] && a[@"university_name"]!=nil ? a[@"university_name"] : @"";
                                        schools = a[@"schools"] && a[@"schools"]!=nil &&  [a[@"schools"] count] > 0  ? a[@"schools"][0][@"name"] : @"";
                                        relation = a[@"relation"] && a[@"relation"]!=nil ? a[@"relation"] : @"";
                                        quotes = a[@"quotes"] && a[@"quotes"]!=nil ? a[@"quotes"] : @"";
                                        object = @{@"id":a[@"id"], @"full_name":fullName, @"city":city, @"status":status, @"user_photo":photo, @"user_photo_big":photoBig,@"country":countryName, @"bdate":bdate, @"online":online, @"last_seen":last_seen, @"sex":sex, @"site":site, @"mobile":mobilePhone, @"about":about, @"books":books, @"music":music, @"schools":schools, @"university_name":education, @"quotes":quotes, @"deactivated":deactivated, @"blacklisted":[NSNumber numberWithInt:blacklisted], @"blacklisted_by_me":[NSNumber numberWithInt:blacklisted_by_me], @"relation":relation, @"domain":domain};
                                        
                                        if(filterOnline.state==1 && filterOffline.state ==1 && filterActive.state == 1){
                                            
                                            if(searchByName){
                                                NSArray *found = [regex matchesInString:fullName  options:0 range:NSMakeRange(0, [fullName length])];
                                                if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
                                                    offsetCounter++;
                                                    [favesUsersData addObject:object];
                                                }
                                            }
                                            else{
                                                
                                                if(!a[@"deactivated"] || a[@"deactivated"]){
                                                    if(filterWomen.state==1 && filterMen.state==1){
                                                        if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                                            offsetCounter++;
                                                            [favesUsersData addObject:object];
                                                        }
                                                    }
                                                    else if(filterWomen.state==1 && filterMen.state==0){
                                                        if([a[@"sex"] intValue]==1){
                                                            offsetCounter++;
                                                            [favesUsersData addObject:object];
                                                        }
                                                        
                                                    }
                                                    else if(filterWomen.state==0 && filterMen.state==1){
                                                        if([a[@"sex"] intValue]==2){
                                                            offsetCounter++;
                                                            [favesUsersData addObject:object];
                                                        }
                                                        
                                                    }
                                                    else if(filterWomen.state==0 && filterMen.state==0){
                                                        if([a[@"sex"] intValue]==0){
                                                            offsetCounter++;
                                                            [favesUsersData addObject:object];
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                            }
                                        }
                                        else if(filterOnline.state==0 && filterOffline.state ==1 && filterActive.state == 1 ) {
                                            
                                            
                                            if(!a[@"deactivated"]){
                                                if ([online intValue] != 1){
                                                    
                                                    if(filterWomen.state==1 && filterMen.state==1){
                                                        if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                                            offsetCounter++;
                                                            [favesUsersData addObject:object];
                                                        }
                                                    }
                                                    else if(filterWomen.state==1 && filterMen.state==0){
                                                        if([a[@"sex"] intValue]==1){
                                                            offsetCounter++;
                                                            [favesUsersData addObject:object];
                                                        }
                                                        
                                                    }
                                                    else if(filterWomen.state==0 && filterMen.state==1){
                                                        if([a[@"sex"] intValue]==2){
                                                            offsetCounter++;
                                                            [favesUsersData addObject:object];
                                                        }
                                                        
                                                    }
                                                    else if(filterWomen.state==0 && filterMen.state==0){
                                                        if([a[@"sex"] intValue]==0){
                                                            offsetCounter++;
                                                            [favesUsersData addObject:object];
                                                        }
                                                        
                                                    }
                                                }
                                            }
                                        }
                                        else if(filterOnline.state==1 && filterOffline.state ==0 && filterActive.state == 1) {
                                            
                                            if ([online  isEqual: @"1"]){
                                                
                                                if(filterWomen.state==1 && filterMen.state==1){
                                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                                        offsetCounter++;
                                                        [favesUsersData addObject:object];
                                                    }
                                                }
                                                else if(filterWomen.state==1 && filterMen.state==0){
                                                    if([a[@"sex"] intValue]==1){
                                                        offsetCounter++;
                                                        [favesUsersData addObject:object];
                                                    }
                                                }
                                                else if(filterWomen.state==0 && filterMen.state==1){
                                                    if([a[@"sex"] intValue]==2){
                                                        offsetCounter++;
                                                        [favesUsersData addObject:object];
                                                    }
                                                }
                                                else if(filterWomen.state==0 && filterMen.state==0){
                                                    if([a[@"sex"] intValue]==0){
                                                        offsetCounter++;
                                                        [favesUsersData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                        else if(filterOnline.state==0 && filterOffline.state == 1 && filterActive.state == 0) {
                                            
                                            if (a[@"deactivated"]){
                                                
                                                if(filterWomen.state==1 && filterMen.state==1){
                                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                                        offsetCounter++;
                                                        [favesUsersData addObject:object];
                                                    }
                                                }
                                                else if(filterWomen.state==1 && filterMen.state==0){
                                                    if([a[@"sex"] intValue]==1){
                                                        offsetCounter++;
                                                        [favesUsersData addObject:object];
                                                    }
                                                }
                                                else if(filterWomen.state==0 && filterMen.state==1){
                                                    if([a[@"sex"] intValue]==2){
                                                        offsetCounter++;
                                                        [favesUsersData addObject:object];
                                                    }
                                                }
                                                else if(filterWomen.state==0 && filterMen.state==0){
                                                    if([a[@"sex"] intValue]==0){
                                                        offsetCounter++;
                                                        [favesUsersData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                        else if(filterOnline.state==1 && filterOffline.state == 1 && filterActive.state == 0) {
                                            
                                            if (a[@"deactivated"] && ([online intValue]==1 || [online intValue]==0)){
                                                
                                                if(filterWomen.state==1 && filterMen.state==1){
                                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                                        offsetCounter++;
                                                        [favesUsersData addObject:object];
                                                    }
                                                }
                                                else if(filterWomen.state==1 && filterMen.state==0){
                                                    if([a[@"sex"] intValue]==1){
                                                        offsetCounter++;
                                                        [favesUsersData addObject:object];
                                                    }
                                                }
                                                else if(filterWomen.state==0 && filterMen.state==1){
                                                    if([a[@"sex"] intValue]==2){
                                                        offsetCounter++;
                                                        [favesUsersData addObject:object];
                                                    }
                                                }
                                                else if(filterWomen.state==0 && filterMen.state==0){
                                                    if([a[@"sex"] intValue]==0){
                                                        offsetCounter++;
                                                        [favesUsersData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if([favesUsersData count]>0 && offsetLoadFaveUsers<totalCount){
                                        NSLog(@"BAD END");
                                        searchCount.title=[NSString stringWithFormat:@"%lu",offsetCounter];
                                        if(makeOffset){
                                            [favesUsersList insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startInsertRowIndex, [favesUsersData count]-1)] withAnimation:NSTableViewAnimationSlideDown];
                                              [favesUsersList reloadData];
                                        }else{
                                            [favesUsersList reloadData];
                                        }
                                        
                                    }
                                    
                                    
                                    [progressSpin stopAnimation:self];
                                    if([favesUsersData count]<15 && totalCount>=15 && offsetCounter < totalCount){
                                        loadFavesBlock(YES);
                                    }
                                    
                                });
                            }
                            
                        }
                    }]resume];
                }
            }
        }]resume];
    };
    if(makeOffset){
        loadFavesBlock(YES);
    }else{
        loadFavesBlock(NO);
    }
    
        
 
    
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row;
    if([[favesUsersList selectedRowIndexes]count]>0){
        row = [favesUsersList selectedRow];
        receiverDataForMessage = favesUsersData[row];
    }
    
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if ([favesUsersData count]>0) {
        return [favesUsersData count];
    }
    return 0;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if ([favesUsersData count]>0) {
        
        FavesUsersCustomCell *cell=[[FavesUsersCustomCell  alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.country.stringValue = favesUsersData[row][@"country"];
        cell.city.stringValue = favesUsersData[row][@"city" ];
        cell.fullName.stringValue = favesUsersData[row][@"full_name"];
//        cell.status.stringValue = favesUsersData[row][@"status"];
        [cell.status setAllowsEditingTextAttributes:YES];
        cell.status.attributedStringValue = [self getAttributedStringWithURLExternSites:favesUsersData[row][@"status"]];
        [cell.status setFont:[NSFont fontWithName:@"Helvetica" size:12]];
        cell.bdate.stringValue = favesUsersData[row][@"bdate"];
        cell.lastSeen.stringValue = favesUsersData[row][@"last_seen"];
        cell.sex.stringValue = favesUsersData[row][@"sex"];
//        NSSize imSize=NSMakeSize(80, 80);
        cell.photo.wantsLayer=YES;
        cell.photo.layer.cornerRadius=40;
        cell.photo.layer.masksToBounds=TRUE;
        if([favesUsersData[row][@"deactivated"] isEqual:@""]){
            cell.deactivatedStatus.hidden=YES;
        }else{
            cell.deactivatedStatus.stringValue = favesUsersData[row][@"deactivated"];
            cell.deactivatedStatus.hidden=NO;
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSImage *imagePhoto = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", favesUsersData[row][@"user_photo"]]]];
            NSImageRep *rep = [[imagePhoto representations] objectAtIndex:0];
            NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
            imagePhoto.size=imageSize;
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.photo setImage:imagePhoto];
            });
        });
        
        
        
        if([favesUsersData[row][@"online"] isEqual:@"1"]){
            [cell.online setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
            //             cell.lastOnline.stringValue = @"";
        }
        else{
            //             cell.lastOnline.stringValue = favesUsersData[row][@"last_seen"];
            [cell.online setImage:[NSImage imageNamed:NSImageNameStatusNone]];
        }
        
        return cell;
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
    NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:@"(?i)(?<!(//|\\w|(www\\.)|@))(?:[a-z0-9-\\._])+\\.(?:ru|com|net|info|tv|uk|de|ua)/?(?![^\\w/|\\U00000410-\\U0000044F\\U00002700-\\U000027BF\\U0001F300-\\U0001F5FF\\U0001F910-\\U0001F9C0\\U00002070-\\U0000209C\\s()<>])" options:NSRegularExpressionCaseInsensitive error:&error];
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

     [string addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:12]  range:NSMakeRange(0, [string length])];
    return string;
    
    
}
@end
