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
#import <QuartzCore/QuartzCore.h>
#import <Quartz/Quartz.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSString+MyNSStringCategory.h"
#import "HTMLReader.h"
#import <DZReadability/DZReadability.h>
@interface FavoritesUsersViewController ()<NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate>
typedef void(^OnFaveUsersGetComplete)(NSMutableArray*faveUsers);
- (void)getFaveUsers:(OnFaveUsersGetComplete)completion;
@end

@implementation FavoritesUsersViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    favesUsersList.delegate=self;
    favesUsersList.dataSource=self;
    searchBar.delegate=self;
    favesUsersData = [[NSMutableArray alloc]init];
    favesUsersDataCopy = [[NSMutableArray alloc]init];
    selectedUsers = [[NSMutableArray alloc]init];
    favesUsersTemp = [[NSMutableArray alloc]init];
    restoredUserIDs = [[NSMutableArray alloc]init];
    _app = [[appInfo alloc]init];
    loadFromUserGroup=NO;
    [self loadFavesUsers:NO :NO];
    stringHighlighter = [[StringHighlighter alloc]init];
    [[favesScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(VisitUserPageFromFavoriteUsers:) name:@"VisitUserPageFromFavoriteUsers" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(createGroupFromSelectedUsers:) name:@"CreateGroupFromSelectedFavesUsers" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CreateFavesGroup:) name:@"CreateFavesGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddFavesUserGroupsItemIntoGroup:) name:@"AddFavesUserGroupsItemIntoGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddFavesUserToBanOrUnbun:) name:@"AddFavesUserToBanOrUnbun" object:nil];
    offsetLoadFaveUsers=0;
    moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    [favesUserGroups removeAllItems];
//    NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:favesScrollView.frame xRadius:4 yRadius:4];
    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.cornerRadius=4;
    layer.borderWidth=1;
    layer.borderColor=[[NSColor colorWithWhite:0.8 alpha:1]CGColor];
    favesScrollView.wantsLayer = TRUE;
    favesScrollView.layer = layer;
