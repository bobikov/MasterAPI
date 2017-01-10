//
//  FriendsViewController.m
//  vkapp
//
//  Created by sim on 19.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "FriendsViewController.h"
#import "FriendsMessageSendViewController.h"
#import "FriendsStatController.h"
#import "FullUserInfoPopupViewController.h"
#import "ViewControllerMenuItem.h"
@interface FriendsViewController ()<NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate>

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
//     myCell = [[FriendsCustomCellView alloc]init];
    searchBar.delegate=self;
    cleanTableFlag=NO;
    _app = [[appInfo alloc]init];
    selectedUsers = [[NSMutableArray alloc]init];
    [FriendsTableView setDelegate:self];
    [FriendsTableView setDataSource:self];
    FriendsData = [[NSMutableArray alloc]init];
    [progressSpin startAnimation:self];
    friendsListPopupData = [[NSMutableArray alloc]init];
    [friendsListPopup removeAllItems];
     _stringHighlighter = [[StringHighlighter alloc]init];
    [self loadFriendsPopup];
    cachedImage = [[NSMutableDictionary alloc]init];
    cachedStatus = [[NSMutableDictionary alloc]init];
//    self.view.wantsLayer=YES;
//    [self.view.layer setBackgroundColor:[[NSColor whiteColor] CGColor]];
//    
//    FriendsMessageSendViewController *fac = [[FriendsMessageSendViewController alloc]init];
//     searchBar.sendsWholeSearchString=YES;
   
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    [style setAlignment:NSCenterTextAlignment];
//    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
//    NSAttributedString *attrString = [[NSAttributedString alloc]initWithString:mainSendMessage.title attributes:attrsDictionary];
//    [mainSendMessage setAttributedTitle:attrString];
//    [self setButtonStyle:mainSendMessage];
//    [self setButtonStyle:deleteFromFriends];
//    [self setButtonStyle:addToBlackList];
}
-(void)loadFriendsPopup{
    __block NSMenu *menu1 = [[NSMenu alloc]init];
    __block  NSMenuItem *menuItem;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(!_loadFromFullUserInfo){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/friends.get?owner_id=%@&v=%@&fields=city,domain,photo_50&access_token=%@", _app.person, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *getFriendsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

                for(NSDictionary *i in getFriendsResponse[@"response"][@"items"]){
                    [friendsListPopupData addObject:@{@"full_name":[NSString stringWithFormat:@"%@ %@", i[@"first_name"], i[@"last_name"]], @"id":i[@"id"]}];
                    ViewControllerMenuItem *viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
                    [viewControllerItem loadView];
                    menuItem = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"%@ %@", i[@"first_name"], i[@"last_name"]] action:nil keyEquivalent:@""];
                    
                   
                    NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:i[@"photo_50"]]];
                    
                    image.size=NSMakeSize(30,30);
                    viewControllerItem.photo.wantsLayer=YES;
                    viewControllerItem.photo.layer.masksToBounds=YES;
                    viewControllerItem.photo.layer.cornerRadius=39/2;
                    [menuItem setImage:image];
