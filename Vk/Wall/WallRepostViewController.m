//
//  WallRepostViewController.m
//  vkapp
//
//  Created by sim on 11.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "WallRepostViewController.h"
#import "WallRepostGroupsCustomCellView.h"
#import "AddRepostGroupController.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface WallRepostViewController ()<NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate>

@end

@implementation WallRepostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    groupsData1=[[NSMutableArray alloc]init];
    groupsData2=[[NSMutableArray alloc]init];
    searchBar1.delegate=self;
    searchBar2.delegate=self;
    selectedGroups = [[NSMutableArray alloc]init];
    groupsPopupData = [[NSMutableArray alloc]init];
    countGroups.title=@"0";
    countGroups2.title=@"0";
    [groupsPopupList removeAllItems];
    [groupsPopupData addObject:_app.person];
    [groupsPopupList addItemWithTitle:@"Personal"];
    addSeletedObjects.hidden = YES;
    groupsList1.delegate = self;
    groupsList1.dataSource = self;
    groupsList2.delegate = self;
    groupsList2.dataSource = self;
    groupsData1Copy = [[NSMutableArray alloc]init];
    groupsData2Copy = [[NSMutableArray alloc]init];
    [self loadGroupsPopup];
    [repostUserGroups removeAllItems];
    itemsToRemoveInSelectedRepostGroup = [[NSMutableArray alloc]init];
    [self getListOfUserRepostGroupsFromData];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadListUserRepostGroups:) name:@"reloadListUserRepostGroups" object:nil];
    removeRepostGroup.hidden=YES;
    addRepostGroup.hidden=YES;
    saveRepostGroup.hidden=YES;
    itemsToSaveInSelectedRepostGroup = [[NSMutableArray alloc]init];
}

- (IBAction)removeItemFromRepostGroup:(id)sender {
    saveRepostGroup.hidden=NO;
    NSInteger row = [groupsList2 rowForView:[sender superview]];
//    NSManagedObjectContext *moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
//    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    temporaryContext.parentContext=moc;
//    NSFetchRequest *request = [ NSFetchRequest fetchRequestWithEntityName:@"VKUserRepostGroupsNames"];
//    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@",[[repostUserGroups selectedItem]title]]];
//    NSError *readError;
//    NSError *saveError;
//    [request setReturnsObjectsAsFaults:NO];
//    NSArray *data = [temporaryContext executeFetchRequest:request error:&readError];
//    if(!readError){
//        for(NSManagedObject *i in data){
//            for(NSManagedObject *b in [[i valueForKey:@"userRepostGroups"] allObjects]){
////                NSLog(@"%@", [b valueForKey:@"id"]);
    
//                if([[b valueForKey:@"id"] isEqualToString:groupsData2[row][@"id"]]){
//                    NSLog(@"111");
//                    [temporaryContext deleteObject:b];
//                    if(![temporaryContext save:&saveError]){
//                        NSLog(@"Error remove item from repost group \"%@\"", [[repostUserGroups selectedItem]title]);
//                    }else{
//    for(NSDictionary *i in groupsData2){
//        if([i[@"id"] isEqual:groupsData2[row][@"id"]]){
            [itemsToRemoveInSelectedRepostGroup addObject:groupsData2[row]];
            [groupsData2 removeObjectAtIndex:row];
            [groupsList2 removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:row] withAnimation:NSTableViewAnimationSlideUp];
            
            //                        NSLog(@"Item successfully removed from repost group \"%@\"", [[repostUserGroups selectedItem]title]);
            countGroups2.title = [NSString stringWithFormat:@"%li", [groupsData2 count]];
            [groupsList2 reloadData];
//        }
//    }
//            }
//        }
    
//    }else{
//        NSLog(@"Error read repost group \"%@\"",[[repostUserGroups selectedItem]title]);
//    }
    
}