//    [self loadURL];
    
   
}
- (void)AddFavesUserToBanOrUnbun:(NSNotification*)obj{
    NSLog(@"%@", obj);
    if([obj.userInfo[@"bannedStatus"] intValue]){
        NSLog(@"UNBANNED");
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/account.unbanUser?user_id=%@&v=%@&access_token=%@", favesUsersData[[obj.userInfo[@"row"] intValue]][@"id"], _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *unbanUserResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
            NSLog(@"%@", unbanUserResponse);
            dispatch_async(dispatch_get_main_queue(), ^{
                favesUsersData[[obj.userInfo[@"row"] intValue]][@"blacklisted_by_me"] = @0;
                //            NSLog(@"%@", favesUsersData[[obj.userInfo[@"row"] intValue]]);
                [favesUsersList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[obj.userInfo[@"row"] intValue]]  columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            });
            
        }]resume];
    }else{
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/account.banUser?user_id=%@&v=%@&access_token=%@", favesUsersData[[obj.userInfo[@"row"] intValue] ][@"id"] ,_app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *addToBanResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
            NSLog(@"%@", addToBanResponse);
            dispatch_async(dispatch_get_main_queue(), ^{
    //            [favesUsersList deselectRow:[favesUsersData indexOfObject:i]];
                favesUsersData[[obj.userInfo[@"row"] intValue]][@"blacklisted_by_me"] = @1;
    //            NSLog(@"%@", favesUsersData[[obj.userInfo[@"row"] intValue]]);
                [favesUsersList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:[obj.userInfo[@"row"] intValue]]  columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            });
        }]resume];
    }
}
- (void)loadURL{
//    [[[ DZReadability alloc]initWithURLToDownload:[NSURL URLWithString:@"https://soundcloud.com/alaplay/barbaraboeing"]  options:nil completionHandler:^(DZReadability *sender, NSString *content, NSError *error) {
//        if(!error) {
//            NSLog(@"%@", content);
//        }else{
//            NSLog(@"ERROR");
//        }
//    }] start];
    
//    SBJson5ValueBlock block = ^(id v, BOOL *stop) {
//        BOOL isDict = [v isKindOfClass:[NSDictionary class]];
//        NSLog(@"%@", isDict ? v : @"");
//    };
//    SBJson5ErrorBlock eh = ^(NSError* err) {
//        NSLog(@"OOPS: %@", err);
//        exit(1);
//    };
//    id parser = [SBJson5Parser parserWithBlock:block errorHandler:eh];
//    id parser2 = [SBJson5Parser unwrapRootArrayParserWithBlock:block errorHandler:eh];
    NSString *url;
    url = @"https://www.youtube.com/watch?v=WIrIxbah_80";
//    url = @"https://soundcloud.com/alaplay/barbaraboeing";
    NSString *dataBody = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
    HTMLDocument *doc = [HTMLDocument documentWithString:dataBody];
    NSArray *meta = [doc nodesMatchingSelector:@"meta"];
//    NSLog(@"%@", dataBody);
     for(HTMLElement *s in meta){
         NSDictionary *attrs = [s attributes];
//        NSLog(@"Meta element: %@",[s attributes]);
         if([attrs[@"property"] containsString:@"og:site_name"]){
             NSLog(@"Site name:%@", attrs[@"content"]);
         }
         else if([attrs[@"property"] containsString:@"og:title"]){
             NSLog(@"Title:%@", attrs[@"content"]);
         }
         else if([attrs[@"property"] containsString:@"og:description"]){
             NSLog(@"Description:%@", attrs[@"content"]);
         }
         else if([attrs[@"property"] isEqualToString:@"og:image"]){
             NSLog(@"Image:%@", attrs[@"content"]);
         }
//          [parser2 parse:[ [[s textContent] stringByReplacingOccurrencesOfString:@"\n" withString:@""] dataUsingEncoding:NSUTF8StringEncoding]];
     };
}
- (void)viewDidAppear{
    [self loadFavesUserGroups];
    [self loadUserFavesGroupsPrefs];
    
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
            if([favesUsersData count] > 0 && !loadFromUserGroup && !loading){
                [self loadFavesUsers:NO :YES];
            }
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

- (void)CreateFavesGroup:(NSNotification*)obj{
    NSLog(@"New group name %@", obj.userInfo[@"group_name"]);
    userFavesNewGroupName = obj.userInfo[@"group_name"];
    if([obj.userInfo[@"only_create"] intValue]){
        [self storeNewCreatedGroupsOnly];
    }else{
        [self storeNewCreatedGroupWithItems];
    }
}
- (void)AddFavesUserGroupsItemIntoGroup:(NSNotification*)notification{
    [self addNewItemsInToSelectedUserGroup:notification.userInfo[@"group_name"]];
}
- (void)VisitUserPageFromFavoriteUsers:(NSNotification *)notification{
    NSInteger row = [notification.userInfo[@"row"] intValue];
    NSLog(@"%@", favesUsersData[row]);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/id%@", favesUsersData[row][@"id"]]]];
}
- (void)createGroupFromSelectedUsers:(NSNotification *)notification{
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Fifth" bundle:nil];
    CreateFavesGroupController *contr = [story instantiateControllerWithIdentifier:@"CreateFavesGroupView"];
    contr.onlyCreate=NO;
    [self presentViewControllerAsSheet:contr];
    
}

- (void)loadUserFavesGroupsPrefs{
    [userFavesGroupsPrefs removeItemAtIndex:1];
    [userFavesGroupsPrefs removeItemAtIndex:1];
    [userFavesGroupsPrefs insertItemWithTitle:@"Remove group" atIndex:1];
    [userFavesGroupsPrefs insertItemWithTitle:@"Create group" atIndex:1];
   
}
- (void)loadFavesUserGroups{
    [self readItemsInUserFavesGroup];
    //    NSLog(@"%@", userGroupsNames);
}
- (IBAction)userFavesGroupsPrefsSelect:(id)sender {
    if([userFavesGroupsPrefs indexOfSelectedItem]==1){
        NSStoryboard *story = [NSStoryboard storyboardWithName:@"Fifth" bundle:nil];
        CreateFavesGroupController *contr = [story instantiateControllerWithIdentifier:@"CreateFavesGroupView"];
        contr.onlyCreate=YES;
        [self presentViewControllerAsSheet:contr];
        
    }else if([userFavesGroupsPrefs indexOfSelectedItem]==2){
        [self deleteUserFavesGroup];
    }
}
- (IBAction)selectUserFavesGroup:(id)sender {
  
    [restoredUserIDs removeAllObjects];
    if([[[favesUserGroups selectedItem]title] isEqual:@"No group"]){
          loadFromUserGroup=NO;
        [self loadFavesUsers:NO :NO];
    }else{
        loadFromUserGroup=YES;
        NSFetchRequest *fetchGroupsRequest = [NSFetchRequest fetchRequestWithEntityName:@"VKFavesUserGroupsNames"];
        [fetchGroupsRequest setReturnsObjectsAsFaults:NO];
        [fetchGroupsRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@", [[favesUserGroups selectedItem]title]]];
        NSArray *fetchedGroups = [moc executeFetchRequest:fetchGroupsRequest error:nil];
        for(NSManagedObject *i in fetchedGroups ){
            for(NSManagedObject *a in [[i valueForKey:@"userFavesGroups"] allObjects]){
                if([[[i valueForKey:@"userFavesGroups"] allObjects] count]>0){
//                    NSLog(@"%@", [a valueForKey:@"id"]);
                    [restoredUserIDs addObject:[a valueForKey:@"id"]];
                }
            }
        }
        [self loadFavesUsers:NO :NO];
//        NSLog(@"%@", restoredUserIDs);
    }
}



- (void)readItemsInUserFavesGroup{
    [favesUserGroups removeAllItems];
    NSMutableArray *userGroupsNames = [[NSMutableArray alloc]init];
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
        [userGroupsNames addObject:i[@"name"]];
        [favesUserGroupsMenu addItem:item];
    }
    [favesUserGroups setMenu:favesUserGroupsMenu];
    dispatch_after(6, dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"getUserFavesGroupsForContextMenu" object:nil userInfo:@{@"groups":[userGroupsNames mutableCopy]}];
    });

}
- (void)storeNewCreatedGroupWithItems{
   
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
- (void)storeNewCreatedGroupsOnly{
    NSEntityDescription *entityDesc1 = [NSEntityDescription entityForName:@"VKFavesUserGroupsNames" inManagedObjectContext:moc];
    NSError *saveError;
    NSManagedObject *object = [[NSManagedObject alloc]initWithEntity:entityDesc1 insertIntoManagedObjectContext:moc];
    [object setValue:userFavesNewGroupName forKey:@"name"];
    if(![moc save:&saveError]){
        NSLog(@"Error save items in group.");
    }else{
        NSLog(@"New user group %@ successfully created", userFavesNewGroupName);
        [self loadFavesUserGroups];
    }
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
- (void)addNewItemsInToSelectedUserGroup:(NSString*)groupName{
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext=moc;
  
    [temporaryContext performBlock:^{
        NSError *saveError;
        NSError *readError;
        NSMutableArray *allItemsInGroup = [[NSMutableArray alloc]init];
        NSFetchRequest *fetchGroupsNamesRequest = [ NSFetchRequest fetchRequestWithEntityName:@"VKFavesUserGroupsNames"];
        [fetchGroupsNamesRequest setPredicate:[NSPredicate predicateWithFormat:@"name == %@",groupName]];
        
        NSArray *fetechedGroupsNames = [temporaryContext executeFetchRequest:fetchGroupsNamesRequest error:&readError];
        for(NSManagedObject *group in fetechedGroupsNames){
            for(NSManagedObject *oldItem in [group valueForKey:@"userFavesGroups"]){
                [allItemsInGroup addObject:oldItem];
            }
            for(NSDictionary *newItem in [favesUsersData objectsAtIndexes:[favesUsersList selectedRowIndexes]]){
                if(![allItemsInGroup containsObject:newItem[@"id"]]){
                    NSEntityDescription *entityDesc2 = [NSEntityDescription entityForName:@"VKFavesUserItemsInGroup" inManagedObjectContext:temporaryContext];
                    NSManagedObject *newObjectWithGroupItem = [[NSManagedObject alloc]initWithEntity:entityDesc2 insertIntoManagedObjectContext:temporaryContext];
                    [newObjectWithGroupItem setValue:[NSString stringWithFormat:@"%@",newItem[@"id"]] forKey:@"id"];
                    [allItemsInGroup addObject:newObjectWithGroupItem];
                }
            }
            
            [group setValue:[NSSet setWithArray:allItemsInGroup] forKey:@"userFavesGroups"];
            if(![temporaryContext save:&saveError]){
                NSLog(@"Error save new items in group.");
            }else{
               
            }
            [moc performBlockAndWait:^{
                NSError *error=nil;
                if (![moc save:&error]) {
                    
                }else{
                     NSLog(@"New items in group %@ successfully saved.", groupName);
                }
            }];
        }
    }];
}



- (void)getFaveUsers:(OnFaveUsersGetComplete)completion{
    __block void (^getFavesUsersBlock)();
    getFavesUsersBlock = ^void(){
        if( loadFromUserGroup){
            completion(restoredUserIDs);
            dispatch_async(dispatch_get_main_queue(), ^{
                totalCount = [restoredUserIDs count];
                totalCountLabel.title = [NSString stringWithFormat:@"%li", totalCount];
            });
        }else{
            
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/fave.getUsers?count=50&offset=%li&v=%@&access_token=%@", offsetLoadFaveUsers, _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if(data){
                    NSDictionary *getFavesUsersResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if(getFavesUsersResponse[@"error"]){
                        NSLog(@"%@:%@", getFavesUsersResponse[@"error"][@"error_code"], getFavesUsersResponse[@"error"][@"error_msg"]);
                        NSLog(@"Trying send get faves users info request  again.");
                        dispatch_after(3, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                              getFavesUsersBlock();
                        });
                      
                        
                    }else{
                        totalCount = [getFavesUsersResponse[@"response"][@"count"] intValue];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            totalCountLabel.title = [NSString stringWithFormat:@"%li", totalCount];
                        });
                        [favesUsersTemp removeAllObjects];
                        for(NSDictionary *i in getFavesUsersResponse[@"response"][@"items"]){
                            [favesUsersTemp addObject:i[@"id"]];
                        }
                        completion(favesUsersTemp);
                    }
                }
            }]resume];
        }
    };
    getFavesUsersBlock();
    
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

