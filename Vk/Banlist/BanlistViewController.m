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
#import <SDWebImage/UIImageView+WebCache.h>
#import "MyTableRowView.h"

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
    NSArray *dateFilterItems = @[@"last seen", @"all", @" > 10 days", @"> month"];
    [[banListScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    [dateFilterOptionsPopup removeAllItems];
    [dateFilterOptionsPopup addItemsWithTitles:dateFilterItems];
    value = [[NSMutableArray alloc]init];
    selectedUsers = [[NSMutableArray alloc]init];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VisitUserPageFromBanlist:) name:@"VisitUserPageFromBanlist" object:nil];
    _stringHighlighter = [[StringHighlighter alloc]init];
//     NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:favesScrollView.frame xRadius:4 yRadius:4];
    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.cornerRadius=4;
    layer.borderWidth=1;
    layer.borderColor=[[NSColor colorWithWhite:0.8 alpha:1]CGColor];
    banList.enclosingScrollView.wantsLayer = TRUE;
    banList.enclosingScrollView.layer = layer;
    [self setFlatButtonStyle];
    banlistStatBut.font=[NSFont fontWithName:@"Pe-icon-7-stroke" size:22];
//    button = [[SYFlatButton alloc]init];
    NSString *s = @"\U0000E64B";
    banlistStatBut.title = s;
}

-(void)setFlatButtonStyle{
    NSLog(@"%@", self.view.subviews[0].subviews[0].subviews);
    for(NSArray *v in self.view.subviews[0].subviews[0].subviews){
        if([v isKindOfClass:[SYFlatButton class]]){
            SYFlatButton *button = (SYFlatButton*)v;
            [button simpleButton:button];
        }
    }
}
- (void)VisitUserPageFromBanlist:(NSNotification*)notification{
    NSInteger row = [notification.userInfo[@"row"] intValue];
    NSLog(@"%@", banlistData[row]);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/id%@",banlistData[row][@"id"]]]];
}
- (void)viewDidAppear{
    
    [self loadBanlist:NO :NO];
    
    
}
- (IBAction)showUserFullInfo:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Third" bundle:nil];
    FullUserInfoPopupViewController *popuper = [story instantiateControllerWithIdentifier:@"profilePopup"];
//    NSPoint mouseLoc = [NSEvent mouseLocation];
    //    int x = mouseLoc.x;
//    int y = mouseLoc.y;
    //    int scrollPosition = [[scrollView contentView] bounds].origin.y+120;
    
    NSView *parentCell = [sender superview];
    NSInteger row = [banList rowForView:parentCell];
//    CGRect rect=CGRectMake(0, y, 0, 0);
    
    popuper.receivedData = banlistData[row];

    
    [popuper setToViewController];
//    [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:banList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
    
}
- (IBAction)showBanlistStat:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
    FriendsStatController *controller = [story instantiateControllerWithIdentifier:@"FriendsStatController"];
    controller.receivedData = @{@"data":banlistData};
    [self presentViewController:controller asPopoverRelativeToRect:banlistStatBut.frame ofView:self.view.subviews[0] preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
}