//                    viewControllerItem.photo.layer.borderColor = [[NSColor grayColor] CGColor];
//                     viewControllerItem.photo.layer.borderWidth = 2.0;
                    [viewControllerItem.photo setImageScaling:NSImageScaleProportionallyUpOrDown];
                    viewControllerItem.nameField.stringValue=[NSString stringWithFormat:@"%@ %@", i[@"first_name"],i[@"last_name"]];
                    [viewControllerItem.photo setImage:image];
                    [menuItem setView:[viewControllerItem view]];
                    [menu1 addItem:menuItem];
                }
                dispatch_async(dispatch_get_main_queue(),^{
                    //[friendsListDropdown setPullsDown:YES];
                    [friendsListPopup removeAllItems];
                    [friendsListPopup setMenu:menu1];
                });
            }]resume];
        }else{
            [friendsListPopupData removeAllObjects];
            [friendsListPopupData addObject:@{@"full_name":[NSString stringWithFormat:@"%@", _userDataFromFullUserInfo[@"full_name"]], @"id":_userDataFromFullUserInfo[@"id"]}];
            ViewControllerMenuItem *viewControllerItem = [[ViewControllerMenuItem alloc]initWithNibName:@"ViewControllerMenuItem" bundle:nil];
            [viewControllerItem loadView];
            menuItem = [[NSMenuItem alloc]initWithTitle:[NSString stringWithFormat:@"%@", _userDataFromFullUserInfo[@"full_name"]] action:nil keyEquivalent:@""];
            NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:_userDataFromFullUserInfo[@"user_photo"]]];
            
            image.size=NSMakeSize(30,30);
            viewControllerItem.photo.wantsLayer=YES;
            viewControllerItem.photo.layer.masksToBounds=YES;
            viewControllerItem.photo.layer.cornerRadius=39/2;
            [menuItem setImage:image];
            //                    viewControllerItem.photo.layer.borderColor = [[NSColor grayColor] CGColor];
            //                     viewControllerItem.photo.layer.borderWidth = 2.0;
            [viewControllerItem.photo setImageScaling:NSImageScaleProportionallyUpOrDown];
            viewControllerItem.nameField.stringValue=[NSString stringWithFormat:@"%@", _userDataFromFullUserInfo[@"full_name"]];
            [viewControllerItem.photo setImage:image];
            [menuItem setView:[viewControllerItem view]];
            [menu1 addItem:menuItem];
            dispatch_async(dispatch_get_main_queue(), ^{
                [friendsListPopup removeAllItems];
//                [friendsListPopup addItemWithTitle:_userDataFromFullUserInfo[@"full_name"]];
                [friendsListPopup setMenu:menu1];
            });
        }
    });
 
}
- (IBAction)goUp:(id)sender {
    [FriendsTableView scrollRowToVisible: 0];
}
- (IBAction)goDown:(id)sender {
    [FriendsTableView scrollRowToVisible:[FriendsTableView numberOfRows] - 1];
}

-(void)viewDidAppear{
    if(_loadFromFullUserInfo || _loadFromWallPost){
        self.view.window.titleVisibility=NSWindowTitleHidden;
        self.view.window.titlebarAppearsTransparent = YES;
        self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
        self.view.window.movableByWindowBackground=YES;
    }

    [self loadFriends:NO];

}
- (IBAction)friendsListPopupSelect:(id)sender {
//
    _ownerId = [NSString stringWithFormat:@"%@", friendsListPopupData[[friendsListPopup indexOfSelectedItem]][@"id"]];
    NSLog(@"%@", _ownerId);
    [self loadFriends:NO];
}