- (void)viewDidAppear{
     [self loadGroups1];
    countGroups.title=[NSString stringWithFormat:@"%li",[groupsData1 count]];
//     NSLog(@"%@", groupsData1[0][@"name"]);
}
- (void)reloadListUserRepostGroups:(NSNotification*)notification{
    [self getListOfUserRepostGroupsFromData];
}
- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(id)sender{
    AddRepostGroupController *contr = (AddRepostGroupController*)segue.destinationController;
    contr.receivedData = [[NSMutableArray alloc] initWithArray:groupsData2];
    
}
- (IBAction)saveRepostGroup:(id)sender {
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext=moc;
//    NSEntityDescription *entityDesc1 = [NSEntityDescription entityForName:@"VKUserRepostGroupsNames" inManagedObjectContext:moc];
    NSError *saveError;
    NSError *readError;
    NSMutableArray *objects = [[NSMutableArray alloc]init];
    NSFetchRequest *request = [ NSFetchRequest fetchRequestWithEntityName:@"VKUserRepostGroupsNames"];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@",[[repostUserGroups selectedItem]title]]];
    
    NSArray *data = [temporaryContext executeFetchRequest:request error:&readError];
    if([itemsToSaveInSelectedRepostGroup count]>0){
        [objects removeAllObjects];
        for(NSManagedObject *i in data){
            for(NSManagedObject *a in [i valueForKey:@"userRepostGroups"]){
                [objects addObject:a];
            }
            for(NSDictionary *b in itemsToSaveInSelectedRepostGroup){
                NSEntityDescription *entityDesc2 = [NSEntityDescription entityForName:@"VKUserRepostGroups" inManagedObjectContext:temporaryContext];
                NSManagedObject *object2 = [[NSManagedObject alloc]initWithEntity:entityDesc2 insertIntoManagedObjectContext:temporaryContext];
                [object2 setValue:b[@"id"] forKey:@"id"];
                [object2 setValue:b[@"photo"] forKey:@"photo"];
                [object2 setValue:b[@"deactivated"] forKey:@"deactivated"];
                [object2 setValue:b[@"desc"] forKey:@"desc"];
                [object2 setValue:b[@"name"] forKey:@"name"];
                //NSLog(@"%@",b[@"name"]);
                //[seet addObject:object2];
                [objects addObject:object2];
            }
            
            [i setValue:[NSSet setWithArray:objects] forKey:@"userRepostGroups"];
            if(![temporaryContext save:&saveError]){
                NSLog(@"Error save new items in group.");
            }else{
                NSLog(@"New items in group successfully saved.");
                [itemsToSaveInSelectedRepostGroup removeAllObjects];
            }
        }
    }
    if([itemsToRemoveInSelectedRepostGroup count]>0){
        NSMutableArray *ids = [[NSMutableArray alloc]init];
        for(NSDictionary *i in itemsToRemoveInSelectedRepostGroup){
            [ids addObject:i[@"id"]];
        }
        for(NSManagedObject *i in data){
            for(NSManagedObject *a in [[i valueForKey:@"userRepostGroups"] allObjects]){
                
                if ([ids containsObject: [a valueForKey:@"id"]] ){
                    [temporaryContext deleteObject:a];
                    if(![temporaryContext save:&saveError]){
                        NSLog(@"Error remove item from repost group \"%@\"", [[repostUserGroups selectedItem]title]);
                    }else{
                        
                        NSLog(@"Item successfully removed from repost group \"%@\"", [[repostUserGroups selectedItem]title]);
                    }
                }
            }
        }
         [itemsToRemoveInSelectedRepostGroup removeAllObjects];
    }

    
    
}