- (void)searchFieldDidStartSearching:(NSSearchField *)sender{
    searchMode=YES;
    [self loadSearchBanlist];
}
- (void)searchFieldDidEndSearching:(NSSearchField *)sender{
    searchMode=NO;
    banlistData = banlistDataCopy;
    [banList reloadData];
}
- (void)viewDidScroll:(NSNotification *)notification{
    if([notification.object isEqual:banListClipView]){
        NSInteger scrollOrigin = [[banListScrollView contentView]bounds].origin.y+NSMaxY([banListScrollView visibleRect]);
        //    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
        NSInteger boundsHeight = banList.bounds.size.height;
        //    NSInteger frameHeight = subscribersList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            //Refresh here
            //         NSLog(@"The end of table");
            if(!searchMode && [banlistData count]!=0  && !loading && offsetLoadBanlist < totalCountBanned){
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
        case 1:
            [self loadAllDates];
            break;
        case 2:
            [self loadEqualOrMoreThenDays];
            break;
        case 3:
             [self loadEqualOrMoreThenMonthLastSeen];
            break;
    }
    
}
- (void)loadAllDates{
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
- (BOOL)checkIfMoreOrEqualDays:(NSString*)date{
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"dd.MM.yyyy HH:mm"];
    NSDate *userLastSeenDate = [NSDate dateWithTimeIntervalSince1970:[date intValue]];
    
    
    NSInteger tenDaysInSeconds = 60*60*24;
    NSTimeInterval currentDateInterval = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval userLastSeenDateInterval = [userLastSeenDate timeIntervalSince1970];
    NSTimeInterval tenDaysInterval = (currentDateInterval - userLastSeenDateInterval)/tenDaysInSeconds;
    NSInteger tenDays = [[NSString stringWithFormat:@"%.0f", tenDaysInterval]intValue];
//    NSLog(@"%li", tenDays);
//    NSLog(@"%.f", userLastSeenDateInterval);
//    NSLog(@"%@", userLastSeenDate);
//    NSLog(@"%f", currentDateInterval);
    if(tenDays >= 10){
        return YES;
    }
    
    return NO;
}
- (BOOL)checkIfMoreOrEqualMonth:(id)date{
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
- (void)loadEqualOrMoreThenDays{
    banlistDataCopy = [[NSMutableArray alloc]initWithArray:banlistData];
    [banlistData removeAllObjects];
    for(NSDictionary *i in banlistDataCopy){
//        NSLog(@"%@", [i[@"last_seen"] componentsSeparatedByString:@"."]);
        if([self checkIfMoreOrEqualDays:[NSString stringWithFormat:@"%@",i[@"timestamp"]]]){
            [banlistData addObject:i];
            
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [banList reloadData];
    });
}
- (void)loadEqualOrMoreThenMonthLastSeen{
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
- (void)loadSearchBanlist{
   
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
- (void)setFiltersDisabled{
    filterActive.enabled=NO;
    filterMen.enabled=NO;
    filterActive.enabled=NO;
    filterWomen.enabled=NO;
    filterOnline.enabled=NO;
    filterOffline.enabled=NO;
    filterInUserBlacklist.enabled=NO;
}
- (void)setFiltersEnabled{
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
    
        [banList scrollToBeginningOfDocument:self];
        [self loadBanlist:NO :NO];
    
}
- (IBAction)filterMenAction:(id)sender {
//     [self setFiltersDisabled];
    
        [banList scrollToBeginningOfDocument:self];
        [self loadBanlist:NO :NO];
}

- (IBAction)FriendsFilterOfflineAction:(id)sender {
//     [self setFiltersDisabled];
    
        [banList scrollToBeginningOfDocument:self];
        [self loadBanlist:NO :NO];
    
}
- (IBAction)FriendsFilterOnlineAction:(id)sender {
//     [self setFiltersDisabled];
    
        [banList scrollToBeginningOfDocument:self];
        [self loadBanlist:NO :NO];
}
- (IBAction)FriendsFilterActiveAction:(id)sender {
//     [self setFiltersDisabled];
    
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

- (void)loadBanlist:(BOOL)searchByName :(BOOL)makeOffset{
    __block void(^getBannedBlock)(BOOL);
    
    getBannedBlock = ^void(BOOL offset){
        loading=YES;
        searchMode=NO;
        [progressSpin startAnimation:self];
     
        NSDictionary *filters =@{@"women":[NSNumber numberWithInteger:filterWomen.state],@"men":[NSNumber numberWithInteger:filterMen.state],@"online":[NSNumber numberWithInteger:filterOnline.state], @"offline":[NSNumber numberWithInteger:filterOffline.state], @"active":[NSNumber numberWithInteger:filterActive.state], @"blacklist":[NSNumber numberWithInteger:filterInUserBlacklist.state]};
  
        [_app getBannedUsersInfo:filters :offset :^(NSMutableArray * _Nonnull bannedUsersInfo, NSInteger offsetCounterResult, NSInteger totalBannedResult, NSInteger bannedUsersListCount, NSInteger offsetBanlistLoadResult) {
            banlistData = bannedUsersInfo;
            totalCountBanned = totalBannedResult;
            offsetLoadBanlist = offsetBanlistLoadResult;
            
//            if([bannedUsersInfo count]>0  && offsetCounterResult <= bannedUsersListCount ){
                dispatch_async(dispatch_get_main_queue(), ^{
                    loading=NO;
//                    if (bannedUsersListCount>0 && offsetBanlistLoadResult < totalBannedResult){
                        [progressSpin stopAnimation:self];
                        loadedCount.title=[NSString stringWithFormat:@"%li", bannedUsersListCount];
                        totalCount.title = [NSString stringWithFormat:@"%li", totalBannedResult];
                        [banList reloadData];
                        
                        dispatch_after(2, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            if( (bannedUsersListCount<15 && totalBannedResult>=15 && offsetBanlistLoadResult < totalBannedResult && !loading)){
                                NSLog(@"OFFSET LOAD");
                                getBannedBlock(YES);
                                
                            }
                        });
//                    }
                });
//            }
//            else{
//                
//            }
            
            NSLog(@"OFFSET BANLIST %li", offsetBanlistLoadResult);
            NSLog(@"OFFSET BANLIST COUNTER %li", offsetCounterResult);
        }];
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
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    MyTableRowView *rowView = [[MyTableRowView alloc]init];
    return rowView;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [banlistData count];
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([banlistData count]>0 && [banlistData lastObject] && row <= [banlistData count]){
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
       
       
//        }else{
//                    cell.status.stringValue = banlistData[row][@"status"];
//        }
//        cell.status.stringValue = banlistData[row][@"status"];
        cell.deactivated.stringValue = banlistData[row][@"deactivated"];
        cell.sex.stringValue = banlistData[row][@"sex"];

        cell.userPhoto.wantsLayer=YES;
        cell.userPhoto.layer.masksToBounds=YES;
        cell.userPhoto.layer.cornerRadius=80/2;
        
        [_stringHighlighter highlightStringWithURLs:banlistData[row][@"status"] Emails:YES fontSize:12 completion:^(NSMutableAttributedString *highlightedString) {
            cell.status.attributedStringValue=highlightedString;
          
        }];
        
        
        [cell.userPhoto sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", banlistData[row][@"user_photo"]]]  placeholderImage:nil options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
     
            
        } completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            NSImageRep *rep = [[image representations] objectAtIndex:0];
            NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
            image.size=imageSize;
            [cell.userPhoto setImage:image];
        }];

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
