//
//  SearchViewController.m
//  vkapp
//
//  Created by sim on 02.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "SearchViewController.h"
#import "FullUserInfoPopupViewController.h"
#import "SearchGroupsCellView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <EventKit/EventKit.h>
#import "MyTableRowView.h"
#import <IRFAutoCompletionKit/IRFAutoCompletionKit.h>

@interface SearchViewController ()<NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate,NSComboBoxDelegate>

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
    cities = [[NSMutableArray alloc]init];
    
    NSNib *nib = [[NSNib alloc] initWithNibNamed:@"SearchGroupsCellView" bundle:nil];
    [foundList registerNib:nib forIdentifier: @"SearchGroupsCellView"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VisitUserPage:) name:@"VisitUserPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addUserToFaves:) name:@"addUserToFaves" object:nil];
    _stringHighlighter = [[StringHighlighter alloc]init];
    searchOffsetCounter = 0;
    [[searchListScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    [countriesList removeAllItems];
    [citiesList removeAllItems];
    [religionsList removeAllItems];
    [self loadCountries];
    [self loadReligions];
    
//    IRFAutoCompletionTextFieldManager *complMan = [IRFAutoCompletionTextFieldManager new];
//    IRFAutoCompletionProvider *cProvider = [IRFAutoCompletionProvider new];
//    [complMan attachToTextField:searchBar];
//    [complMan setTextFieldFowardingDelegate:self];
//    [complMan setCompletionProviders:@[cProvider]];
//    
//    
//    EKEventStore *store =[[EKEventStore alloc]init];
//    [store calendarsForEntityType:EKEntityTypeEvent];
//    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
//    dayComponent.day = 1;
//    
//    NSCalendar *theCalendar = [NSCalendar currentCalendar];
//    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
//    
//    NSLog(@"nextDate: %@ ...", nextDate);
    
//    [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"testValue":@"test value"}];
    
//    [[NSUserDefaults standardUserDefaults] setObject:@{@"apps":@[@{@"app1":@{@"token":@"token app1"}}]} forKey:@"testValue"];
//    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] dictionaryRepresentation] );
    
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
    [self.view.window makeFirstResponder:searchBar];

}

- (void)viewDidScroll:(NSNotification*)notification{
    NSInteger scrollOrigin = [[searchListScrollView contentView]bounds].origin.y+NSMaxY([searchListScrollView visibleRect]);
    //    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
    NSInteger boundsHeight = foundList.bounds.size.height;
    //    NSInteger frameHeight = subscribersList.frame.size.height;
    if (scrollOrigin == boundsHeight) {
        //Refresh here
        //         NSLog(@"The end of table");
        if([foundListData count] > 0 && !byId.state){
            if([selectedSourceName isEqualToString:@"people"]){
                [self loadPeople:YES useParams:usedParams];
            }else if([selectedSourceName isEqualToString:@"group"]){
                [self loadGroups:YES useParams:usedParams];
            }
        }
    }
}


//- (void)viewSetupMethod {
//    IRFEmojiAutoCompletionProvider *emojiCompletionProvider = [IRFEmojiAutoCompletionProvider new];
//    NSArray *completionsProviders = @[emojiCompletionProvider];
//    [self setAutoCompletionManager:[IRFAutoCompletionTextFieldManager new]];
//    [self.autoCompletionManager setCompletionProviders:completionsProviders];
//    [self.autoCompletionManager attachToTextField:searchBar];
//    [self.autoCompletionManager setTextFieldFowardingDelegate:self];
//}

- (void)controlTextDidChange:(NSNotification *)obj{
 
    if([obj.object isEqual:citiesList]){
//           NSLog(@"f333");
        if([citiesList.stringValue length]==0){
            [cities removeAllObjects];
        }
    }else if([obj.object isEqual:religionsList]){
//        NSLog(@"%@", religionsList.stringValue);
        if([religionsList.stringValue length]==0){
            
        }else{
            religion=[religionsList.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        }
    }
}
- (void)loadReligions{
    NSArray *religions = @[@"Иудаизм", @"Христианство", @"Католицизм", @"Православие", @"Протестантизм", @"Гностицизм", @"Ислам", @"Бабизм", @"Вера Бахаи", @"Растафарианство", @"Айявари", @"Буддизм", @"Индуизм", @"Джайнизм", @"Сикхизм", @"Даосизм", @"Конфуцианство", @"Синтоизм", @"Неоязычество", @"Современные религии, духовные и мистические учения", @"Нью-эйдж", @"Эзотеризм и мистицизм"];
    [religionsList addItemsWithObjectValues:religions];
}

- (IBAction)selectCountry:(id)sender {
    if(![countriesList.stringValue isEqual:@""] && ![countriesList.stringValue isEqual:nil]){
        countryID = countries[[countriesList indexOfSelectedItem]];
        [self loadCities];
    }
    
}
- (IBAction)selectCity:(id)sender {
    if(![citiesList.stringValue isEqual:@""] && ![citiesList.stringValue isEqual:nil]){
        //    NSLog(@"%li", [cities count]);
        //    NSLog(@"%@", citiesList.stringValue );
        if([cities count]==0 ){
            cityQuery = [citiesList.stringValue length]>0 ? [citiesList.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] : nil;
            
            [self loadCities];
            NSLog(@"A");
        }else{
            NSLog(@"B");
            if([citiesList indexOfSelectedItem]<[cities count]){
                cityID = cities[[citiesList indexOfSelectedItem]];
            }
            NSLog(@"%@", countriesList.stringValue);
            NSLog(@"%@", cityID);
        }
    }
}





- (void)loadResults:(BOOL)useParams{
    queryString = [searchBar.stringValue length]>0? [searchBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]:nil;
    switch(searchType.selectedSegment){
        case 0:
            selectedSourceName = @"group";
            [self loadGroups:NO useParams:useParams];
            break;
        case 1:
            selectedSourceName = @"people";
            [self loadPeople:NO useParams:useParams];
            break;
    }
}
- (void)loadCountries{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/database.getCountries?need_all=1&count=1000&access_token=%@&v=%@", _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *countriesResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //NSLog(@"%@", countriesResp);
            for(NSDictionary *i in countriesResp[@"response"][@"items"]){
                [countries addObject:i[@"id"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [countriesList addItemWithObjectValue:i[@"title"]];
                });
            }
        }
    }]resume];
}
- (void)loadCities{
    [cities removeAllObjects];
    [citiesList removeAllItems];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/database.getCities?country_id=%@&%@need_all=1&count=1000&access_token=%@&v=%@", countryID, cityQuery ? [NSString stringWithFormat:@"q=%@&",cityQuery] : @"", _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(data){
            NSDictionary *countriesResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //NSLog(@"%@", countriesResp);
            for(NSDictionary *i in countriesResp[@"response"][@"items"]){
                [cities addObject:i[@"id"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [citiesList addItemWithObjectValue:i[@"title"]];
                });
                
            }
            dispatch_async(dispatch_get_main_queue(),^{
//
            });
        }      
    }]resume];
}
- (IBAction)searchWithParams:(id)sender {
    usedParams=YES;
    countryID = nil;
    countryID = ![countriesList.stringValue isEqual:@""] && countriesList.stringValue!=nil ? countries[[countriesList indexOfSelectedItem]] : nil;
    [self loadResults:YES];
}
- (void)addUserToFaves:(NSNotification*)notification{
     NSInteger row = [notification.userInfo[@"row"] intValue];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/fave.addUser?user_id=%@&v=%@&access_token=%@",foundListData[row][@"id"], _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSDictionary *faveAddUser = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"%@", faveAddUser);
    }]resume];
}
- (void)VisitUserPage:(NSNotification*)notification{
    NSInteger row = [notification.userInfo[@"row"] intValue];
//    NSLog(@"%@", foundListData[row]);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/id%@",foundListData[row][@"id"]]]];
}
- (IBAction)showFullInfo:(id)sender {
    if(searchType.selectedSegment==1){
        NSStoryboard *story = [NSStoryboard storyboardWithName:@"Third" bundle:nil];
        FullUserInfoPopupViewController *popuper = [story instantiateControllerWithIdentifier:@"profilePopup"];
//        NSPoint mouseLoc = [NSEvent mouseLocation];
//        int x = mouseLoc.x;
//        int y = mouseLoc.y;
        //    int scrollPosition = [[scrollView contentView] bounds].origin.y+120
        NSView *parentCell = [sender superview];
        NSInteger row = [foundList rowForView:parentCell];
//        CGRect rect=CGRectMake(x, y, 0, 0);
//         CGRect rect=CGRectMake(0, y, 0, 0);
        popuper.receivedData = foundListData[row];
        [popuper setToViewController];
//        [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:foundList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
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
- (void)loadGroupByIdInfo:(NSString*)groupId{
    [_app getGroupById:groupId :^(NSDictionary * _Nonnull groupInfoObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
            FullUserInfoPopupViewController *popuper = [story instantiateControllerWithIdentifier:@"GroupFullInfo"];
            NSPoint mouseLoc = [NSEvent mouseLocation];
            //int x = mouseLoc.x;
            int y = mouseLoc.y;
            //int scrollPosition = [[scrollView contentView] bounds].origin.y+120;
            CGRect rect=CGRectMake(0, y, 0, 0);
            popuper.receivedData = groupInfoObject;
            //NSLog(@"%@", object);
            [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:foundList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
        });
    }];
}

- (void)searchFieldDidEndSearching:(NSSearchField *)sender{

}
- (void)searchFieldDidStartSearching:(NSSearchField *)sender{
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
- (void)loadPeople:(BOOL)makeOffset useParams:(BOOL)useParams{
    queryString = [searchBar.stringValue length]>0?[searchBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]:nil;
    if(useParams){
        NSURLComponents *paramsComponents = [[NSURLComponents alloc]init];
        NSMutableArray *mutableParams = [NSMutableArray array];
        NSURLQueryItem *countryParam =  [NSURLQueryItem queryItemWithName:@"country" value:[NSString stringWithFormat:@"%@",countryID]] ;
        NSURLQueryItem *cityParam = [NSURLQueryItem queryItemWithName:@"city" value:[NSString stringWithFormat:@"%@",cityID]];
        NSURLQueryItem *religionParam = [NSURLQueryItem queryItemWithName:@"religion" value:[NSString stringWithFormat:@"%@",religion]] ;
        NSURLQueryItem *fullQueryParam = [NSURLQueryItem queryItemWithName:@"q" value:[NSString stringWithFormat:@"%@",queryString]] ;
       
        if(cityID){
            [mutableParams addObject:cityParam];
        }
        if(countryID){
            [mutableParams addObject:countryParam];
        }
        if(religion){
            [mutableParams addObject:religionParam];
        }
        if(queryString){
            [mutableParams addObject:fullQueryParam];
        }
        paramsComponents.queryItems = mutableParams;
        NSLog(@"%@", paramsComponents.query);
        NSLog(@"%@", mutableParams);
//        NSLog(@"%@", countryParam);
        url = [NSString stringWithFormat:@"https://api.vk.com/method/users.search?%@sort=0&count=100&offset=%li&fields=city,domain,photo_100,photo_200_orig,photo_200,status,last_seen,bdate,online,country,sex,about,books,contacts,site,music,schools,education,quotes,blacklisted,blacklisted_by_me,relation,counters,is_friend,verified&v=%@&access_token=%@", [paramsComponents.query stringByAppendingString:@"&"], searchOffsetCounter, _app.version, _app.token];
    
    }else{
        if(byId.state==1){
            [_app searchPeople:@[searchBar.stringValue]  queryString:nil offset:makeOffset  :^(NSMutableArray * _Nonnull people) {
                foundListData = people;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [foundList reloadData];
                    
                    loadedCountResults.title = [NSString stringWithFormat:@"%li", [foundListData count]];
                });
            }];
            
        }else{
            [_app searchPeople:nil queryString:queryString offset:makeOffset :^(NSMutableArray * _Nonnull people) {
                foundListData = people;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [foundList reloadData];
             
                    loadedCountResults.title = [NSString stringWithFormat:@"%li", [foundListData count]];
                });
            }];
        }
    }
}
- (void)loadGroups:(BOOL)makeOffset useParams:(BOOL)useParams{
    queryString = [searchBar.stringValue stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    if(useParams){
        NSString *countryParam = countryID ? [NSString stringWithFormat:@"country_id=%@&", countryID] : nil;
        url = [NSString stringWithFormat:@"https://api.vk.com/method/groups.search?q=%@&sort=0&count=100&%@offset=%li&v=%@&access_token=%@", queryString,  countryParam ? countryParam : @"", searchOffsetCounter, _app.version, _app.token];
    }else{
        url = [NSString stringWithFormat:@"https://api.vk.com/method/groups.search?q=%@&sort=0&count=100&offset=%li&v=%@&access_token=%@", queryString, searchOffsetCounter, _app.version, _app.token];
    }
    [_app searchGroups:makeOffset queryString:queryString :^(NSMutableArray * _Nonnull groups) {
        foundListData = groups;
        dispatch_async(dispatch_get_main_queue(), ^{
            loadedCountResults.title = [NSString stringWithFormat:@"%li", [foundListData count]];
            [foundList reloadData];
        });
    }];
}



- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    MyTableRowView *rowView = [[MyTableRowView alloc]init];
    return rowView;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([foundListData count]>0){
        return [foundListData count];
    }
    return 0;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([foundListData count]>0){
//        cell.userStatus.stringValue =foundListData[row][@"status"];
//        [cell.userStatus setFont:[NSFont systemFontOfSize:12 weight:NSFontWeightRegular]];
        if(searchType.selectedSegment==1){
            CustomSearchCell *cell = (CustomSearchCell*)[tableView makeViewWithIdentifier:@"MainCell" owner:self];
         
            if( [foundListData[row][@"blacklisted"] intValue] ||  [foundListData[row][@"blacklisted_by_me"] intValue]) {
                cell.blacklisted.hidden=NO;
            }else{
                cell.blacklisted.hidden=YES;
            };
            [cell.userStatus setAllowsEditingTextAttributes:YES];
            cell.lastSeen.stringValue = foundListData[row][@"last_seen"];
            cell.country.stringValue = foundListData[row][@"country"];
            cell.verified.hidden = ![foundListData[row][@"verified"] intValue];
            cell.age.stringValue = foundListData[row][@"bdate"];
            cell.city.stringValue = foundListData[row][@"city"];
            cell.name.stringValue = foundListData[row][@"full_name"];
            cell.photo.wantsLayer=YES;
            cell.photo.layer.cornerRadius=60/2;
            cell.photo.layer.masksToBounds=YES;
            //cell.fieldId.stringValue = [NSString stringWithFormat:@"%@", foundListData[row][@"id"]];
            [_stringHighlighter highlightStringWithURLs:foundListData[row][@"status"] Emails:YES fontSize:12 completion:^(NSMutableAttributedString *highlightedString) {
                cell.userStatus.attributedStringValue = highlightedString;
            }];
            
            
            [cell.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", foundListData[row][@"user_photo"]]] placeholderImage:nil options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {

//                NSImageRep *rep = [[image representations] objectAtIndex:0];
                NSSize imageSize = NSMakeSize(60,60);
                image.size=imageSize;
                [cell.photo setImage:image];
            }];
            
            if([foundListData[row][@"online"] intValue]){
                [cell.status setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
            }else{
                [cell.status setImage:[NSImage imageNamed:NSImageNameStatusNone]];
            }
            return cell;
        }
        else if(searchType.selectedSegment==0){
            SearchGroupsCellView *cell = (SearchGroupsCellView*)[tableView makeViewWithIdentifier:@"SearchGroupsCellView" owner:self];
            cell.groupAvatar.wantsLayer=YES;
            cell.groupAvatar.layer.cornerRadius=60/2;
            cell.groupAvatar.layer.masksToBounds=YES;
            cell.groupName.stringValue = foundListData[row][@"name"];
            cell.groupCountry.stringValue = foundListData[row][@"country"];
            [cell.groupAvatar sd_setImageWithURL:[NSURL URLWithString:foundListData[row][@"photo"]] placeholderImage:nil options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                NSSize imSize=NSMakeSize(60, 60);
                image.size=imSize;
                [cell.groupAvatar setImage:image];
            }];
            return cell;
        }
    }
    return nil;
}
@end
