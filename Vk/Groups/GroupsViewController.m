//
//  GroupsViewController.m
//  vkapp
//
//  Created by sim on 14.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "GroupsViewController.h"
#import "FullGroupInfoViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
@interface GroupsViewController ()<NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate>

@end

@implementation GroupsViewController
@synthesize value, arrayController;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    groupsList.delegate=self;
    groupsList.dataSource=self;
    groupsData = [[NSMutableArray alloc]init];
    searchBar.delegate=self;
    _app = [[appInfo alloc]init];
    foundData = [[NSMutableArray alloc]init];
    [[groupsListScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
//    searchGroupBar.delegate=self;
    searchCountResults.hidden=YES;
    tempData = [[NSMutableArray alloc]init];
//    [self loadGroups:NO :NO];
    [self loadGroupsFromFile];
    groupsDataCopy = [[NSMutableArray alloc]init];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(VisitGroupPageFromBanlist:) name:@"VisitGroupPageFromBanlist" object:nil];
    //     NSBezierPath * path = [NSBezierPath bezierPathWithRoundedRect:favesScrollView.frame xRadius:4 yRadius:4];
    CAShapeLayer * layer = [CAShapeLayer layer];
    
    layer.cornerRadius=4;
    layer.borderWidth=1;
    layer.borderColor=[[NSColor colorWithWhite:0.8 alpha:1]CGColor];
    groupsList.enclosingScrollView.wantsLayer = TRUE;
    groupsList.enclosingScrollView.layer = layer;
}
-(void)VisitGroupPageFromBanlist:(NSNotification*)notification{
    NSInteger row = [notification.userInfo[@"row"] intValue];
    NSLog(@"%@", groupsData[row]);
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://vk.com/club%@",groupsData[row][@"id"]]]];
}
-(void)viewDidAppear{
  
    
}
- (IBAction)showFullInfo:(id)sender {
    NSStoryboard *storySecond = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
    FullGroupInfoViewController *popuper = [storySecond instantiateControllerWithIdentifier:@"GroupFullInfo"];
    NSPoint mouseLoc = [NSEvent mouseLocation];
    //    int x = mouseLoc.x;
    int y = mouseLoc.y;
    //    int scrollPosition = [[scrollView contentView] bounds].origin.y+120;
    
    NSView *parentCell = [sender superview];
    NSInteger row = [groupsList rowForView:parentCell];
    CGRect rect=CGRectMake(0, y, 0, 0);
    popuper.receivedData = groupsData[row];
    
    [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:groupsList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
    
    
}
- (IBAction)unloadGroups:(id)sender {
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
     NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
    temporaryContext.parentContext=moc;
    
//    _groupsHandle = [[groupsHandler alloc]init];
//    NSLog(@"%@", [_groupsHandle readFromFile]);
//    [_groupsHandle writeToFile:groupsData];
    reloaded=NO;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc ] init];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"VKGroups" inManagedObjectContext:temporaryContext]];
    NSError *error;
    NSArray *items = [temporaryContext executeFetchRequest:fetchRequest error:&error];