- (IBAction)removeRepostGroup:(id)sender {
//    NSLog(@"%@",  [[repostUserGroups selectedItem]title]);
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext=moc;
//    NSEntityDescription *entityDesc1 = [NSEntityDescription entityForName:@"VKUserRepostGroupsNames" inManagedObjectContext:moc];
    [temporaryContext performBlock:^{
        NSFetchRequest *request = [ NSFetchRequest fetchRequestWithEntityName:@"VKUserRepostGroupsNames"];
        NSError *readError;
        NSError *deleteError;
        [request setReturnsObjectsAsFaults:NO];
        [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@",[[repostUserGroups selectedItem]title]]];
        NSArray *data = [temporaryContext executeFetchRequest:request error:&readError];
        if(!readError){
            for(NSManagedObject *object in data){
                [temporaryContext deleteObject:object];
                if(![temporaryContext save:&deleteError]){
                    NSLog(@"Error delete epost group \"%@\"",  [[repostUserGroups selectedItem]title]);
                }
                [moc performBlockAndWait:^{
                    NSError *error=nil;
                    if(![moc save:&error]){
                        NSLog(@"Error saving context: %@\n%@", [error localizedDescription], [error userInfo]);
                        abort();
                    }else{
                        NSLog(@"Repost group \"%@\" successfully removed",  [[repostUserGroups selectedItem]title]);
                    }
                }];
            }
            [self getListOfUserRepostGroupsFromData];
        }else{
            NSLog(@"Error read repost groups.");
        }
    }];
}
- (IBAction)repostUserGroupsSelect:(id)sender {
    [itemsToRemoveInSelectedRepostGroup removeAllObjects];
    [itemsToSaveInSelectedRepostGroup removeAllObjects];
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    NSFetchRequest *request = [ NSFetchRequest fetchRequestWithEntityName:@"VKUserRepostGroupsNames"];
    NSError *readError;
    
//    [request setResultType:NSDictionaryResultType];
    [request setReturnsObjectsAsFaults:NO];
//     [request setShouldRefreshRefetchedObjects:YES];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name == %@", [[repostUserGroups selectedItem]title]]];
//    [request setRelationshipKeyPathsForPrefetching:@[@"userRepostGroups"]];

    NSArray *data = [moc executeFetchRequest:request  error:&readError];
    
   
    if(!readError){
        removeRepostGroup.hidden=NO;
//        [groupsList2 removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [groupsData2 count])] withAnimation:NSTableViewAnimationEffectGap];
        [groupsData2 removeAllObjects];
      
        for(NSManagedObject *i in data ){
            for(NSManagedObject *a in [[i valueForKey:@"userRepostGroups"] allObjects]){
//                NSLog(@"%@", [a valueForKey:@"name"]);
                [groupsData2 addObject:@{@"name":[a valueForKey:@"name"], @"desc":[a valueForKey:@"desc"], @"photo":[a valueForKey:@"photo"], @"id":[a valueForKey:@"id"], @"deactivated":[a valueForKey:@"deactivated"]}];
                
            }
            
        }
        countGroups2.title = [NSString stringWithFormat:@"%li", [groupsData2 count]];
        selectedGroups = groupsData2;
        [groupsList2 reloadData];
        
    }else{
        NSLog(@"Error read repostSelectedGroup.");
    }
    
    
    
    
    
}
- (void)getListOfUserRepostGroupsFromData{
    [repostUserGroups removeAllItems];
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication ] delegate] managedObjectContext];
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext=moc;
//    NSEntityDescription *entityDesc1 = [NSEntityDescription entityForName:@"VKUserRepostGroupsNames" inManagedObjectContext:moc];
    NSFetchRequest *request = [ NSFetchRequest fetchRequestWithEntityName:@"VKUserRepostGroupsNames"];
    NSError *readError;
    [request setResultType:NSDictionaryResultType];
    [request setReturnsObjectsAsFaults:NO];
    NSArray *data = [temporaryContext executeFetchRequest:request error:&readError];
    for(NSDictionary *i in data){
        [repostUserGroups addItemWithTitle:i[@"name"]];
    }
    
}

- (void)searchFieldDidStartSearching:(NSSearchField *)sender{
    [self loadGroupsList1Search];
}
- (void)searchFieldDidEndSearching:(NSSearchField *)sender{
    groupsData1 = groupsData1Copy;
    [groupsList1 reloadData];
}