- (IBAction)showFriendsStat:(id)sender {
    
    NSStoryboard *secondStory = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
    FriendsStatController *friendsStatController = [secondStory instantiateControllerWithIdentifier:@"FriendsStatController"];
    friendsStatController.receivedData = @{@"data":FriendsData};
    
//    [self presentViewControllerAsModalWindow:friendsStatController];
    [self presentViewController:friendsStatController asPopoverRelativeToRect:friendsStatBut.frame ofView:self.view preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
}
-(void)loadSearchFriendsList{
    
    NSInteger counter=0;
    NSMutableArray *FriendsDataTemp=[[NSMutableArray alloc]init];
    FriendsDataCopy = [[NSMutableArray alloc]initWithArray:FriendsData];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
    [FriendsDataTemp removeAllObjects];
    for(NSDictionary *i in FriendsData){
        
        NSArray *found = [regex matchesInString:i[@"full_name"]  options:0 range:NSMakeRange(0, [i[@"full_name"] length])];
        if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
            counter++;
            [FriendsDataTemp addObject:i];
        }
        
    }
    //     NSLog(@"Start search %@", banlistDataTemp);
    if([FriendsDataTemp count]>0){
        FriendsData = FriendsDataTemp;
        [FriendsTableView reloadData];
    }
    
}
- (IBAction)deleteFromFriendsAction:(id)sender {
    
    NSIndexSet *rows;
    rows=[FriendsTableView selectedRowIndexes];
    [selectedUsers removeAllObjects];
    void(^deleteFromFriendsBlock)()=^void(){
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            [selectedUsers addObject:@{@"id":FriendsData[i][@"id"], @"index":[NSNumber numberWithInteger:i]}];
            
            
        }
        for(NSDictionary *i in selectedUsers){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/friends.delete?user_id=%@&v=%@&access_token=%@", i[@"id"] ,_app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *deleteFromFriendsResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
                NSLog(@"%@", deleteFromFriendsResponse);
            }]resume];
            dispatch_async(dispatch_get_main_queue(), ^{
                [FriendsTableView deselectRow:[i[@"index"] intValue]];
            });
            sleep(1);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [FriendsData removeObjectsAtIndexes:rows];
            [FriendsTableView reloadData];
            

        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        deleteFromFriendsBlock();
    });

}
- (IBAction)addToBlacklistAction:(id)sender {
    
    NSIndexSet *rows;
    rows=[FriendsTableView selectedRowIndexes];
    [selectedUsers removeAllObjects];
    void(^addToBanBlock)()=^void(){
      
        for(NSDictionary *i in [FriendsData objectsAtIndexes:rows]){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/account.banUser?user_id=%@&v=%@&access_token=%@", i[@"id"] ,_app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *addToBanResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
                NSLog(@"%@", addToBanResponse);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [FriendsTableView deselectRow:[FriendsData indexOfObject:i]];
                });
            }]resume];
            sleep(1);
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [FriendsData removeObjectsAtIndexes:rows];
            [FriendsTableView reloadData];
            
            
        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        addToBanBlock();
    });
    
}
- (IBAction)selectAllAction:(id)sender {
    
    [FriendsTableView selectAll:self];
}
-(void)setButtonStyle:(id)button{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    NSAttributedString *attrString = [[NSAttributedString alloc]initWithString:[button title] attributes:attrsDictionary];
    [button setAttributedTitle:attrString];
}
- (IBAction)fdfd:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Third" bundle:nil];
    FullUserInfoPopupViewController *popuper = [story instantiateControllerWithIdentifier:@"profilePopup"];
    NSPoint mouseLoc = [NSEvent mouseLocation];
//    int x = mouseLoc.x;
    int y = mouseLoc.y;
//    int scrollPosition = [[scrollView contentView] bounds].origin.y+120;
   
    NSView *parentCell = [sender superview];
    NSInteger row = [FriendsTableView rowForView:parentCell];
     CGRect rect=CGRectMake(0, y, 0, 0);
    popuper.receivedData = FriendsData[row];
    
    [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:FriendsTableView preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadUserFullInfo" object:self userInfo:dataForUserInfo];
}

-(void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showDetailSegue"]){
        FriendsMessageSendViewController *controller = (FriendsMessageSendViewController *)segue.destinationController;

        controller.recivedDataForMessage=receiverDataForMessage;
    }
}
- (IBAction)womenFilterAction:(id)sender {
    [self loadFriends:NO];
    
}
- (IBAction)menFilterAction:(id)sender {
    [self loadFriends:NO];
    
}
- (IBAction)FriendsFilterOfflineAction:(id)sender {

     [self loadFriends:NO];
  
}
- (IBAction)FriendsFilterOnlineAction:(id)sender {
 
    [self loadFriends:NO];
}
- (IBAction)FriendsFilterActiveAction:(id)sender {
    if(FriendsFilterActive.state == 0){
        FriendsFilterOffline.state=1;
        FriendsFilterOnline.state=0;
    }
//    else{
//        FriendsFilterOnline.state=1;
//    }
    [self loadFriends:NO];
}
-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    [self loadSearchFriendsList];
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    
    FriendsData = FriendsDataCopy;
    [FriendsTableView reloadData];
}