//    fetchRequest = nil;
    
    if ([items count]>0){
        for (NSManagedObject *managedObject in items) {
            [temporaryContext deleteObject:managedObject];
        }
        if (![temporaryContext save:&error]) {
        }
    }
    
    
    [temporaryContext performBlock:^{
        for(NSDictionary *i in groupsData){
            NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"VKGroups" inManagedObjectContext:temporaryContext];
            [object setValue:i[@"id"] forKey:@"id"];
            [object setValue:i[@"name"] forKey:@"name"];
            [object setValue:i[@"photo"] forKey:@"photo"];
            [object setValue:i[@"desc"] forKey:@"desc"];
            [object setValue:i[@"deactivated"] forKey:@"deactivated"];
            [object setValue:i[@"status"] forKey:@"status"];
            [object setValue:i[@"site"] forKey:@"site"];
            [object setValue:i[@"is_admin"] forKey:@"is_admin"];
            [object setValue:i[@"members_count"] forKey:@"members_count"];
            [object setValue:i[@"country"] forKey:@"country"];
            [object setValue:i[@"city"] forKey:@"city"];
            [object setValue:i[@"start_date"] forKey:@"start_date"];
            [object setValue:i[@"screen_name"] forKey:@"screen_name"];
            [object setValue:i[@"is_closed"] forKey:@"is_closed"];
            [object setValue:i[@"is_member"] forKey:@"is_member"];
            [object setValue:i[@"type"] forKey:@"type"];
            [object setValue:i[@"finish_date"] forKey:@"finish_date"];
            
            NSError *saveError;
            if(![temporaryContext save:&saveError]){
                NSLog(@"Error");
            }else{
//                NSLog(@"Saved");
            }
        }

    }];

}
- (IBAction)filterActive:(id)sender {
    if(filterActive.state==1 && foundData){
        groupsData = tempData;
        [groupsList reloadData];
        //        groupInvitesSearchCount.title = [NSString stringWithFormat:@"%lu", [GroupInvitesData count]];
        searchCountResults.hidden = YES;
    }
    else{
        [self filterGroups];
    }
}
- (IBAction)filterDeactivated:(id)sender {
    if(filterDeactivated.state==1 && foundData){
        groupsData = tempData;
        [groupsList reloadData];
        //        groupInvitesSearchCount.title = [NSString stringWithFormat:@"%lu", [GroupInvitesData count]];
        searchCountResults.hidden = YES;
        
    }
    else{
        [self filterGroups];
    }
}
-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    [self loadSearchGroups];
    
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    groupsData = groupsDataCopy;
    [groupsList reloadData];
}
-(void)loadGroupsFromFile{
    
       
  
     NSManagedObjectContext *moc = [[[NSApplication sharedApplication] delegate] managedObjectContext];
        NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = moc;
//    if([groupsData count]==0){
//        _groupsHandle = [[groupsHandler alloc] init];
//        //    NSLog(@"%@", [_groupsHandle readFromFile]);
//        if ([_groupsHandle readFromFile]!=nil){
//            groupsData = [_groupsHandle readFromFile];
//            totalCountGroups.title = [NSString stringWithFormat:@"%li", [groupsData count] ];
//            loadedCountGroups.title =[NSString stringWithFormat:@"%li", [groupsData count] ];
////            NSLog(@"%@", groupsData[0][@"name"]);
//            //            arrayController1.content=groupsData1;
//            [groupsList reloadData];
//        }else{
//            NSLog(@"Check your groups file");
//        }
//    }else{
//        //        arrayController1.content=groupsData1;
//        [groupsList reloadData];
//    }
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"VKGroups" inManagedObjectContext:temporaryContext]];
    [request setReturnsObjectsAsFaults:NO];
    [request setResultType:NSDictionaryResultType];
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
//     NSLog(@"%@", array);
    if([array count]>0){
        groupsData = [[NSMutableArray alloc] initWithArray:array];
        totalCountGroups.title = [NSString stringWithFormat:@"%li", [groupsData count] ];
        loadedCountGroups.title =[NSString stringWithFormat:@"%li", [groupsData count] ];
        
        [groupsList reloadData];
    }
//    if (array != nil) {
//        for(NSDictionary *i in array){
//            NSLog(@"%@", i);
//        }
//    }
//    else {
//        NSLog(@"Error");
//    }
        
}
-(void)loadSearchGroups{
    
    NSInteger counter=0;
    NSMutableArray *groupsDataTemp = [[NSMutableArray alloc]init];
    groupsDataCopy = [[NSMutableArray alloc]initWithArray:groupsData];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
    [groupsDataTemp removeAllObjects];
    for(NSDictionary *i in groupsData){
        
        NSArray *found = [regex matchesInString:i[@"name"]  options:0 range:NSMakeRange(0, [i[@"name"] length])];
        if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
            counter++;
            [groupsDataTemp addObject:i];
        }
        
    }
    //     NSLog(@"Start search %@", banlistDataTemp);
    if([groupsDataTemp count]>0){
        groupsData = groupsDataTemp;
        [groupsList reloadData];
    }
    
}
-(void)filterGroups{
    NSInteger counter=0;
    [groupsList scrollToBeginningOfDocument:self];
    //    if([groupInvitesList numberOfRows]>2){
    //        [groupInvitesList removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [GroupInvitesData count])] withAnimation:NSTableViewAnimationEffectNone];
    //    }
    [foundData removeAllObjects];
    
    tempData = [[NSMutableArray alloc]initWithArray:groupsData];;
    for(NSDictionary *i in groupsData){
        
        
        if( filterDeactivated.state==1 && filterActive.state==1){
            if([i[@"deactivated"] intValue] ==1 || [i[@"deactivated"] intValue]==0){
                [foundData addObject:i];
                counter++;
            }
        }
        
        else if(filterDeactivated.state==0 && filterActive.state==1){
            if([i[@"deactivated"] intValue]==0){
                [foundData addObject:i];
                counter++;
            }
        }
        else if(filterDeactivated.state==0 && filterActive.state==0){
            
                [foundData removeAllObjects];
                break;
            
        }
        else if(filterDeactivated.state==1 && filterActive.state==0){
            if([i[@"desc"] containsString:@"Данный материал"]){
                [foundData addObject:i];
                counter++;
            }
        }
        
    }
    if([foundData count] > 0){
        [groupsData removeAllObjects];
        groupsData = [[NSMutableArray alloc]initWithArray:foundData];
        arrayController.content=groupsData;
//        filterData = YES;
        //        NSLog(@"%lu", [foundData count]);
        //        NSLog(@"%lu", [GroupInvitesData count]);
        searchCountResults.title=[NSString stringWithFormat:@"%lu", counter];
        searchCountResults.hidden=NO;
        //        subscribersCountInline.title = [NSString stringWithFormat:@"%lu", [subscribersData count]];
        [groupsList reloadData];
        //[self loadSubscribers:NO :NO];
    }

}
- (IBAction)leaveGroup:(id)sender {
    
    rows=[groupsList selectedRowIndexes];
    NSMutableArray *selectedGroups=[[NSMutableArray alloc]init];
    void(^leaveGroupBlock)()=^void(){
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            [selectedGroups addObject:@{@"id":groupsData[i][@"id"], @"index":[NSNumber numberWithInteger:i]}];
            
            
        }
        for(NSDictionary *i in selectedGroups){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.leave?group_id=%@&v=%@&access_token=%@", i[@"id"], _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *groupLeaveResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
                
                NSLog(@"%@", groupLeaveResponse);
            }]resume];
            dispatch_async(dispatch_get_main_queue(), ^{
                [groupsList deselectRow:[i[@"index"] intValue]];

            });
            sleep(1);
        }
       
        dispatch_async(dispatch_get_main_queue(), ^{
//            [self loadGroups:NO :NO];
            [groupsData removeObjectsAtIndexes:rows];
            if([tempData count]>0){
                [tempData removeObjectsAtIndexes:rows];
            }
            [foundData removeAllObjects];
            [groupsList reloadData];

        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        leaveGroupBlock();
    });

    
}