- (void)loadGroupsList1Search{
    
    NSInteger counter=0;
//    NSMutableArray *groupsData1Temp=[[NSMutableArray alloc]init];
    groupsData1Copy = [[NSMutableArray alloc]initWithArray:groupsData1];
    [groupsData1 removeAllObjects];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchBar1.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
    for(NSDictionary *i in groupsData1Copy){
        
        NSArray *found = [regex matchesInString:i[@"name"]  options:0 range:NSMakeRange(0, [i[@"name"] length])];
        if([found count]>0 && ![searchBar1.stringValue isEqual:@""]){
            counter++;
            [groupsData1 addObject:i];
        }
        
    }
    //     NSLog(@"Start search %@", banlistDataTemp);
    
        
        [groupsList1 reloadData];
    
}
- (IBAction)groupsPopupSelect:(id)sender {
    
    groupToRespostTo = [groupsPopupData objectAtIndex:[groupsPopupList indexOfSelectedItem]];
//    NSLog(@"%@", groupToRespostTo);
}
- (IBAction)addToSelectTable:(id)sender {
    
    NSView *parentCell = [sender superview];
    NSInteger row = [groupsList1 rowForView:parentCell];
//    NSLog(@"%@", groupsData1[row]);
//    NSLog(@"%li", row);
    
//    NSDictionary *groupData = groupsData1[row];
    
    if(![groupsData2 containsObject:groupsData1[row]]){
//        [groupsData2 addObject:groupsData1[row]];
        [groupsData2 insertObject:groupsData1[row] atIndex:0];
        selectedGroups = groupsData2;
//        groupsData2 = [[NSMutableArray alloc]initWithArray:[[groupsData2 reverseObjectEnumerator] allObjects]];
        
        if(repostUserGroups.selectedItem){
            [itemsToSaveInSelectedRepostGroup addObject:groupsData1[row]];
        }
        [groupsList2 insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideLeft];
//        [groupsList2 reloadData];
        countGroups2.title = [NSString stringWithFormat:@"%li", [groupsData2 count]];
        saveRepostGroup.hidden=NO;
        addRepostGroup.hidden=NO;
    }
    
}

- (IBAction)addSelectedObjectsAction:(id)sender {
    NSIndexSet *rows;
    rows=[groupsList1 selectedRowIndexes];
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            if(![groupsData2 containsObject:groupsData1[i]]){
                [groupsData2 addObject:groupsData1[i]] ;
            }
        }

//    NSLog(@"%@", selectedGroups);
    selectedGroups = groupsData2;
    [groupsList2 insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [groupsData2 count]) ] withAnimation:NSTableViewAnimationSlideLeft];
    countGroups2.title = [NSString stringWithFormat:@"%li", [groupsData2 count] ];