-(void)cleanTable{
    NSIndexSet *index=[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [FriendsData count])];
    
    [FriendsTableView removeRowsAtIndexes:index withAnimation:0];
//    [FriendsData removeAllObjects];
//    if([FriendsData count]==0){
//        [FriendsData removeAllObjects];
//        [FriendsTableView reloadData];
//        [FriendsTableView reloadData];
////        sleep(2);
//          [self loadFriends:NO];
//    }
    
  
}

-(void)loadFriends:(BOOL)searchByName{
    [progressSpin startAnimation:self];
    [FriendsData removeAllObjects];
    _ownerId = _ownerId == nil ? _app.person : _ownerId;
    __block NSDictionary *object;
    NSURLSessionDataTask *dataTask = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/friends.get?user_id=%@&fields=city,domain,photo_100,photo_200,status,last_seen,bdate,online,country,sex,books,site,contacts,about,music,schools,education,quotes,relation,blacklisted_by_me,blacklisted&count=1000&access_token=%@&v=%@", _ownerId, _app.token, _app.version]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(data){
            if (error){
                NSLog(@"Check your connection");
                return;
            }
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                
                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                
                if (statusCode != 200) {
                    NSLog(@"dataTask HTTP status code: %lu", statusCode);
                    return;
                }
                else{
          
                }

            }
            
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if ([jsonData objectForKey:@"error"]){
                NSLog(@"%@:%@", jsonData[@"error"][@"error_code"], jsonData[@"error"][@"error_msg"]);
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
                //                        NSString *phone;
                NSString *photoBig;
                NSString *photo;
                NSString *about;
                NSString *music;
                NSString *education;
                NSString *schools;
                NSString *quotes;
                NSString *relation;
                NSString *relation_partner;
                NSString *domain;
                NSInteger blacklisted;
                NSInteger blacklisted_by_me;
                NSInteger counter=0;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    friendsTotalCount.title=[NSString stringWithFormat:@"%i",[jsonData[@"response"][@"count"] intValue]];
                    
                    
                    
                });
                if([jsonData[@"response"][@"items"] count]>0){
                    
                    for (NSDictionary *a in jsonData[@"response"][@"items"]){
                        fullName = [NSString stringWithFormat:@"%@ %@", a[@"first_name"], a[@"last_name"]];
                        firstName = a[@"first_name"];
                        lastName = a[@"last_name"];
                        online = [NSString stringWithFormat:@"%@", a[@"online"]];
                        city = a[@"city"] && a[@"city"][@"title"]!=nil ? a[@"city"][@"title"] : @"";
                        status = a[@"status"] && a[@"status"]!=nil ? a[@"status"] : @"";
                        music = a[@"music"] && a[@"music"]!=nil ? a[@"music"] : @"";
                        domain = a[@"domain"] && a[@"domain"]!=nil ? a[@"domain"] : @"";
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
                        photoBig = a[@"photo_200"] ? a[@"photo_200"] : a[@"photo_100"];
                        photo = a[@"photo_100"];
                        mobilePhone = a[@"mobile_phone"] && a[@"mobile_phone"]!=nil ? a[@"mobile_phone"] : @"";
                        sex = a[@"sex"] && [a[@"sex"] intValue]==1 ? @"W" :[a[@"sex"] intValue]==2 ?  @"M" : [a[@"sex"] intValue]==0 ? @"n/a" : @"";
                        books = a[@"books"] && a[@"books"]!=nil ? a[@"books"] : @"";
                        about = a[@"about"] && a[@"about"]!=nil ? a[@"about"] : @"";
                        education = a[@"university_name"] && a[@"university_name"]!=nil ? a[@"university_name"] : @"";
                        schools = a[@"schools"] && a[@"schools"]!=nil &&  [a[@"schools"] count] > 0  ? a[@"schools"][0][@"name"] : @"";
                        relation = a[@"relation"] && a[@"relation"]!=nil ? a[@"relation"] : @"";
                        relation_partner = a[@"relation_partner"] && a[@"relation_partner"]!=nil ? a[@"relation_partner"] : @"";
                        quotes = a[@"quotes"] && a[@"quotes"]!=nil ? a[@"quotes"] : @"";
                        object = @{@"id":a[@"id"], @"full_name":fullName, @"city":city, @"status":status, @"user_photo":photo, @"user_photo_big":photoBig,@"country":countryName, @"bdate":bdate, @"online":online, @"last_seen":last_seen, @"sex":sex, @"site":site, @"mobile":mobilePhone, @"about":about, @"books":books, @"music":music, @"schools":schools, @"university_name":education, @"quotes":quotes, @"relation":relation, @"relation_partner":relation_partner, @"domain":domain, @"blacklisted":[NSNumber numberWithInteger:blacklisted], @"blacklisted_by_me":[NSNumber numberWithInteger:blacklisted_by_me]};
                        
                        if(FriendsFilterOnline.state==1 && FriendsFilterOffline.state ==1 && FriendsFilterActive.state == 1){
                            
                            if(searchByName){
                                NSArray *found = [regex matchesInString:fullName  options:0 range:NSMakeRange(0, [fullName length])];
                                if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
                                    counter++;
                                    [FriendsData addObject:object];
                                }
                            }
                            else{
                                
                                if(!a[@"deactivated"]){
                                    if(womenFilter.state==1 && menFilter.state==1){
                                        if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                            counter++;
                                            [FriendsData addObject:object];
                                        }
                                    }
                                    else if(womenFilter.state==1 && menFilter.state==0){
                                        if([a[@"sex"] intValue]==1){
                                            counter++;
                                            [FriendsData addObject:object];
                                        }
                                        
                                    }
                                    else if(womenFilter.state==0 && menFilter.state==1){
                                        if([a[@"sex"] intValue]==2){
                                            counter++;
                                            [FriendsData addObject:object];
                                        }
                                        
                                    }
                                    else if(womenFilter.state==0 && menFilter.state==0){
                                        if([a[@"sex"] intValue]==0){
                                            counter++;
                                            [FriendsData addObject:object];
                                        }
                                        
                                    }
                                    
                                }
                            }
                        }
                        else if(FriendsFilterOnline.state==0 && FriendsFilterOffline.state ==1 && FriendsFilterActive.state == 1 ) {
                            
                            
                            if(!a[@"deactivated"]){
                                if ([online intValue] != 1){
                                    
                                    if(womenFilter.state==1 && menFilter.state==1){
                                        if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                            counter++;
                                            [FriendsData addObject:object];
                                        }
                                    }
                                    else if(womenFilter.state==1 && menFilter.state==0){
                                        if([a[@"sex"] intValue]==1){
                                            counter++;
                                            [FriendsData addObject:object];
                                        }
                                        
                                    }
                                    else if(womenFilter.state==0 && menFilter.state==1){
                                        if([a[@"sex"] intValue]==2){
                                            counter++;
                                            [FriendsData addObject:object];
                                        }
                                        
                                    }
                                    else if(womenFilter.state==0 && menFilter.state==0){
                                        if([a[@"sex"] intValue]==0){
                                            counter++;
                                            [FriendsData addObject:object];
                                        }
                                        
                                    }
                                }
                            }
                        }
                        else if(FriendsFilterOnline.state==1 && FriendsFilterOffline.state ==0 && FriendsFilterActive.state == 1) {
                            
                            if ([online  isEqual: @"1"]){
                                
                                if(womenFilter.state==1 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                        counter++;
                                        [FriendsData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==1 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==1){
                                        counter++;
                                        [FriendsData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==2){
                                        counter++;
                                        [FriendsData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==0){
                                        counter++;
                                        [FriendsData addObject:object];
                                    }
                                }
                            }
                        }
                        else if(FriendsFilterOnline.state==0 && FriendsFilterOffline.state == 1 && FriendsFilterActive.state == 0) {
                            
                            if (a[@"deactivated"]){
                                
                                if(womenFilter.state==1 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                        counter++;
                                        [FriendsData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==1 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==1){
                                        counter++;
                                        [FriendsData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==2){
                                        counter++;
                                        [FriendsData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==0){
                                        counter++;
                                        [FriendsData addObject:object];
                                    }
                                }
                            }
                        }
                        else if(FriendsFilterOnline.state==1 && FriendsFilterOffline.state == 1 && FriendsFilterActive.state == 0) {
                            
                            if (a[@"deactivated"] && ([online intValue]==1 || [online intValue]==0)){
                                
                                if(womenFilter.state==1 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue] ==2){
                                        counter++;
                                        [FriendsData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==1 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==1){
                                        counter++;
                                        [FriendsData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==1){
                                    if([a[@"sex"] intValue]==2){
                                        counter++;
                                        [FriendsData addObject:object];
                                    }
                                }
                                else if(womenFilter.state==0 && menFilter.state==0){
                                    if([a[@"sex"] intValue]==0){
                                        counter++;
                                        [FriendsData addObject:object];
                                    }
                                }
                            }
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([FriendsData count]>0){
                        [FriendsTableView reloadData];
                        
                    }
                    FriendsCountInline.title=[NSString stringWithFormat:@"%lu",counter];
                    
                    [progressSpin stopAnimation:self];
                    
                });
            }
            
        }
    }];
    [dataTask resume];
    
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row;
    if([[FriendsTableView selectedRowIndexes]count]>0){
        row = [FriendsTableView selectedRow];
        receiverDataForMessage = FriendsData[row];
    }
 
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if ([FriendsData count]>0) {
        return [FriendsData count];
    }
    return 0;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if ([FriendsData count]>0) {
       
        FriendsCustomCellView *cell=[[FriendsCustomCellView alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.country.stringValue = FriendsData[row][@"country"];
        cell.city.stringValue = FriendsData[row][@"city" ];
        cell.fullName.stringValue = FriendsData[row][@"full_name"];
//        cell.status.stringValue = FriendsData[row][@"status"];
        [cell.status setAllowsEditingTextAttributes:YES];
       
        cell.bdate.stringValue = FriendsData[row][@"bdate"];
        cell.lastSeen.stringValue = FriendsData[row][@"last_seen"];
        cell.sex.stringValue = FriendsData[row][@"sex"];
        NSSize imSize=NSMakeSize(80, 80);
        cell.photo.wantsLayer=YES;
        cell.photo.layer.cornerRadius=40;
        cell.photo.layer.masksToBounds=TRUE;
        if([cachedImage count]>0 && cachedImage[FriendsData[row]] && cachedStatus[FriendsData[row]]){
            cell.photo.image=cachedImage[FriendsData[row]];
            cell.status.attributedStringValue = cachedStatus[FriendsData[row]];
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSAttributedString *attrStatusString = [_stringHighlighter highlightStringWithURLs:FriendsData[row][@"status"] Emails:YES fontSize:12];
                cachedStatus[FriendsData[row]]=attrStatusString;
                NSImage *imagePhoto = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", FriendsData[row][@"user_photo"]]]];
                imagePhoto.size=imSize;
                cachedImage[FriendsData[row]] = imagePhoto;
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.status.attributedStringValue = attrStatusString;
                    [cell.status setFont:[NSFont fontWithName:@"Helvetica" size:12]];
                    [cell.photo setImage:imagePhoto];
                });
            });
        }
      

        if([FriendsData[row][@"online"] isEqual:@"1"]){
            [cell.online setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
//             cell.lastOnline.stringValue = @"";
        }
        else{
//             cell.lastOnline.stringValue = FriendsData[row][@"last_seen"];
            [cell.online setImage:[NSImage imageNamed:NSImageNameStatusNone]];
        }
       
        return cell;
    }
    
    return nil;
}


@end
