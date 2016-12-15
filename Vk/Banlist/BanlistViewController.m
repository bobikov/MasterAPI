//
//  BanlistViewController.m
//  vkapp
//
//  Created by sim on 01.06.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "BanlistViewController.h"
#import "FullUserInfoPopupViewController.h"
#import "FriendsStatController.h"
@interface BanlistViewController () <NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate>

@end

@implementation BanlistViewController
@synthesize arrayController, value;
- (void)viewDidLoad {
    [super viewDidLoad];
    banList.dataSource = self;
    banList.delegate = self;
    searchBar.delegate=self;
    _app = [[appInfo alloc]init];
    banlistData = [[NSMutableArray alloc]init];
    foundData = [[NSMutableArray alloc]init];
    NSArray *dateFilterItems = @[@"all", @" > 10", @"> this month"];
    [[banListScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    [dateFilterOptionsPopup removeAllItems];
    [dateFilterOptionsPopup addItemsWithTitles:dateFilterItems];
    value = [[NSMutableArray alloc]init];
   selectedUsers=[[NSMutableArray alloc]init];
    cachedImage = [[NSMutableDictionary alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VisitUserPageFromBanlist:) name:@"VisitUserPageFromBanlist" object:nil];
    _stringHighlighter = [[StringHighlighter alloc]init];
}
-(void)VisitUserPageFromBanlist:(NSNotification*)notification{
    NSInteger row = [notification.userInfo[@"row"] intValue];
    NSLog(@"%@", banlistData[row]);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/id%@",banlistData[row][@"id"]]]];
}
-(void)viewDidAppear{
    if(!loading){
        [self loadBanlist:NO :NO];
    }
    
}
- (IBAction)showUserFullInfo:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Third" bundle:nil];
    FullUserInfoPopupViewController *popuper = [story instantiateControllerWithIdentifier:@"profilePopup"];
    NSPoint mouseLoc = [NSEvent mouseLocation];
    //    int x = mouseLoc.x;
    int y = mouseLoc.y;
    //    int scrollPosition = [[scrollView contentView] bounds].origin.y+120;
    
    NSView *parentCell = [sender superview];
    NSInteger row = [banList rowForView:parentCell];
    CGRect rect=CGRectMake(0, y, 0, 0);
    popuper.receivedData = banlistData[row];
    
    [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:banList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
    
}
- (IBAction)showBanlistStat:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
    FriendsStatController *controller = [story instantiateControllerWithIdentifier:@"FriendsStatController"];
    controller.receivedData = @{@"data":banlistData};
    [self presentViewController:controller asPopoverRelativeToRect:banlistStatBut.frame ofView:self.view.subviews[0] preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
}

-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    searchMode=YES;
    [self loadSearchBanlist];
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    searchMode=NO;
    banlistData = banlistDataCopy;
    [banList reloadData];
}
-(void)viewDidScroll:(NSNotification *)notification{
    if([notification.object isEqual:banListClipView]){
        NSInteger scrollOrigin = [[banListScrollView contentView]bounds].origin.y+NSMaxY([banListScrollView visibleRect]);
        //    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
        NSInteger boundsHeight = banList.bounds.size.height;
        //    NSInteger frameHeight = subscribersList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            //Refresh here
            //         NSLog(@"The end of table");
            if(!searchMode && [banlistData count]!=0 && !loading && offsetLoadBanlist < totalCountBanned){
                [self loadBanlist:NO :YES];
            }
        }
        //        NSLog(@"%ld", scrollOrigin);
        //        NSLog(@"%ld", boundsHeight);
        //    NSLog(@"%fld", frameHeight-300);
        //
    }
}
- (IBAction)filterByDate:(id)sender {
    switch ([dateFilterOptionsPopup indexOfSelectedItem]){
        case 0:
            [self loadAllDates];
            break;
        case 1:
            [self loadEqualOrMoreThenDays];
            break;
        case 2:
             [self loadEqualOrMoreThenMonthLastSeen];
            break;
    }
    
}
-(void)loadAllDates{
    banlistData = banlistDataCopy;
    [banList reloadData];
}
- (IBAction)filterInUserBlackList:(id)sender {
//    banlistDataCopy = [[NSMutableArray alloc]initWithArray:banlistDataCopy];
//    for(NSDictionary *i in banlistDataCopy){
//        
//    }
    [self loadBanlist:NO :NO];
    
}
-(BOOL)checkIfMoreOrEqualDays:(id)date{
//    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger currentDateSubstractDays = [components day] - 10;
    if(![date isEqual:@""] && date!=nil){
        NSArray *lastSeenComponents = [date componentsSeparatedByString:@"."];
        //        NSLog(@"%@", lastSeenComponents[1]);
        if([lastSeenComponents[0] intValue]<=currentDateSubstractDays){
            return YES;
        }
    }
    return NO;
}
-(BOOL)checkIfMoreOrEqualMonth:(id)date{
//    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    if(![date isEqual:@""] && date!=nil){
        NSArray *lastSeenComponents = [date componentsSeparatedByString:@"."];
//        NSLog(@"%@", lastSeenComponents[1]);
        if([lastSeenComponents[1] intValue]<[components month]){
            return YES;
        }
    }
    return NO;
}
-(void)loadEqualOrMoreThenDays{
    banlistDataCopy = [[NSMutableArray alloc]initWithArray:banlistData];
    [banlistData removeAllObjects];
    for(NSDictionary *i in banlistDataCopy){
//        NSLog(@"%@", [i[@"last_seen"] componentsSeparatedByString:@"."]);
        if([self checkIfMoreOrEqualDays:i[@"last_seen"]]){
            [banlistData addObject:i];
            
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [banList reloadData];
    });
}
-(void)loadEqualOrMoreThenMonthLastSeen{
    banlistDataCopy = [[NSMutableArray alloc]initWithArray:banlistData];
    [banlistData removeAllObjects];
    for(NSDictionary *i in banlistDataCopy){
//        NSLog(@"%@", [i[@"last_seen"] componentsSeparatedByString:@"."]);
        if([self checkIfMoreOrEqualMonth:i[@"last_seen"]]){
            [banlistData addObject:i];
            
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [banList reloadData];
    });
}
-(void)loadSearchBanlist{
   
        NSInteger counter=0;
        NSMutableArray *banlistDataTemp=[[NSMutableArray alloc]init];
        banlistDataCopy = [[NSMutableArray alloc]initWithArray:banlistData];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
        [banlistDataTemp removeAllObjects];
        for(NSDictionary *i in banlistData){
            
            NSArray *found = [regex matchesInString:i[@"full_name"]  options:0 range:NSMakeRange(0, [i[@"full_name"] length])];
            if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
                counter++;
                [banlistDataTemp addObject:i];
            }
            
        }