//    [groupsList2 reloadData];
    addRepostGroup.hidden=NO;
}
- (IBAction)clearSelectedToRepost:(id)senfder {
//    [selectedObjects removeAllObjects];
    [selectedGroups removeAllObjects];
    countGroups2.title = [NSString stringWithFormat:@"%li", [selectedGroups count] ];
    [groupsData2 removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [groupsData2 count])]];
    [groupsList2 removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [groupsData2 count])] withAnimation:NSTableViewAnimationSlideUp];
    [groupsList2 reloadData];
    addRepostGroup.hidden=YES;
    removeRepostGroup.hidden=YES;
    
}
- (IBAction)repost:(id)sender {
    __block NSMutableArray *notPinnedPosts = [[NSMutableArray alloc]init];
    
//    NSLog(@"%@", [arrayController1 selectedObjects]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(NSDictionary *i in selectedGroups){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.get?owner_id=-%@&count=3&access_token=%@&v=%@", i[@"id"], _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                NSDictionary *wallGetResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                            NSLog(@"%@", wallGetResp);
                
                for(NSDictionary *a in wallGetResp[@"response"][@"items"]){
                    if(!a[@"is_pinned"]){
                        [notPinnedPosts addObject:a[@"id"]];
                    }
                }
                
              NSLog(@"wall-%@_%@", i[@"id"], notPinnedPosts[0]);
                [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.repost?object=wall-%@_%@&message=%@&group_id=%i&access_token=%@&v=%@", i[@"id"], notPinnedPosts[0], @"", abs( [groupToRespostTo intValue]), _app.token, _app.version]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSDictionary *repostResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@", repostResponse);
                }]resume];
                [notPinnedPosts removeAllObjects];
                
            }]resume];
            sleep(2);
        }
    });
    
}
- (void)loadGroupsPopup{
    
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
            [groupsPopupData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
            [groupsPopupList addItemWithTitle:i[@"name"]];
            
        }
    }]resume];
}
- (void)loadGroups1{
//    if([groupsData1 count]==0){
//        _groupsHandle = [[groupsHandler alloc] init];
//        //    NSLog(@"%@", [_groupsHandle readFromFile]);
//        if ([_groupsHandle readFromFile]!=nil){
//            groupsData1 = [_groupsHandle readFromFile];
//            NSLog(@"%@", groupsData1[0][@"name"]);
////            arrayController1.content=groupsData1;
//            [groupsList1 reloadData];
//        }else{
//            NSLog(@"Check your groups file");
//        }
//    }else{
////        arrayController1.content=groupsData1;
//        [groupsList1 reloadData];
//    }
    NSManagedObjectContext *moc = [[[NSApplication sharedApplication]delegate] managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"VKGroups"];
    [request setReturnsObjectsAsFaults:NO];
    [request setResultType:NSDictionaryResultType];
    NSError *readError;
    NSArray *array = [moc executeFetchRequest:request error:&readError];
    if(array!=nil){
        groupsData1 = [[NSMutableArray alloc] initWithArray:array];
        
        [groupsList1 reloadData];
    }
}



- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    
    if([notification.object isEqual: groupsList1]){
        
        if([[groupsList1 selectedRowIndexes]count]>1){
            addSeletedObjects.hidden=NO;
        }else{
            addSeletedObjects.hidden=YES;
        }
    }
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([tableView isEqual: groupsList1]){
        if([groupsData1 count]>0){
            
            return [groupsData1 count];
        }
    }
    else if([tableView isEqual: groupsList2]){
        if([groupsData2 count]>0){
            return [groupsData2 count];
        }
    }
    return 0;
}
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
  
    
    if([tableView isEqual: groupsList1]){
        WallRepostGroupsCustomCellView *cell = [[WallRepostGroupsCustomCellView alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        if([groupsData1 count]>0){
            cell.groupName.stringValue=groupsData1[row][@"name"];
            cell.groupPhoto.wantsLayer=YES;
            cell.groupPhoto.layer.masksToBounds=YES;
            cell.groupPhoto.layer.cornerRadius=38/2;
          
            [cell.groupPhoto sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString: groupsData1[row][@"photo"]] placeholderImage:[NSImage imageNamed:@"placeholderImage.jpg"] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                image.size=NSMakeSize(38, 38);
                [cell.groupPhoto setImage:image];
            }];
            
            return cell;
        }
    }
    else if([tableView isEqual:groupsList2]){
        WallRepostGroupsCustomCellView *cell = [[WallRepostGroupsCustomCellView alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        if([groupsData2 count]>0){
            cell.groupName.stringValue=groupsData2[row][@"name"];
            cell.groupPhoto.wantsLayer=YES;
            cell.groupPhoto.layer.masksToBounds=YES;
            cell.groupPhoto.layer.cornerRadius=38/2;;
            cell.groupName.stringValue=groupsData2[row][@"name"];
            
            [cell.groupPhoto sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:groupsData2[row][@"photo"]] placeholderImage:[NSImage imageNamed:@"placeholderImage.jpg"] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                
            } completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                image.size=NSMakeSize(38, 38);
                [cell.groupPhoto setImage:image];
            }];
           
            
            return cell;
        }
    }
    return nil;
}
@end