- (IBAction)reloadGroups:(id)sender {
    [self loadGroups:NO :NO];
    reloaded=YES;
}
-(void)viewDidScroll:(NSNotification*)notification{
    if([notification.object isEqual:groupsListClipView]){
        NSInteger scrollOrigin = [[groupsListScrollView contentView]bounds].origin.y+NSMaxY([groupsListScrollView visibleRect]);
//        NSInteger numberRowHeights = [groupsList numberOfRows] * [groupsList rowHeight];
        NSInteger boundsHeight = groupsList.bounds.size.height;
//        NSInteger frameHeight = groupsList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            //Refresh here
            //         NSLog(@"The end of table");
            if([foundData count] <=0 && reloaded ) {
                [self loadGroups:NO :YES];
            }
        }
        //        NSLog(@"%ld", scrollOrigin);
        //        NSLog(@"%ld", boundsHeight);
        //    NSLog(@"%fld", frameHeight-300);
        //
    }

    
}
- (IBAction)goUp:(id)sender {
    [groupsList scrollToBeginningOfDocument:self];
}
- (IBAction)goDown:(id)sender {
    [groupsList scrollToEndOfDocument:self];
    
}
-(void)loadGroups:(BOOL)searchByName :(BOOL)makeOffset{
    if(makeOffset){
        offsetLoadGroups=offsetLoadGroups+1000;
    }else{
        [groupsData removeAllObjects];
        offsetLoadGroups=0;
        offsetCounter=0;
    }
      [progressSpin startAnimation:self];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&v=%@&access_token=%@&extended=1&count=1000&offset=%lu&fields=description,city,country,members_count,status,site,start_date,finish_date", _app.person, _app.version, _app.token, offsetLoadGroups]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"%@", groupsGetResponse);
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
        dispatch_async(dispatch_get_main_queue(), ^{
             totalCountGroups.title= [NSString stringWithFormat:@"%@", groupsGetResponse[@"response"][@"count"]];
        });
       
        for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
         
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
            
            
            [groupsData addObject:@{@"name":i[@"name"], @"id":[NSString stringWithFormat:@"%@",i[@"id"]], @"deactivated":deactivated, @"desc":desc, @"photo":photo, @"members_count":membersCount, @"status":status, @"site":site, @"start_date":startDate, @"country":country, @"city":city, @"type":type, @"screen_name":screenName, @"is_member":isMember, @"finish_date":finishDate}];
            
            offsetCounter++;
        }
//        NSLog(@"%@", groupsData);
        dispatch_async(dispatch_get_main_queue(), ^{
//            arrayController.content = groupsData;
            [groupsList reloadData];
            loadedCountGroups.title = [NSString stringWithFormat:@"%li",offsetCounter];
            [progressSpin stopAnimation:self];
        });
    }]resume];
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if([groupsData count]>0){
        return [groupsData count];
    }
    return 0;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([groupsData count]>0){
        GroupsCustomCellView *cell = [[GroupsCustomCellView alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        //        cell.groupImage.stringValue=groupsData[row][@"photo"];
        cell.nameOfGroup.stringValue = groupsData[row][@"name"];
        cell.descriptionOfGroup.stringValue = groupsData[row][@"desc"];
        cell.groupId.stringValue = groupsData[row][@"id"];

        cell.groupImage.wantsLayer=YES;
        cell.groupImage.layer.masksToBounds=YES;
        cell.groupImage.layer.cornerRadius = 70/2;
  

        [cell.groupImage sd_setImageWithPreviousCachedImageWithURL:[NSURL URLWithString:groupsData[row][@"photo"]] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(NSImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            NSSize imSize=NSMakeSize(70, 70);
            image.size=imSize;
            [cell.groupImage setImage:image];
        }];
        return cell;
    }
    
    return nil;

}
@end
