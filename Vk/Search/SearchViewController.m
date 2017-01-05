//
//  SearchViewController.m
//  vkapp
//
//  Created by sim on 02.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "SearchViewController.h"
#import "FullUserInfoPopupViewController.h"
@interface SearchViewController ()<NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate>

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    foundList.delegate = self;
    foundList.dataSource = self;
    searchBar.delegate = self;
    foundListData = [[NSMutableArray alloc]init];
    _app = [[appInfo alloc]init];
    [addBut setEnabled:NO];
    countries = [[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VisitUserPage:) name:@"VisitUserPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserToFaves:) name:@"addUserToFaves" object:nil];
    _stringHighlighter = [[StringHighlighter alloc]init];
    searchOffsetCounter = 0;
    [[searchListScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    [countriesList removeAllItems];
    [self loadCountries];
}
- (void)viewDidAppear{
    self.view.window.title=@"Global search";
    //    self.view.wantsLayer = YES;
    //    self.view.layer.masksToBounds=YES;
    //    self.view.layer.cornerRadius=8;
    //    self.view.layer.backgroundColor=[[NSColor blackColor]CGColor];
    self.view.window.titleVisibility=NSWindowTitleHidden;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    self.view.window.movableByWindowBackground=YES;
    //    self.view.wantsLayer=YES;
    //    self.view.layer.masksToBounds=YES;
    //    self.view.layer.backgroundColor=[[NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:0.0]CGColor];
    
    
    NSVisualEffectView* vibrantView = [[NSVisualEffectView alloc] initWithFrame:self.view.frame];
    vibrantView.material=NSVisualEffectStateActive;
    
    vibrantView.blendingMode=NSVisualEffectBlendingModeBehindWindow;
    
    
    vibrantView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    
    
    [vibrantView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    [self.view addSubview:vibrantView positioned:NSWindowBelow relativeTo:self.view];
}
-(void)viewDidScroll:(NSNotification*)notification{
    NSInteger scrollOrigin = [[searchListScrollView contentView]bounds].origin.y+NSMaxY([searchListScrollView visibleRect]);
    //    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
    NSInteger boundsHeight = foundList.bounds.size.height;
    //    NSInteger frameHeight = subscribersList.frame.size.height;
    if (scrollOrigin == boundsHeight) {
        //Refresh here
        //         NSLog(@"The end of table");
        if([foundListData count] > 0){
            [self loadPeople:YES useParams:usedParams];
        }
    }

}
-(void)loadCountries{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/database.getCountries?need_all=1&count=1000&access_token=%@&v=%@", _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *countriesResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"%@", countriesResp);
        for(NSDictionary *i in countriesResp[@"response"][@"items"]){
            [countries addObject:i[@"id"]];
            dispatch_async(dispatch_get_main_queue(), ^{
                  [countriesList addItemWithObjectValue:i[@"title"]];
            });
          
        }
    }]resume];
}
- (IBAction)searchWithParams:(id)sender {
    usedParams=YES;
    country = nil;
    country = countries[[countriesList indexOfSelectedItem]] ? countries[[countriesList indexOfSelectedItem]] : nil;
    [self loadResults:YES];
    
}
-(void)addUserToFaves:(NSNotification*)notification{
     NSInteger row = [notification.userInfo[@"row"] intValue];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/fave.addUser?user_id=%@&v=%@&access_token=%@",foundListData[row][@"id"], _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSDictionary *faveAddUser = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"%@", faveAddUser);
    }]resume];
}
-(void)VisitUserPage:(NSNotification*)notification{
    NSInteger row = [notification.userInfo[@"row"] intValue];
//    NSLog(@"%@", foundListData[row]);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/id%@",foundListData[row][@"id"]]]];
}
- (IBAction)showFullInfo:(id)sender {
    if(searchType.selectedSegment==1){
        NSStoryboard *story = [NSStoryboard storyboardWithName:@"Third" bundle:nil];
        FullUserInfoPopupViewController *popuper = [story instantiateControllerWithIdentifier:@"profilePopup"];
        NSPoint mouseLoc = [NSEvent mouseLocation];
            int x = mouseLoc.x;
        int y = mouseLoc.y;
        
        
        //    int scrollPosition = [[scrollView contentView] bounds].origin.y+120;
        
        NSView *parentCell = [sender superview];
        NSInteger row = [foundList rowForView:parentCell];
        CGRect rect=CGRectMake(x, y, 0, 0);
        popuper.receivedData = foundListData[row];
        
        [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:foundList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
//        [self presentViewController:friendsStatController asPopoverRelativeToRect:friendsStatBut.frame ofView:self.view preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
    }
    else if(searchType.selectedSegment==0){
        
        NSView *parentCell = [sender superview];
        NSInteger row = [foundList rowForView:parentCell];
//        popuper.receivedData = foundListData[row];
        [self loadGroupByIdInfo:foundListData[row][@"id"]];
//        [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:foundList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
    }
    
}
-(void)loadGroupByIdInfo:(NSString*)groupId{
    
    url = [NSString stringWithFormat:@"https://api.vk.com/method/groups.getById?group_id=%@&fields=description,city,country,members_count,status,site,start_date,finish_date,ban_info&access_token=%@&v=%@", groupId, _app.token, _app.version];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *groupByIdInfoResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for (NSDictionary *i in groupByIdInfoResp[@"response"]){
                
                NSString *desc;
                NSString *photo;
                NSString *deactivated;
                NSString *city;
                NSString *country;
                NSNumber *membersCount;
                NSString *status;
                NSNumber *startDate;
                NSNumber *finishDate;
                NSNumber *isAdmin;
                NSNumber *isClosed;
                NSNumber *isMember;
                NSString *site;
                NSString *type;
                NSString *screenName;
                NSString *banInfo;
              
                desc = i[@"description"] && i[@"description"] != nil ? i[@"description"] : @"";
                photo = i[@"photo_200"] ? i[@"photo_200"] : i[@"photo_100"] ?  i[@"photo_100"] : i[@"photo_50"];
                deactivated = i[@"deactivated"] ? i[@"deactivated"] : @"";
                membersCount = i[@"members_count"] && i[@"members_count"] != nil ? i[@"members_count"] : @0;
                status = i[@"status"] && i[@"status"]  != nil ? i[@"status"] : @"";
                startDate = i[@"start_date"] && i[@"start_date"]!=nil ? i[@"start_date"] : @0;
                finishDate = i[@"finish_date"] && i[@"finish_date"]!=nil ? i[@"finish_date"]  : @0;
                isClosed =  [i[@"is_closed"] intValue] == 0 ? @NO : @YES;
                isAdmin =  [i[@"is_admin"] intValue]==0 ? @NO : @YES;
                isMember =  [i[@"is_member"] intValue]==0 ? @NO : @YES;
                site = i[@"site"] && i[@"site"] != nil ? i[@"site"] : @"";
                country = i[@"country"] && i[@"country"][@"title"] != nil ? i[@"country"][@"title"] : @"";
                type = i[@"type"] && i[@"type"] != nil ? i[@"type"] : @"";
                screenName = i[@"screen_name"] && i[@"screen_name"] != nil ? i[@"screen_name"] : @"";
                banInfo = i[@"ban_info"] && i[@"ban_info"]!=nil ? i[@"ban_info"] : @"";
                city = i[@"city"] && i[@"city"][@"title"]!=nil ? i[@"city"][@"title"] : @"";
                
                
                object = @{@"name":i[@"name"], @"id":[NSString stringWithFormat:@"%@",i[@"id"]], @"deactivated":deactivated, @"desc":desc, @"photo":photo, @"members_count":membersCount, @"status":status, @"site":site, @"start_date":startDate, @"country":country, @"city":city, @"type":type, @"screen_name":screenName, @"is_member":isMember, @"finish_date":finishDate, @"ban_info":banInfo};
                
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
                FullUserInfoPopupViewController *popuper = [story instantiateControllerWithIdentifier:@"GroupFullInfo"];
                NSPoint mouseLoc = [NSEvent mouseLocation];
                //    int x = mouseLoc.x;
                int y = mouseLoc.y;
                //    int scrollPosition = [[scrollView contentView] bounds].origin.y+120;
          
                CGRect rect=CGRectMake(0, y, 0, 0);
                popuper.receivedData = object;
//                NSLog(@"%@", object);
                [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:foundList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
                
            });

            
        }
    }]resume];
}