- (IBAction)showFullInfo:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Third" bundle:nil];
    FullUserInfoPopupViewController *popuper = [story instantiateControllerWithIdentifier:@"profilePopup"];
//    NSPoint mouseLoc = [NSEvent mouseLocation];
//    int y = mouseLoc.y;
    NSView *parentCell = [sender superview];
    NSInteger row = [favesUsersList rowForView:parentCell];
//    CGRect rect=CGRectMake(0, y, 0, 0);
    popuper.receivedData = favesUsersData[row];
    [popuper setToViewController];
//    [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:favesUsersList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
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
   
    __block NSMutableDictionary *object;
    __block void (^loadFavesBlock)(BOOL);
    loadFavesBlock = ^void(BOOL offset){
        loading=YES;
        [progressSpin startAnimation:self];
        if(offset){
            offsetLoadFaveUsers=offsetLoadFaveUsers+50;
        }else{
//            [favesUsersList scrollToBeginningOfDocument:self];
            [favesUsersData removeAllObjects];
//            [favesUsersList reloadData];
            offsetLoadFaveUsers=0;
            offsetCounter=0;
        }
        // __block NSInteger startInsertRowIndex = [favesUsersData count];
        
            [self getFaveUsers:^(NSMutableArray *faveUsers) {
//                NSLog(@"%@", [faveUsers componentsJoinedByString:@","]);
                if([faveUsers count]>0 && offsetCounter <= [favesUsersData count]){
                    [[_app.session dataTaskWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@&fields=photo_100,photo_200,photo_200_orig,country,city,online,last_seen,status,bdate,books,about,sex,site,contacts,verified,music,schools,education,quotes,blacklisted,domain,blacklisted_by_me,relation&access_token=%@&v=%@" , [faveUsers componentsJoinedByString:@","],  _app.token, _app.version]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        if(data){
//                            if (error){
//                                NSLog(@"Check your connection");
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    [progressSpin stopAnimation:self];
//                                });
//                                return;
//                            }
//                            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
//                                
//                                NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
//                                if (statusCode != 200) {
//                                    NSLog(@"dataTask HTTP status code: %lu", statusCode);
//                                    dispatch_async(dispatch_get_main_queue(), ^{
//                                        [progressSpin stopAnimation:self];
//                                    });
//                                    return;
//                                }
//                                else{
//                                }
//                            }
                            
                            NSDictionary *getUsersResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            //NSLog(@"%@", getUsersResponse);
                            if (getUsersResponse[@"error"]){
                                NSLog(@"%@:%@", getUsersResponse[@"error"][@"error_code"], getUsersResponse[@"error"][@"error_msg"]);
                                NSLog(@"Trying send faves users request  again.");
                                if([favesUsersData count]<15 && totalCount>=15 && offsetCounter < totalCount && [restoredUserIDs count]==0 && !loading){
                                    dispatch_after(1, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                        loadFavesBlock(YES);
                                    });
                                }
                            }
                            else{
                                NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:searchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
                     
                                
                                if(getUsersResponse[@"response"]){
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
                                        object = [NSMutableDictionary dictionaryWithDictionary:@{@"id":a[@"id"], @"full_name":fullName, @"city":city, @"status":status, @"user_photo":photo, @"user_photo_big":photoBig,@"country":countryName, @"bdate":bdate, @"online":online, @"last_seen":last_seen, @"sex":sex, @"site":site, @"mobile":mobilePhone, @"about":about, @"books":books, @"music":music, @"schools":schools, @"university_name":education, @"quotes":quotes, @"deactivated":deactivated, @"blacklisted":[NSNumber numberWithInt:blacklisted], @"blacklisted_by_me":[NSNumber numberWithInt:blacklisted_by_me], @"relation":relation, @"domain":domain,@"verified":verified}];
                                        
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
                                                        if([a[@"sex"] intValue]==1 || [a[@"sex"] intValue]==2){
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
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //NSLog(@"%@", favesUsersData);
                                //NSLog(@"%li", [favesUsersData count]);
                                //totalCountLabel.title = [NSString stringWithFormat:@"%li", totalCount];
                                if([favesUsersData count]>0 && offsetLoadFaveUsers<totalCount){
                                    NSLog(@"BAD END");
                                    loadedCount.title=[NSString stringWithFormat:@"%lu",offsetCounter];
                                    [favesUsersList reloadData];
                                    [progressSpin stopAnimation:self];
                                    loading=NO;
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"banAndUnbanUserInFaves" object:nil userInfo:@{@"favesUsersData":favesUsersData}];
                                    if([favesUsersData count]<15 && totalCount>=15 && offsetCounter < totalCount && [restoredUserIDs count]==0 && !loading){
                                        dispatch_after(1, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                            loadFavesBlock(YES);
                                        });
                                    }
                                }
                            });
                        }
                        else{
                            NSInteger statusCode = ((NSHTTPURLResponse *)response).statusCode;
                            if (!error && statusCode == 200) {
                                // even fancier code goes here
                            } else {
                                // omg!!!!!!!!!
                                NSLog(@"Server error code on Faves users request:%li", statusCode);
//                                if(![favesUsersData count]){
//                                    dispatch_after(2, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                        loadFavesBlock(NO);
//                                        
//                                    });
//                                   
//                                }
//                                else{
//                                    dispatch_after(2, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                        loadFavesBlock(YES);
//                                        
//                                    });
//                                }
                            }
                        }
                    }]resume];
                }else{
                    dispatch_async(dispatch_get_main_queue(),^{
                        [progressSpin stopAnimation:self];
                        [favesUsersList reloadData];
                    });
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
    if ([favesUsersData count]==offsetCounter && [favesUsersData lastObject] && row <= [favesUsersData count]) {
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
        cell.photo.layer.masksToBounds=YES;
        cell.verified.hidden=![favesUsersData[row][@"verified"] intValue];
        cell.blacklisted.hidden = ![favesUsersData[row][@"blacklisted_by_me"] intValue];
        if([favesUsersData[row][@"deactivated"] isEqual:@""]){
            cell.deactivatedStatus.hidden=YES;
        }else{
            cell.deactivatedStatus.stringValue = favesUsersData[row][@"deactivated"];
            cell.deactivatedStatus.hidden=NO;
        }

         [stringHighlighter highlightStringWithURLs:favesUsersData[row][@"status"]  Emails:YES fontSize:12 completion:^(NSMutableAttributedString *highlightedString) {
             cell.status.attributedStringValue = highlightedString;
         }];

        
        [cell.photo sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", favesUsersData[row][@"user_photo"]]] placeholderImage:nil options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            NSImageRep *rep = [[image representations] objectAtIndex:0];
            NSSize imageSize = NSMakeSize(rep.pixelsWide, rep.pixelsHigh);
            image.size=imageSize;
            [cell.photo setImage:image];
        }];


       
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
