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
#import "CreateFavesGroupController.h"
@interface FavoritesUsersViewController ()<NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate>
typedef void(^OnFaveUsersGetComplete)(NSMutableArray*faveUsers);
- (void)getFaveUsers:(OnFaveUsersGetComplete)completion;
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
    cachedImage = [[NSMutableDictionary alloc]init];
    cachedStatus = [[NSMutableDictionary alloc]init];
    restoredUserIDs = [[NSMutableArray alloc]init];
    _app = [[appInfo alloc]init];
      [self loadFavesUsers:NO :NO];
    stringHighlighter = [[StringHighlighter alloc]init];
    [[favesScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(VisitUserPageFromFavoriteUsers:) name:@"VisitUserPageFromFavoriteUsers" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(createGroupFromSelectedUsers:) name:@"CreateGroupFromSelectedFavesUsers" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CreateFavesGroup:) name:@"CreateFavesGroup" object:nil];
    offsetLoadFaveUsers=0;
    moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    [favesUserGroups removeAllItems];
    
    [self loadFavesUserGroups];
    [self loadUserFavesGroupsPrefs];
}
- (void)VisitUserPageFromFavoriteUsers:(NSNotification *)notification{
    NSInteger row = [notification.userInfo[@"row"] intValue];
    NSLog(@"%@", favesUsersData[row]);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/id%@", favesUsersData[row][@"id"]]]];
}
-(void)createGroupFromSelectedUsers:(NSNotification *)notification{
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Fifth" bundle:nil];
    CreateFavesGroupController *contr = [story instantiateControllerWithIdentifier:@"CreateFavesGroupView"];
    [self presentViewControllerAsSheet:contr];
    
}
- (void)loadUserFavesGroupsPrefs{
    [userFavesGroupsPrefs removeItemAtIndex:1];
    [userFavesGroupsPrefs removeItemAtIndex:1];
    [userFavesGroupsPrefs insertItemWithTitle:@"Remove group" atIndex:1];
   
}
- (IBAction)userFavesGroupsPrefsSelect:(id)sender {
    [self deleteUserFavesGroup];
}

