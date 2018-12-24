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
#import "HTMLReader.h"
#import <DZReadability/DZReadability.h>
#import "AppDelegate.h"
#import <NSColor+HexString.h>
#import "MyTableRowView.h"
#import <BOString/BOString.h>

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
    moc = ((AppDelegate*)[[NSApplication sharedApplication ] delegate]).managedObjectContext;
    [favesUserGroups removeAllItems];
//    NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:favesScrollView.frame xRadius:4 yRadius:4];
    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.cornerRadius=4;
    layer.borderWidth=1;
    layer.borderColor=[[NSColor colorWithWhite:0.8 alpha:1]CGColor];
    favesScrollView.wantsLayer = TRUE;
    favesScrollView.layer = layer;
//    [self loadURL];
//    [favesUsersList setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
    [self setFlatButtonStyle];
    showFavesUsersStatBut.font=[NSFont fontWithName:@"Pe-icon-7-stroke" size:22];
    CDHandle = [[CDataHandler alloc]init];
    NSLog(@"Today date is: %@", CDHandle.today);
    NSString *statS = @"\U0000E64B";
    showFavesUsersStatBut.title = statS;
    
}
- (void)setFlatButtonStyle{
    NSLog(@"%@", self.view.subviews[0].subviews[0].subviews);
    for(NSArray *v in self.view.subviews[0].subviews[0].subviews){
        if([v isKindOfClass:[SYFlatButton class]]){
            SYFlatButton *button = [[SYFlatButton alloc]init];
//            [button simpleButton:(SYFlatButton*)v];
        }
    }
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
            if([favesUsersData count] > 0 && !loading && [restoredUserIDs count]==0){
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
//        NSLog(@"%@", userGroupsNames);
}
- (IBAction)userFavesGroupsPrefsSelect:(id)sender {
    if([userFavesGroupsPrefs indexOfSelectedItem]==1){
        NSStoryboard *story = [NSStoryboard storyboardWithName:@"Fifth" bundle:nil];
        CreateFavesGroupController *contr = [story instantiateControllerWithIdentifier:@"CreateFavesGroupView"];
        contr.onlyCreate=YES;
        contr.source=@"users";
        [self presentViewControllerAsSheet:contr];
        
    }else if([userFavesGroupsPrefs indexOfSelectedItem]==2){
        [self deleteUserFavesGroup];
    }
}
- (IBAction)selectUserFavesGroup:(id)sender {
  
    [restoredUserIDs removeAllObjects];
    if([[[favesUserGroups selectedItem]title] isEqual:@"No group"]){
        
//        restoredUserIDs = nil;
        [self loadFavesUsers:NO :NO];
    }else{
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
        NSLog(@"%@", restoredUserIDs);
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
        
//        for(NSDictionary *i in favesUsersData){
//            if(![i[@"deactivated"] isEqual:@""]){
//                counter++;
//                [favesUsersDataTemp addObject:i];
//            }
//            
//        }
//        //     NSLog(@"Start search %@", banlistDataTemp);
//        if([favesUsersDataTemp count]>0){
//            favesUsersData = favesUsersDataTemp;
//            [favesUsersList reloadData];
//        }
    }
//    else{
//        favesUsersData = favesUsersDataCopy;
//        [favesUsersList reloadData];
//    }
    [self loadFavesUsers:NO :NO];
    

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
- (void)getFaveUsers:(OnFaveUsersGetComplete)completion{
    
}

- (void)loadFavesUsers:(BOOL)searchByName :(BOOL)makeOffset{

    __block void (^loadFavesBlock)(BOOL);
    loadFavesBlock = ^void(BOOL offset){
        loading=YES;
        [progressSpin startAnimation:self];
        NSDictionary *filters = @{@"women":[NSNumber numberWithInteger:filterWomen.state],@"men":[NSNumber numberWithInteger:filterMen.state],@"online":[NSNumber numberWithInteger:filterOnline.state], @"offline":[NSNumber numberWithInteger:filterOffline.state], @"active":[NSNumber numberWithInteger:filterActive.state]};
        
        [_app getFavoriteUsersInfo:filters :offset data:[restoredUserIDs count ] ? restoredUserIDs : nil :^(NSMutableArray * _Nonnull favesUsersObjectsInfo, NSInteger offsetCounterResult, NSInteger totalFavesUsersResult, NSInteger offsefFavesUsersLoadResult, NSInteger favesUsersListCount) {
            favesUsersData = favesUsersObjectsInfo;
            totalCount = totalFavesUsersResult;
//            NSLog(@"%@",favesUsersData );
            NSLog(@"%li, %li , %li, %li", offsetCounterResult, totalFavesUsersResult, offsefFavesUsersLoadResult,favesUsersListCount);
            if(favesUsersListCount>0 && offsetCounterResult <= favesUsersListCount){
                dispatch_async(dispatch_get_main_queue(), ^{
                    //NSLog(@"%@", favesUsersData);
                    //NSLog(@"%li", [favesUsersData count]);
                    totalCountLabel.title = [NSString stringWithFormat:@"%li", totalFavesUsersResult];
                    loadedCount.title=[NSString stringWithFormat:@"%lu",offsetCounterResult];
                    [favesUsersList reloadData];
                    [progressSpin stopAnimation:self];
                    loading=NO;
                   
                    if(favesUsersListCount>0 && offsefFavesUsersLoadResult<totalFavesUsersResult){
                     
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"banAndUnbanUserInFaves" object:nil userInfo:@{@"favesUsersData":favesUsersData}];
                         NSLog(@"TOTAL FAVES USERS %li", totalFavesUsersResult);
                        NSLog(@"COUNT FAVES USERS %li", favesUsersListCount);
                        if(favesUsersListCount<15 && totalFavesUsersResult>=15 && offsetCounterResult < totalFavesUsersResult && [restoredUserIDs count]==0 && !loading){
                            dispatch_after(2, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                loadFavesBlock(YES);
                            });
                        }
                    }
                });
            }
            else{
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [favesUsersList reloadData];
                     [progressSpin stopAnimation:self];
                     loading=NO;
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




- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row{
    MyTableRowView *rowView = [[MyTableRowView alloc]init];

    return rowView;
}
- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row;
    NSInteger prevRow;
    if([[favesUsersList selectedRowIndexes]count]>0){
        
        row = [favesUsersList selectedRow];
        prevRow = row;
        receiverDataForMessage = favesUsersData[row];
        [favesUsersList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    }
//    if(prevRow){
//        [favesUsersList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:prevRow] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
//    }
  
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [favesUsersData count];
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    FavesUsersCustomCell *cell=[[FavesUsersCustomCell  alloc]init];
    cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.country.stringValue = favesUsersData[row][@"country"];
    cell.city.stringValue = favesUsersData[row][@"city" ];
    cell.fullName.stringValue = favesUsersData[row][@"full_name"];
    
    //        if(((MyTableRowView*)[tableView rowViewAtRow:row makeIfNecessary:NO]).isSelected){
    //            cell.fullName.attributedStringValue = [favesUsersData[row][@"full_name"] bos_makeString:^(BOStringMaker *make) {
    //               NSShadow *tshadow = [[NSShadow alloc]init];
    //                tshadow.shadowColor=[NSColor grayColor];
    //                tshadow.shadowOffset=NSMakeSize(0, 0);
    //                tshadow.shadowBlurRadius=2.0;
    //                make.shadow(tshadow);
    //            }];
    //        }else{
    //            cell.fullName.attributedStringValue = [favesUsersData[row][@"full_name"] bos_makeString:^(BOStringMaker *make) {
    //                NSShadow *tshadow2 = [[NSShadow alloc]init];
    //                tshadow2.shadowColor=[NSColor clearColor];
    //                make.shadow(nil);
    //            }];
    //        }
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
    
    if([favesUsersData[row][@"blacklisted_by_me"] intValue] || [favesUsersData[row][@"blacklisted"] intValue]){
        cell.blacklisted.hidden = NO;
    }else{
        cell.blacklisted.hidden = YES;
    }
   
    
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

@end