//     NSLog(@"Start search %@", banlistDataTemp);
        if([banlistDataTemp count]>0){
            banlistData = banlistDataTemp;
            [banList reloadData];
        }
    
}
-(void)setFiltersDisabled{
    filterActive.enabled=NO;
    filterMen.enabled=NO;
    filterActive.enabled=NO;
    filterWomen.enabled=NO;
    filterOnline.enabled=NO;
    filterOffline.enabled=NO;
    filterInUserBlacklist.enabled=NO;
}
-(void)setFiltersEnabled{
    filterActive.enabled=YES;
    filterMen.enabled=YES;
    filterActive.enabled=YES;
    filterWomen.enabled=YES;
    filterOnline.enabled=YES;
    filterOffline.enabled=YES;
    filterInUserBlacklist.enabled=YES;
}
- (IBAction)filterWomenAction:(id)sender {
//    [self setFiltersDisabled];
    if(!loading)
        [banList scrollToBeginningOfDocument:self];
        [self loadBanlist:NO :NO];
    
}
- (IBAction)filterMenAction:(id)sender {
//     [self setFiltersDisabled];
    if(!loading)
        [banList scrollToBeginningOfDocument:self];
        [self loadBanlist:NO :NO];
}

- (IBAction)FriendsFilterOfflineAction:(id)sender {
//     [self setFiltersDisabled];
    if(!loading)
        [banList scrollToBeginningOfDocument:self];
        [self loadBanlist:NO :NO];
    
}
- (IBAction)FriendsFilterOnlineAction:(id)sender {
//     [self setFiltersDisabled];
    if(!loading)
        [banList scrollToBeginningOfDocument:self];
        [self loadBanlist:NO :NO];
}
- (IBAction)FriendsFilterActiveAction:(id)sender {
//     [self setFiltersDisabled];
    if(!loading){
        [banList scrollToBeginningOfDocument:self];
        if(filterActive.state == 0){
            filterOffline.state=1;
            filterOnline.state=0;
        }
        //    else{
        //        filterOnline.state=1;
        //    }
        
        [self loadBanlist:NO :NO];
    }
}
-(void)loadBanlist:(BOOL)searchByName :(BOOL)makeOffset{
    __block void(^getBannedBlock)(BOOL);
    
 
    getBannedBlock = ^void(BOOL offset){
        searchMode=NO;
        
        [progressSpin startAnimation:self];
        if(offset){
            offsetLoadBanlist=offsetLoadBanlist+200;
        }else{
            [banlistData removeAllObjects];
            offsetLoadBanlist=0;
            offsetCounter=0;
        }
        __block NSDictionary *object;
      
        __block NSInteger startInsertRowIndex = [banlistData count];
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/account.getBanned?count=200&offset=%lu&v=%@&access_token=%@",offsetLoadBanlist, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if(data){
                NSDictionary *getBannedResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if(getBannedResponse[@"error"]){
                    
                }else{
                    totalCountBanned = [getBannedResponse[@"response"][@"count"] intValue];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        totalCount.title=[NSString stringWithFormat:@"%@", getBannedResponse[@"response"][@"count"]];
                    });
                    NSMutableArray *banlistLight = [[NSMutableArray alloc]init];
                    for(NSDictionary *i in getBannedResponse[@"response"][@"items"]){
                        [banlistLight addObject:i[@"id"]];
                        
                    }
                    //        NSLog(@"%@", banlistLight);
                    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@&fields=city,domain,photo_50,photo_100,photo_200_orig,photo_200,status,last_seen,bdate,online,country,sex,about,books,contacts,site,music,schools,education,quotes,blacklisted,blacklisted_by_me,relation&v=%@&access_token=%@", [banlistLight componentsJoinedByString:@","], _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        
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
                        //                NSString *phone;
                        NSString *photoBig;
                        NSString *photo;
                        NSString *about;
                        NSString *music;
                        NSString *schools;
                        NSString *education;
                        NSString *quotes;
                        NSString *deactivated;
                        NSString *relation;
                        NSString *domain;
                        __block int blacklisted;
                        int blacklisted_by_me;
                        if(data){
                            NSDictionary *userGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            
                            for(NSDictionary *a in userGetResponse[@"response"]){
                                
                                firstName = a[@"first_name"];
                                lastName=a[@"last_name"];
                                fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
                                city = a[@"city"] && a[@"city"][@"title"]!=nil ? a[@"city"][@"title"] : @"";
                                status = a[@"status"] && a[@"status"]!=nil ? a[@"status"] : @"";
                                blacklisted = a[@"blacklisted"] && a[@"blacklisted"]!=nil?  [a[@"blacklisted"] intValue] : 0;
                                blacklisted_by_me = a[@"blacklisted_by_me"] && a[@"blacklisted_by_me"]!=nil ?  [a[@"blacklisted_by_me"] intValue] : 0;
                                domain = a[@"domain"] && a[@"domain"]!=nil ? a[@"domain"] : @"";
                                if(a[@"bdate"] && a[@"bdate"] && a[@"bdate"]!=nil){
                                    bdate=a[@"bdate"];
                                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                    NSString *templateLateTime2= @"yyyy";
                                    NSString *templateLateTime1= @"d.M.yyyy";
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
                                online = [NSString stringWithFormat:@"%@", a[@"online"]];
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
                                photoBig = a[@"photo_200"] ? a[@"photo_200"] : a[@"photo_200_orig"] ? a[@"photo_200_orig"] : a[@"photo_100"];
                                photo = a[@"photo_100"];
                                mobilePhone = a[@"mobile_phone"] && a[@"mobile_phone"]!=nil ? a[@"mobile_phone"] : @"";
                                sex = a[@"sex"] && [a[@"sex"] intValue]==1 ? @"W" :[a[@"sex"] intValue]==2 ?  @"M" : [a[@"sex"] intValue]==0 ? @"n/a" : @"";
                                books = a[@"books"] && a[@"books"]!=nil ? a[@"books"] : @"";
                                about = a[@"about"] && a[@"about"]!=nil ? a[@"about"] : @"";
                                music = a[@"music"] && a[@"music"]!=nil ? a[@"music"] : @"";
                                education = a[@"university_name"] && a[@"university_name"]!=nil ? a[@"university_name"] : @"";
                                schools = a[@"schools"] && a[@"schools"]!=nil &&  [a[@"schools"] count] > 0  ? a[@"schools"][0][@"name"] : @"";
                                quotes = a[@"quotes"] && a[@"quotes"]!=nil ? a[@"quotes"] : @"";
                                relation = a[@"relation"] && a[@"relation"]!=nil ? a[@"relation"] : @"";
                                deactivated = a[@"deactivated"] ? a[@"deactivated"] : @"";
                                object = @{@"id":a[@"id"], @"full_name":fullName, @"city":city, @"status":status, @"user_photo":photo, @"bdate":bdate,@"country":countryName,  @"online":online, @"user_photo_big":photoBig,  @"last_seen":last_seen, @"books":books, @"site":site, @"about":about, @"mobile":mobilePhone, @"music":music, @"schools":schools, @"university_name":education, @"quotes":quotes, @"deactivated":deactivated,@"blacklisted":[NSNumber numberWithInt:blacklisted],@"blacklisted_by_me":[NSNumber numberWithInt:blacklisted_by_me], @"sex":sex, @"relation":relation, @"domain":domain};
                                
                                
                                
                                if(filterOnline.state==1 && filterOffline.state ==1 && filterActive.state == 1){
                                    
                                    
                                    //                                 [FriendsData removeAllObjects];
                                    if (!a[@"deactivated"]){
                                        if(filterWomen.state==1 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                        else if(filterWomen.state==1 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==1){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==2){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                            
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==0){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                else if(filterOnline.state==0 && filterOffline.state ==1 && filterActive.state == 1 ) {
                                    
                                    
                                    if (![online  isEqual: @"1"]){
                                        if(filterWomen.state==1 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }                                }
                                        }
                                        else if(filterWomen.state==1 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==1){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==2){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                            
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==0){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                else if(filterOnline.state==1 && filterOffline.state ==0 && filterActive.state == 1) {
                                    
                                    if ([online  isEqual: @"1"]){
                                        if(filterWomen.state==1 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                        else if(filterWomen.state==1 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==1){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==2){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                            
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==0){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                else if(filterOnline.state==0 && filterOffline.state == 1 && filterActive.state == 0) {
                                    
                                    if (a[@"deactivated"]){
                                        if(filterWomen.state==1 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                        else if(filterWomen.state==1 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==1){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==2){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                            
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==0){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                else if(filterOnline.state==1 && filterOffline.state == 1 && filterActive.state == 0) {
                                    
                                    if (a[@"deactivated"] && ([online intValue]==1 || [online intValue]==0)){
                                        if(filterWomen.state==1 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] == 2){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                        else if(filterWomen.state==1 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==1){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==1){
                                            if([a[@"sex"] intValue]==2){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                            
                                        }
                                        else if(filterWomen.state==0 && filterMen.state==0){
                                            if([a[@"sex"] intValue]==0){
                                                if(filterInUserBlacklist.state==1){
                                                    if(blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }else{
                                                    if(!blacklisted){
                                                        offsetCounter++;
                                                        [banlistData addObject:object];
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                  
                                //                [banlistData addObject:@{@"id":a[@"id"], @"full_name":fullName, @"city":city, @"status":status, @"user_photo":a[@"photo_100"], @"country":countryName, @"bdate":bdate, @"online":online}];
                                
                                //                offsetCounter++;
                                //
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //                arrayController.content = banlistData;
                                loadedCount.title=[NSString stringWithFormat:@"%li", [banlistData count]];
                                NSLog(@"%li", [banlistData count]);
                                [self setFiltersEnabled];
                                if(makeOffset){
//                                    [banList insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startInsertRowIndex, [banlistData count]-1)] withAnimation:NSTableViewAnimationSlideDown];
                                     [banList reloadData];
                                    
                                }else{
                                    [banList reloadData];
                                }
                                [progressSpin stopAnimation:self];
                                if([banlistData count]<15 && totalCountBanned>=15 && offsetLoadBanlist < totalCountBanned){
                                    loading=YES;
                                    getBannedBlock(YES);
                                }else if ([banlistData count]<15 && totalCountBanned>=15 && offsetLoadBanlist >= totalCountBanned){
                                    [progressSpin stopAnimation:self];
                                    loading=NO;
                                }else{
                                    [progressSpin stopAnimation:self];
                                    loading=NO;
                                }
                                NSLog(@"%li", offsetLoadBanlist);
                                 NSLog(@"%li", offsetCounter);
                            });
                        }
                    }] resume];
                    
                }
            }
        }]resume];
        
    };
    if(makeOffset){
        getBannedBlock(YES);
    }else{
        getBannedBlock(NO);
    }
}

- (IBAction)unbanAction:(id)sender {
    NSIndexSet *rows;
    rows=[banList selectedRowIndexes];
    [selectedUsers removeAllObjects];
      [progressSpin startAnimation:self];
    void(^UnbunUserBlock)()=^void(){

   
        for(NSDictionary *i in [banlistData objectsAtIndexes:rows]){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/account.unbanUser?user_id=%@&v=%@&access_token=%@", i[@"id"], _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *unbanUserResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
                NSLog(@"%@", unbanUserResponse);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [banList deselectRow:[banlistData indexOfObject:i]];
                });
                
            }]resume];
            sleep(1);
           
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [banlistData removeObjectsAtIndexes:rows];
            [banList removeRowsAtIndexes:rows withAnimation:NSTableViewAnimationSlideRight];
            [progressSpin stopAnimation:self];
            [banList reloadData];
        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UnbunUserBlock();

    });

    
    
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([banlistData count]>0){
        return [banlistData count];
    }
    return 0;
}
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([banlistData count]>0){
        BanlistCustomCell *cell = [[BanlistCustomCell alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.fullName.stringValue = banlistData[row][@"full_name"];
        cell.userCountry.stringValue = banlistData[row][@"country"];
        cell.city.stringValue = banlistData[row][@"city"];
        cell.bdate.stringValue = banlistData[row][@"bdate"];
        cell.lastSeen.stringValue = banlistData[row][@"last_seen"];
        cell.blacklisted.hidden = [banlistData[row][@"blacklisted"] intValue] ? NO : YES;
       
//        if(![banlistData[row][@"status"]isEqual:@""] && banlistData[row][@"status"]!=nil){
//        cell.status.stringValue=banlistData[row][@"status"];
        [cell.status setAllowsEditingTextAttributes:YES];
        cell.status.attributedStringValue = [_stringHighlighter highlightStringWithURLs:banlistData[row][@"status"] Emails:YES fontSize:12];
        [cell.status setFont:[NSFont fontWithName:@"Helvetica" size:12]];
//        }else{
//                    cell.status.stringValue = banlistData[row][@"status"];
//        }
//       cell.status.stringValue = banlistData[row][@"status"];
        cell.deactivated.stringValue = banlistData[row][@"deactivated"];
        cell.sex.stringValue = banlistData[row][@"sex"];

        cell.userPhoto.wantsLayer=YES;
        cell.userPhoto.layer.masksToBounds=YES;
        cell.userPhoto.layer.cornerRadius=80/2;
        if([cachedImage count]>0 && cachedImage[banlistData[row]]){
            cell.userPhoto.image=cachedImage[banlistData[row]];
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", banlistData[row][@"user_photo"]]]];
                NSImageRep *rep = [[image representations] objectAtIndex:0];
                NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
                image.size=imageSize;
                
                cachedImage[banlistData[row]]=image;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.userPhoto setImage:image];
                });
            });
        }
        if([banlistData[row][@"online"] intValue] == 1){
            [cell.onlineStatus setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
        }
        else{
            [cell.onlineStatus setImage:[NSImage imageNamed:NSImageNameStatusNone]];
        }
        return cell;
    }
    
    return nil;
}

@end