- (IBAction)selectUserFavesGroup:(id)sender {
    [restoredUserIDs removeAllObjects];
    if([[[favesUserGroups selectedItem]title] isEqual:@"No group"]){
        [self loadFavesUsers:NO :NO];
    }else{
        NSFetchRequest *fetchGroupsRequest = [NSFetchRequest fetchRequestWithEntityName:@"VKFavesUserGroupsNames"];
        [fetchGroupsRequest setReturnsObjectsAsFaults:NO];
        [fetchGroupsRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", [[favesUserGroups selectedItem]title]]];
        NSArray *fetchedGroups = [moc executeFetchRequest:fetchGroupsRequest error:nil];
        for(NSManagedObject *i in fetchedGroups ){
            for(NSManagedObject *a in [[i valueForKey:@"userFavesGroups"] allObjects]){
                //NSLog(@"%@", [a valueForKey:@"name"]);
                [restoredUserIDs addObject:[a valueForKey:@"id"]];
            }
        }
        [self loadFavesUsers:NO :NO];
    }
}
- (void)CreateFavesGroup:(NSNotification*)obj{
    NSLog(@"New group name %@", obj.userInfo[@"group_name"]);
    userFavesNewGroupName = obj.userInfo[@"group_name"];
    [self storeNewCreatedGroup];
}

- (void)loadFavesUserGroups{
    [favesUserGroups removeAllItems];
    NSMenuItem *item;
    NSMenu *favesUserGroupsMenu = [[NSMenu alloc]initWithTitle:@"Faves user groups menu"];
    item = [[NSMenuItem alloc]initWithTitle:@"No group" action:nil keyEquivalent:@""];
    [favesUserGroupsMenu insertItem:item atIndex:0];
    item = [NSMenuItem separatorItem];
    [favesUserGroupsMenu insertItem:item atIndex:1];
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext=moc;
    NSFetchRequest *fetchGroupsRequest = [NSFetchRequest fetchRequestWithEntityName:@"VKFavesUserGroupsNames"];
    [fetchGroupsRequest setReturnsObjectsAsFaults:NO];
    [fetchGroupsRequest setResultType:NSDictionaryResultType];
    NSArray *fetchedGroups = [moc executeFetchRequest:fetchGroupsRequest error:nil];
    for(NSDictionary *i in fetchedGroups){
        item = [[NSMenuItem alloc]initWithTitle:i[@"name"] action:NULL keyEquivalent:@""];
        [favesUserGroupsMenu addItem:item];
    }
    [favesUserGroups setMenu:favesUserGroupsMenu];
}
- (void)storeNewCreatedGroup{
   
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext=moc;
    [temporaryContext performBlock:^{
        NSEntityDescription *entityDesc1 = [NSEntityDescription entityForName:@"VKFavesUserGroupsNames" inManagedObjectContext:moc];
        //    NSError *saveError;
        //    NSError *saveError2;
        NSError *saveError3;
        NSMutableArray *objects = [[NSMutableArray alloc]init];
        
        NSManagedObject *object = [[NSManagedObject alloc]initWithEntity:entityDesc1 insertIntoManagedObjectContext:temporaryContext];
        [object setValue:userFavesNewGroupName forKey:@"name"];
        //    if(![moc save:&saveError]){
        //        NSLog(@"Error save name of repost group.");
        //    }else{
        //        NSLog(@"Repost name of group successfully saved.");
        for(NSDictionary *i in [favesUsersData objectsAtIndexes:[favesUsersList selectedRowIndexes]]){
            NSEntityDescription *entityDesc2 = [NSEntityDescription entityForName:@"VKFavesUserItemsInGroup" inManagedObjectContext:temporaryContext];
            NSManagedObject *object2 = [[NSManagedObject alloc] initWithEntity:entityDesc2 insertIntoManagedObjectContext:temporaryContext];
            [object2 setValue:[NSString stringWithFormat:@"%@",i[@"id"]] forKey:@"id"];
            // NSLog(@"%@",i[@"name"]);
            //[seet addObject:object2];
            [objects addObject:object2];
        }
        [object setValue:[NSSet setWithArray:objects] forKey:@"userFavesGroups"];
        if(![temporaryContext save:&saveError3]){
            NSLog(@"Error save items in group.");
        }
        [moc performBlockAndWait:^{
            NSError *error=nil;
            if (![moc save:&error]) {
                NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
                abort();
            }else{
                NSLog(@"Items in group successfully saved.");
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadListUserRepostGroups" object:nil];
                [self loadFavesUserGroups];
            }
        }];
    }];
}
- (void)soreItemsInGroup{
    
    
}
- (void)deleteUserFavesGroup{
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext=moc;
    [temporaryContext performBlock:^{
        NSFetchRequest *request = [ NSFetchRequest fetchRequestWithEntityName:@"VKFavesUserGroupsNames"];
        NSError *readError;
        NSError *deleteError;
        [request setReturnsObjectsAsFaults:NO];
        [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@",[[favesUserGroups selectedItem]title]]];
        NSArray *data = [temporaryContext executeFetchRequest:request error:&readError];
//        NSLog(@"%@", data);
        if(!readError){
            for(NSManagedObject *object in data){
                [temporaryContext deleteObject:object];
                if(![temporaryContext save:&deleteError]){
                    NSLog(@"Error delete epost group \"%@\"",  [[favesUserGroups selectedItem]title]);
                }
                [moc performBlockAndWait:^{
                    NSError *error=nil;
                    if(![moc save:&error]){
                        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
                        abort();
                    }else{
                        NSLog(@"Repost group \"%@\" successfully removed",  [[favesUserGroups selectedItem]title]);
                    }
                }];
            }
            [self loadFavesUserGroups];
        }else{
            NSLog(@"Error read repost groups.");
        }
    }];
}


- (void)viewDidAppear{
   
    
}
- (void)viewDidScroll:(NSNotification*)notification{
    if([notification.object isEqual:favesClipView]){
        NSInteger scrollOrigin = [[favesScrollView contentView]bounds].origin.y+NSMaxY([favesScrollView visibleRect]);
        //    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
        NSInteger boundsHeight = favesUsersList.bounds.size.height;
        //    NSInteger frameHeight = subscribersList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            //Refresh here
            //         NSLog(@"The end of table");
            if([favesUsersData count] > 0 && !loading){
                [self loadFavesUsers:NO :YES];
            }
        }
        //        NSLog(@"%ld", scrollOrigin);
        //        NSLog(@"%ld", boundsHeight);
        //    NSLog(@"%fld", frameHeight-300);
        //
    }

}

- (void)getFaveUsers:(OnFaveUsersGetComplete)completion{
    if([restoredUserIDs count]>0){
        completion(restoredUserIDs);
    }else{
        
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
                    completion(favesUsersTemp);
                }
            }
        }]resume];
    }
}
- (IBAction)showFavesUsersStatBut:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
    FriendsStatController *controller = [story instantiateControllerWithIdentifier:@"FriendsStatController"];
    controller.receivedData = @{@"data":favesUsersData};
    [self presentViewController:controller asPopoverRelativeToRect:showFavesUsersStatBut.frame ofView:self.view.subviews[0] preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
}
- (void)loadFavesUsersSearchList{
    
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
- (void)setButtonStyle:(id)button{
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
- (void)searchFieldDidStartSearching:(NSSearchField *)sender{
    [self loadFavesUsersSearchList];
}
- (void)searchFieldDidEndSearching:(NSSearchField *)sender{
    
    favesUsersData = favesUsersDataCopy;
    [favesUsersList reloadData];
}
- (void)cleanTable{
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
- (void)loadFavesUsers:(BOOL)searchByName :(BOOL)makeOffset{
    loading=YES;
    __block NSDictionary *object;
    __block void (^loadFavesBlock)(BOOL);
    loadFavesBlock = ^void(BOOL offset){
        [progressSpin startAnimation:self];
        if(offset){
            offsetLoadFaveUsers=offsetLoadFaveUsers+50;
        }else{
            [favesUsersData removeAllObjects];
            [favesUsersList reloadData];
            offsetLoadFaveUsers=0;
            offsetCounter=0;
        }
       
           
    
//        __block NSInteger startInsertRowIndex = [favesUsersData count];
        
        [self getFaveUsers:^(NSMutableArray *faveUsers) {
            if(faveUsers){
                [[_app.session dataTaskWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@&fields=photo_100,photo_200,photo_200_orig,country,city,online,last_seen,status,bdate,books,about,sex,site,contacts,verified,music,schools,education,quotes,blacklisted,domain,blacklisted_by_me,relation&access_token=%@&v=%@" , [faveUsers componentsJoinedByString:@","],  _app.token, _app.version]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
                        //NSLog(@"%@", getUsersResponse);
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
                            //NSString *phone;
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
                            NSString *verified;
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
                                    verified = a[@"verified"] && a[@"verified"]!=nil ? a[@"verified"] : @"";
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
                                    object = @{@"id":a[@"id"], @"full_name":fullName, @"city":city, @"status":status, @"user_photo":photo, @"user_photo_big":photoBig,@"country":countryName, @"bdate":bdate, @"online":online, @"last_seen":last_seen, @"sex":sex, @"site":site, @"mobile":mobilePhone, @"about":about, @"books":books, @"music":music, @"schools":schools, @"university_name":education, @"quotes":quotes, @"deactivated":deactivated, @"blacklisted":[NSNumber numberWithInt:blacklisted], @"blacklisted_by_me":[NSNumber numberWithInt:blacklisted_by_me], @"relation":relation, @"domain":domain,@"verified":verified};
                                    
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
                                    loading=NO;
                                    if(makeOffset){
//                                        [favesUsersList insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startInsertRowIndex+1, [favesUsersData count]-1)] withAnimation:NSTableViewAnimationSlideDown];
                                        [favesUsersList reloadData];
                                    }else{
                                        [favesUsersList reloadData];
                                    }
                                    [progressSpin stopAnimation:self];
                                    if([favesUsersData count]<15 && totalCount>=15 && offsetCounter < totalCount && !loading && [restoredUserIDs count]==0){
                                        loading=YES;
                                        loadFavesBlock(YES);
                                    }
                                }
                            });
                        }
                    }
                }]resume];
            }
        }];
    };
    if(makeOffset){
        loadFavesBlock(YES);
    }else{
        loadFavesBlock(NO);
    }
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row;
    if([[favesUsersList selectedRowIndexes]count]>0){
        row = [favesUsersList selectedRow];
        receiverDataForMessage = favesUsersData[row];
    }
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [favesUsersData count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if ([favesUsersData count]>0 && [favesUsersData lastObject] && favesUsersData[row]!=[NSNull null]) {
        
        FavesUsersCustomCell *cell=[[FavesUsersCustomCell  alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.country.stringValue = favesUsersData[row][@"country"];
        cell.city.stringValue = favesUsersData[row][@"city" ];
        cell.fullName.stringValue = favesUsersData[row][@"full_name"];
//        cell.status.stringValue = favesUsersData[row][@"status"];
        [cell.status setAllowsEditingTextAttributes:YES];
        cell.bdate.stringValue = favesUsersData[row][@"bdate"];
        cell.lastSeen.stringValue = favesUsersData[row][@"last_seen"];
        cell.sex.stringValue = favesUsersData[row][@"sex"];
//        NSSize imSize=NSMakeSize(80, 80);
        cell.photo.wantsLayer=YES;
        cell.photo.layer.cornerRadius=40;
        cell.photo.layer.masksToBounds=TRUE;
        cell.verified.hidden=![favesUsersData[row][@"verified"] intValue];
        if([favesUsersData[row][@"deactivated"] isEqual:@""]){
            cell.deactivatedStatus.hidden=YES;
        }else{
            cell.deactivatedStatus.stringValue = favesUsersData[row][@"deactivated"];
            cell.deactivatedStatus.hidden=NO;
        }
        if([cachedImage count]>0 && cachedImage[favesUsersData[row]] && cachedStatus[favesUsersData[row]]){
            cell.photo.image=cachedImage[favesUsersData[row]];
            cell.status.attributedStringValue = cachedStatus[favesUsersData[row]];
            
            
        }else{
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSAttributedString *attrStatusString = [stringHighlighter highlightStringWithURLs:favesUsersData[row][@"status"] Emails:YES fontSize:12];
                cachedStatus[favesUsersData[row]] = attrStatusString;
                NSImage *imagePhoto = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", favesUsersData[row][@"user_photo"]]]];
                NSImageRep *rep = [[imagePhoto representations] objectAtIndex:0];
                NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
                imagePhoto.size=imageSize;
                cachedImage[favesUsersData[row]] = imagePhoto;
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.status.attributedStringValue = attrStatusString;
//                    [cell.status setFont:[NSFont fontWithName:@"Helvetica" size:12]];
                    [cell.photo setImage:imagePhoto];
                });
            });
        }
        if([favesUsersData[row][@"online"] isEqual:@"1"]){
            [cell.online setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
            //cell.lastOnline.stringValue = @"";
        }
        else{
            //cell.lastOnline.stringValue = favesUsersData[row][@"last_seen"];
            [cell.online setImage:[NSImage imageNamed:NSImageNameStatusNone]];
        }
        return cell;
    }
    return nil;
}

@end