-(void)viewDidLayout{
    [searchBar becomeFirstResponder];
}

-(void)searchFieldDidEndSearching:(NSSearchField *)sender{

}
-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    usedParams=NO;
    [self loadResults:NO];
    
}
- (IBAction)searchTypeAction:(id)sender {
    if(searchType.selectedSegment == 0){
        [addBut setEnabled:YES];
    }
    else{
        [addBut setEnabled:NO];
    }
}

-(void)loadPeople:(BOOL)makeOffset useParams:(BOOL)useParams{
    if(makeOffset){
        searchOffsetCounter = searchOffsetCounter + 100;
    }else{
        searchOffsetCounter = 0;
        [foundListData removeAllObjects];
        [foundList reloadData];
    }
    
    queryString = [searchBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    if(useParams){
        NSString *fullQuery = queryString ? [NSString stringWithFormat:@"q=%@&", queryString] : nil;
        
        NSString *countryParam = country ? [NSString stringWithFormat:@"country=%@&", country] : nil;
        
        url = [NSString stringWithFormat:@"https://api.vk.com/method/users.search?%@sort=0&%@count=100&offset=%li&fields=city,domain,photo_100,photo_200_orig,photo_200,status,last_seen,bdate,online,country,sex,about,books,contacts,site,music,schools,education,quotes,blacklisted,blacklisted_by_me,relation,counters,is_friend,verified&v=%@&access_token=%@",  fullQuery ? fullQuery : @"", countryParam ? countryParam : @"", searchOffsetCounter, _app.version, _app.token];
    
    }else{
        
        if(byId.state==1){
            url = [NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@&fields=city,domain,photo_100,photo_200_orig,photo_200,status,last_seen,bdate,online,country,sex,about,books,contacts,site,music,schools,education,quotes,blacklisted,blacklisted_by_me,relation,counters&v=%@&access_token=%@", searchBar.stringValue, _app.version, _app.token];
        }else{
            url = [NSString stringWithFormat:@"https://api.vk.com/method/users.search?q=%@&sort=0&count=100&offset=%li&fields=city,domain,photo_100,photo_200_orig,photo_200,status,last_seen,bdate,online,country,sex,about,books,contacts,site,music,schools,education,quotes,blacklisted,blacklisted_by_me,relation,counters&v=%@&access_token=%@",  queryString, searchOffsetCounter, _app.version, _app.token];
        }
    }
   
    

    
    __block NSInteger totalCountPeople;
//    __block NSInteger startInsertIndex = [foundListData count];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            
            NSDictionary *searchResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            NSLog(@"%@", searchResponse);
            totalCountPeople = [searchResponse[@"response"][@"count"] intValue];
            searchResponse = byId.state==1? searchResponse[@"response"]: searchResponse[@"response"][@"items"];
            for (NSDictionary *a in searchResponse){
                
                NSString *city;
                NSString *status;
                NSString *bdate;
                int online;
//                NSString *firstName;
//                NSString *lastName;
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
              
                int verified;
//                NSString *friendsCount;
                int blacklisted;
                int blacklisted_by_me;
                verified = [a[@"verified"] intValue];
                 fullName =  [NSString stringWithFormat:@"%@ %@", a[@"first_name"], a[@"last_name"]];
                city = a[@"city"] && a[@"city"][@"title"]!=nil ? a[@"city"][@"title"] : @"";
                status = a[@"status"] && a[@"status"]!=nil ? a[@"status"] : @"";
                blacklisted = a[@"blacklisted"] && a[@"blacklisted"]!=nil?  [a[@"blacklisted"] intValue] : 0;
                
                blacklisted_by_me = a[@"blacklisted_by_me"] && a[@"blacklisted_by_me"]!=nil ?  [a[@"blacklisted_by_me"] intValue] : 0;
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
                        bdate = [NSString stringWithFormat:@"%d", 2016 - [[formatter stringFromDate:date] intValue]];
                    }
                    if([bdate isEqual:@"2016" ]){
                        bdate=@"";
                    }
                }
                else{
                    bdate=@"";
                }
                online =[a[@"online"] intValue];
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
                if(online){
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
                domain = a[@"domain"] ? a[@"domain"] : @"";
//                NSLog(@"%@", a[@"counters"] );
                object = @{@"id":a[@"id"], @"full_name":fullName, @"city":city, @"status":status, @"user_photo":photo, @"bdate":bdate,@"country":countryName,  @"online":[NSNumber numberWithInt:online], @"user_photo_big":photoBig,  @"last_seen":last_seen, @"books":books, @"site":site, @"about":about, @"mobile":mobilePhone, @"music":music, @"schools":schools, @"university_name":education, @"quotes":quotes, @"deactivated":deactivated,@"blacklisted":[NSNumber numberWithInt:blacklisted],@"blacklisted_by_me":[NSNumber numberWithInt:blacklisted_by_me], @"relation":relation, @"domain":domain, @"verified":[NSNumber numberWithInt:verified]};
//                NSLog(@"%@", object);
              
                
                [foundListData addObject:object];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [foundList insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:[foundListData count]==0?0:[foundListData count]] withAnimation:NSTableViewAnimationEffectNone];
                });
            }
            dispatch_async(dispatch_get_main_queue(), ^{
//                if(searchOffsetCounter != 1000){
                
//                    if(makeOffset && totalCountPeople > 0 && totalCountPeople > searchOffsetCounter){
//                        [foundList insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startInsertIndex, [foundListData count]-1)] withAnimation:NSTableViewAnimationSlideDown];
////                        [foundList reloadData];
//                    }else{
//                        [foundList reloadData];
//                    }
                loadedCountResults.title = [NSString stringWithFormat:@"%li", [foundListData count]];
//                }
            });
        }
    }] resume];
}
-(void)loadGroups{
    
    url = [NSString stringWithFormat:@"https://api.vk.com/method/groups.search?q=%@&sort=0&count=100&v=%@&access_token=%@", queryString, _app.version, _app.token];
    [foundListData removeAllObjects];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            
            NSDictionary *searchResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for (NSDictionary *i in searchResponse[@"response"][@"items"]){
                
                NSString *desc;
                NSString *photo;
                NSString *deactivated;
                NSString *city;
                NSString *country;
                NSNumber *membersCount;
                NSString *status;
                NSNumber *startDate;
                NSNumber *finishDate;
                NSNumber *isAdmin;
                NSNumber *isClosed;
                NSNumber *isMember;
                NSString *site;
                NSString *type;
                NSString *screenName;
                
                int online;
                online= [i[@"online"] intValue];
                desc = i[@"description"] && i[@"description"] != nil ? i[@"description"] : @"";
                photo = i[@"photo_200"] ? i[@"photo_200"] : i[@"photo_100"] ?  i[@"photo_100"] : i[@"photo_50"];
                deactivated = i[@"deactivated"] ? i[@"deactivated"] : @"";
                membersCount = i[@"members_count"] && i[@"members_count"] != nil ? i[@"members_count"] : @0;
                status = i[@"status"] && i[@"status"]  != nil ? i[@"status"] : @"";
                startDate = i[@"start_date"] && i[@"start_date"]!=nil ? i[@"start_date"] : @0;
                finishDate = i[@"finish_date"] && i[@"finish_date"]!=nil ? i[@"finish_date"]  : @0;
                isClosed =  [i[@"is_closed"] intValue] == 0 ? @NO : @YES;
                isAdmin =  [i[@"is_admin"] intValue]==0 ? @NO : @YES;
                isMember =  [i[@"is_member"] intValue]==0 ? @NO : @YES;
                site = i[@"site"] && i[@"site"] != nil ? i[@"site"] : @"";
                country = i[@"country"] && i[@"country"][@"title"] != nil ? i[@"country"][@"title"] : @"";
                type = i[@"type"] && i[@"type"] != nil ? i[@"type"] : @"";
                screenName = i[@"screen_name"] && i[@"screen_name"] != nil ? i[@"screen_name"] : @"";
    
                city = i[@"city"] && i[@"city"][@"title"]!=nil ? i[@"city"][@"title"] : @"";
                object = @{@"name":i[@"name"], @"id":[NSString stringWithFormat:@"%@",i[@"id"]], @"deactivated":deactivated, @"desc":desc, @"photo":photo, @"members_count":membersCount, @"status":status, @"site":site, @"start_date":startDate, @"country":country, @"city":city, @"type":type, @"screen_name":screenName, @"is_member":isMember, @"finish_date":finishDate};
                
                [foundListData addObject:object];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [foundList reloadData];
            });
        }
    }]resume];
}
-(void)loadResults:(BOOL)useParams{
    queryString = [searchBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    switch(searchType.selectedSegment){
        case 0:
            [self loadGroups];
            break;
        case 1:
            [self loadPeople:NO useParams:useParams];
            break;
    }
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([foundListData count]>0){
        return [foundListData count];
    }
    return 0;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([foundListData count]>0){
        CustomSearchCell *cell = (CustomSearchCell*)[tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.photo.wantsLayer=YES;
        cell.photo.layer.cornerRadius=60/2;
        cell.photo.layer.masksToBounds=YES;
        cell.lastSeen.stringValue=foundListData[row][@"last_seen"];
        cell.country.stringValue=foundListData[row][@"country"];
        cell.verified.hidden = [foundListData[row][@"verified"] intValue] ? NO : YES;
        cell.age.stringValue = foundListData[row][@"bdate"];
        cell.city.stringValue = foundListData[row][@"city"];
//        cell.userStatus.stringValue =foundListData[row][@"status"];
//        [cell.userStatus setFont:[NSFont systemFontOfSize:12 weight:NSFontWeightRegular]];
        [cell.userStatus setAllowsEditingTextAttributes:YES];
        if( [foundListData[row][@"blacklisted"] intValue] ||  [foundListData[row][@"blacklisted_by_me"] intValue]) {
            cell.blacklisted.hidden=NO;
        }else{
            cell.blacklisted.hidden=YES;
        };
        if(searchType.selectedSegment==1){
            cell.name.stringValue = foundListData[row][@"full_name"];
            //cell.fieldId.stringValue = [NSString stringWithFormat:@"%@", foundListData[row][@"id"]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 NSAttributedString *attrStatusString = [_stringHighlighter highlightStringWithURLs:foundListData[row][@"status"] Emails:YES fontSize:12];
                NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", foundListData[row][@"user_photo"]]]];
                NSSize imSize=NSMakeSize(60, 60);
                image.size=imSize;
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.userStatus.attributedStringValue = attrStatusString;
                    [cell.userStatus setFont:[NSFont fontWithName:@"Helvetica" size:12]];
                    [cell.photo setImage:image];
                });
            });
            if([foundListData[row][@"online"] intValue]){
                [cell.status setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
            }else{
                [cell.status setImage:[NSImage imageNamed:NSImageNameStatusNone]];
            }
        }
        else if(searchType.selectedSegment==0){
            
            cell.name.stringValue = foundListData[row][@"name"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSImage *image = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", foundListData[row][@"photo"]]]];
                NSSize imSize=NSMakeSize(60, 60);
                image.size=imSize;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.photo setImage:image];
                });
            });
            
        }
        return cell;
    }
    return nil;
}
@end
