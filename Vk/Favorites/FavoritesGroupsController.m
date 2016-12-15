//
//  FavoritesGroupsController.m
//  vkapp
//
//  Created by sim on 24.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "FavoritesGroupsController.h"
#import "FriendsMessageSendViewController.h"
#import "FavesUsersCustomCell.h"
#import "GroupsCustomCellView.h"
#import "FullGroupInfoViewController.h"
@interface FavoritesGroupsController ()<NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate>

@end

@implementation FavoritesGroupsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [super viewDidLoad];
    // Do view setup here.
    favesGroupsList.delegate=self;
    favesGroupsList.dataSource=self;
    searchBar.delegate=self;
    favesGroupsData = [[NSMutableArray alloc]init];

    selectedGroups = [[NSMutableArray alloc]init];
    favesGroupsTemp = [[NSMutableArray alloc]init];
    _app = [[appInfo alloc]init];
    [self loadFavesGroups:NO :NO];
    [[favesGroupsScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    offsetLoadFaveGroups=0;
     groupDataById = [[NSMutableArray alloc]init];
    

}
- (IBAction)groupInfoPopup:(id)sender {
    NSView *parentCell = [sender superview];
    NSInteger row = [favesGroupsList rowForView:parentCell];
   
  

//    contr.receivedData = favesGroupsData[row];
//    NSLog(@"%@", favesGroupsData[row]);
    [self loadInfoByURLRequest:[favesGroupsData[row][@"id"] componentsSeparatedByString:@"_"][2]];
 
}
-(void)viewDidScroll:(NSNotification*)notification{
    if([notification.object isEqual:favesGroupsClipView]){
        NSInteger scrollOrigin = [[favesGroupsScrollView contentView]bounds].origin.y+NSMaxY([favesGroupsScrollView visibleRect]);
        //    NSInteger numberRowHeights = [subscribersList numberOfRows] * [subscribersList rowHeight];
        NSInteger boundsHeight = favesGroupsList.bounds.size.height;
        //    NSInteger frameHeight = subscribersList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            //Refresh here
            //         NSLog(@"The end of table");
                        if(filterActive.state == 1){
                                [self loadFavesGroups:NO :YES];
                        }
        }
        //        NSLog(@"%ld", scrollOrigin);
        //        NSLog(@"%ld", boundsHeight);
        //    NSLog(@"%fld", frameHeight-300);
        //
    }
    
}
- (IBAction)filterActive:(id)sender {
    NSInteger counter=0;
    favesGroupsDataTemp=[[NSMutableArray alloc]init];
    
    [favesGroupsDataTemp removeAllObjects];
    if(filterActive.state==1){
//        [favesGroupsList scrollToBeginningOfDocument:self];
        favesGroupsData = favesGroupsDataCopy;
        [favesGroupsList reloadData];
    }
    else{
        
        favesGroupsDataCopy = [[NSMutableArray alloc]initWithArray:favesGroupsData];
        for(NSDictionary *i in favesGroupsData){
            if(![i[@"deactivated"] isEqual:@""]){
                counter++;
                [favesGroupsDataTemp addObject:i];
            }
            
        }
        //     NSLog(@"Start search %@", banlistDataTemp);
        if([favesGroupsDataTemp count]>0){
            favesGroupsData = favesGroupsDataTemp;
//             [favesGroupsList scrollToBeginningOfDocument:self];
            [favesGroupsList reloadData];
        }
    }
}
- (IBAction)filterDeactivated:(id)sender {
    if(filterDeactivated.state==1){
        
    }
    else{
      
    }
}
-(void)searchFieldDidStartSearching:(NSSearchField *)sender{
    [self loadFavesGroupsSearchList];
}
-(void)searchFieldDidEndSearching:(NSSearchField *)sender{
    favesGroupsData = favesGroupsDataCopySearch;
    [favesGroupsList reloadData];
}
- (IBAction)goUp:(id)sender {
    [favesGroupsList scrollToBeginningOfDocument:self];
}
- (IBAction)goDown:(id)sender {
    [favesGroupsList scrollToEndOfDocument:self];
}
- (IBAction)showGroupInBrowser:(id)sender {
    NSView *parentCell = [sender superview];
    NSInteger row = [favesGroupsList rowForView:parentCell];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString: favesGroupsData[row][@"url"]]];
}
-(void)loadFavesGroupsSearchList{
    
    NSInteger counter=0;
    favesGroupsDataTemp=[[NSMutableArray alloc]init];
    favesGroupsDataCopySearch = [[NSMutableArray alloc]initWithArray:favesGroupsData];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchBar.stringValue options:NSRegularExpressionCaseInsensitive error:nil];
    [favesGroupsDataTemp removeAllObjects];
    for(NSDictionary *i in favesGroupsData){
        
        NSArray *found = [regex matchesInString:i[@"name"]  options:0 range:NSMakeRange(0, [i[@"name"] length])];
        if([found count]>0 && ![searchBar.stringValue isEqual:@""]){
            counter++;
            [favesGroupsDataTemp addObject:i];
        }
        
    }
    //     NSLog(@"Start search %@", banlistDataTemp);
    if([favesGroupsDataTemp count]>0){
        favesGroupsData = favesGroupsDataTemp;
        [favesGroupsList reloadData];
    }
    
}
- (IBAction)deleteGroupsFromFavesAction:(id)sender {
    
    NSIndexSet *rows;
    rows=[favesGroupsList selectedRowIndexes];
    [selectedGroups removeAllObjects];
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    NSMutableIndexSet *indexes2 = [NSMutableIndexSet indexSet];
    void(^deleteFromFavesBlock)()=^void(){
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            [selectedGroups addObject:favesGroupsData[i]];
//            [indexes addIndex:[favesGroupsData[i][@"index"] intValue]];
           
        }
        NSLog(@"Selected groups:%@", selectedGroups);
       for(NSDictionary *i in selectedGroups){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/fave.removeLink?link_id=%@&v=%@&access_token=%@", i[@"id"] ,_app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
               NSDictionary *deleteUsersFromFavesResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
               NSLog(@"%@", deleteUsersFromFavesResponse);
            }]resume];
           dispatch_async(dispatch_get_main_queue(), ^{
               [favesGroupsList deselectRow:[selectedGroups indexOfObject:i]];
               totalCount.title =[NSString stringWithFormat:@"%i", [totalCount.title intValue]-1];
               countLoaded.title =[NSString stringWithFormat:@"%li", [favesGroupsData count] ==0 ? [favesGroupsDataCopy count] : [favesGroupsData count]];
               offsetCounter-=1;
           });
           sleep(1);
       }
       
//
        for(NSDictionary *i in favesGroupsDataCopy){
            if([selectedGroups containsObject:i]){
                NSLog(@"%@", i);
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [favesGroupsList deselectRow:[selectedGroups indexOfObject:i]];
                    
                });
                [indexes addIndex:[favesGroupsDataCopy indexOfObject:i]];
                
//                 [favesGroupsDataCopy removeObjectAtIndex:];
//                sleep(1);
                
               
            }
        }
        [favesGroupsDataCopy removeObjectsAtIndexes:indexes];
         [favesGroupsData removeObjectsAtIndexes:rows];
        if([favesGroupsDataCopySearch count]>0){
            for(NSDictionary *i in favesGroupsDataCopySearch){
                if([selectedGroups containsObject:i]){
                    NSLog(@"%@", i);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //                    [favesGroupsList deselectRow:[selectedGroups indexOfObject:i]];
                        
                    });
                    [indexes2 addIndex:[favesGroupsDataCopySearch indexOfObject:i]];
                    
                    //                 [favesGroupsDataCopy removeObjectAtIndex:];
                    //                sleep(1);
                    
                    
                }
            }
            [favesGroupsDataCopySearch removeObjectsAtIndexes:indexes2];
        }
        
//        NSLog(@"%@", indexes);
//        NSLog(@"%@", [favesGroupsDataCopy objectsAtIndexes:indexes]);
        dispatch_async(dispatch_get_main_queue(), ^{
//            [favesGroupsTemp removeObjectsAtIndexes:rows];

            [favesGroupsList reloadData];
        
            
        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        deleteFromFavesBlock();
    });
    
}

- (IBAction)selectAllAction:(id)sender {
    
    [favesGroupsList selectAll:self];
}
-(void)setButtonStyle:(id)button{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor whiteColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
    NSAttributedString *attrString = [[NSAttributedString alloc]initWithString:[button title] attributes:attrsDictionary];
    [button setAttributedTitle:attrString];
}
//- (IBAction)showFullInfo:(id)sender {
//    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
//    FullUserInfoPopupViewController *popuper = [story instantiateControllerWithIdentifier:@"profilePopup"];
//    NSPoint mouseLoc = [NSEvent mouseLocation];
//    //    int x = mouseLoc.x;
//    int y = mouseLoc.y;
//    //    int scrollPosition = [[scrollView contentView] bounds].origin.y+120;
//    
//    NSView *parentCell = [sender superview];
//    NSInteger row = [favesGroupsList rowForView:parentCell];
//    CGRect rect=CGRectMake(0, y, 0, 0);
//    popuper.receivedData = favesGroupsData[row];
//    
//    [self presentViewController:popuper asPopoverRelativeToRect:rect ofView:favesGroupsList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
//    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadUserFullInfo" object:self userInfo:dataForUserInfo];
//}
- (IBAction)sendMessage:(id)sender {
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    FriendsMessageSendViewController *controller = [story instantiateControllerWithIdentifier:@"MessageController"];
    controller.recivedDataForMessage=receiverDataForMessage;
    [self presentViewControllerAsSheet:controller];
}




-(void)cleanTable{
    NSIndexSet *index=[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [favesGroupsData count])];
    
    [favesGroupsList removeRowsAtIndexes:index withAnimation:0];
    //    [favesGroupsData removeAllObjects];
    //    if([favesGroupsData count]==0){
    //        [favesGroupsData removeAllObjects];
    //        [favesGroupsList reloadData];
    //        [favesGroupsList reloadData];
    ////        sleep(2);
    //          [self loadFavesGroups:NO];
    //    }
    
    
}

-(void)loadFavesGroups:(BOOL)searchByName :(BOOL)makeOffset{
    __block NSDictionary *object;
    if(makeOffset){
        offsetLoadFaveGroups=offsetLoadFaveGroups+50;
    }else{
        [favesGroupsData removeAllObjects];
        //
        offsetLoadFaveGroups=0;
        offsetCounter=0;
    }
    [progressSpin startAnimation:self];
    NSLog(@"%li", offsetLoadFaveGroups);

            [[_app.session dataTaskWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"https://api.vk.com/method/fave.getLinks?offset=%li&access_token=%@&v=%@", offsetLoadFaveGroups, _app.token, _app.version]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
                    
                    NSDictionary *getFavesGroupsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    //                   NSLog(@"%@", getUsersResponse);
                    if (getFavesGroupsResponse[@"error"]){
                        NSLog(@"%@:%@", getFavesGroupsResponse[@"error"][@"error_code"], getFavesGroupsResponse[@"error"][@"error_msg"]);
                    }
                    else{             
                        NSString *groupName;
                        NSString *deactivated;
//                        NSString *groupId;
                        NSString *desc;
                        NSString *photo;
                        NSString *url;
                        NSString *linkId;
//                        NSString *screenName;
//                        NSString *status;
//                        NSString *site;
//                        NSString *city;
//                        NSString *country;
//                        NSString *name;
                        dispatch_async(dispatch_get_main_queue(), ^{
                    
                              totalCount.title=[NSString stringWithFormat:@"%@",getFavesGroupsResponse[@"response"][@"count"]];
                        });
                      
                            for (NSDictionary *a in getFavesGroupsResponse[@"response"][@"items"]){
                                groupName = a[@"title"];
                                linkId = a[@"id"];
                                deactivated = [a[@"photo_100"] containsString:@"deactivated"]  ? @"deactivated" : @"";
                                photo = a[@"photo_100"];
                                
                                desc = a[@"description"] && a[@"description"]!=nil ? a[@"description"] : @"";
                                url = a[@"url"];
                            
                                
                                object = [NSDictionary dictionaryWithObjectsAndKeys:groupName,@"name", [NSString stringWithFormat:@"%@", linkId], @"id", deactivated, @"deactivated",desc, @"desc",photo, @"photo", url, @"url", [NSNumber numberWithInteger:offsetCounter], @"index", nil];
                                [favesGroupsData addObject:object];
                                offsetCounter++;
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if([favesGroupsData count]>0){
                                    countLoaded.title=[NSString stringWithFormat:@"%lu", offsetCounter];
                                    [favesGroupsList reloadData];
                                }
                                [progressSpin stopAnimation:self];
                            });
                    
                    }
                }
        }]resume];
    

    
    
    
    
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row;
    if([[favesGroupsList selectedRowIndexes]count]>0){
        row = [favesGroupsList selectedRow];
        receiverDataForMessage = favesGroupsData[row];
    }
    
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if ([favesGroupsData count]>0) {
        return [favesGroupsData count];
    }
    return 0;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if ([favesGroupsData count]>0) {
        
        GroupsCustomCellView *cell=[[GroupsCustomCellView  alloc]init];
        cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
        cell.nameOfGroup.stringValue = favesGroupsData[row][@"name"];
        cell.descriptionOfGroup.stringValue = favesGroupsData[row][@"desc"];

        NSSize imSize=NSMakeSize(70, 70);
        cell.groupImage.wantsLayer=YES;
        cell.groupImage.layer.cornerRadius=70/2;
        cell.groupImage.layer.masksToBounds=TRUE;
//        if([favesGroupsData[row][@"deactivated"] isEqual:@""]){
//            cell.deactivatedStatus.hidden=YES;
//        }else{
//            cell.deactivatedStatus.stringValue = favesGroupsData[row][@"deactivated"];
//            cell.deactivatedStatus.hidden=NO;
//        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSImage *imagePhoto = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", favesGroupsData[row][@"photo"]]]];
            imagePhoto.size=imSize;
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell.groupImage setImage:imagePhoto];
            });
        });
        
        
        
//        if([favesGroupsData[row][@"online"] isEqual:@"1"]){
//            [cell.online setImage:[NSImage imageNamed:NSImageNameStatusAvailable]];
//            //             cell.lastOnline.stringValue = @"";
//        }
//        else{
//            //             cell.lastOnline.stringValue = favesGroupsData[row][@"last_seen"];
//            [cell.online setImage:[NSImage imageNamed:NSImageNameStatusNone]];
//        }
        
        return cell;
    }
    
    return nil;
}
-(void)loadInfoByURLRequest:(id)sId{
    [groupDataById removeAllObjects];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.getById?group_ids=%@&v=%@&access_token=%@&extended=1&fields=description,city,country,members_count,status,site,start_date,finish_date", sId,  _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *groupGetByIdResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        //        NSLog(@"%@", groupsGetResponse);
        NSString *gdesc;
        NSString *gphoto;
        NSString *gdeactivated;
        NSString *gcity;
        NSString *gcountry;
        NSNumber *gmembersCount;
        NSString *gstatus;
        NSNumber *gstartDate;
        NSNumber *gfinishDate;
        NSNumber *gisAdmin;
        NSNumber *gisClosed;
        NSNumber *gisMember;
        NSString *gsite;
        NSString *gtype;
        NSString *gscreenName;
        for(NSDictionary *i in groupGetByIdResp[@"response"]){
            //            NSLog(@"%@",i);
            gdesc = i[@"description"] && i[@"description"] != nil ? i[@"description"] : @"";
            gphoto = i[@"photo_200"] ? i[@"photo_200"] : i[@"photo_100"] ?  i[@"photo_100"] : i[@"photo_50"];
            gdeactivated = i[@"deactivated"] ? i[@"deactivated"] : @"";
            gmembersCount = i[@"members_count"] && i[@"members_count"] != nil ? i[@"members_count"] : @0;
            gstatus = i[@"status"] && i[@"status"]  != nil ? i[@"status"] : @"";
            gstartDate = i[@"start_date"] && i[@"start_date"]!=nil ? i[@"start_date"] : @0;
            gfinishDate = i[@"finish_date"] && i[@"finish_date"]!=nil ? i[@"finish_date"]  : @0;
            gisClosed =  [i[@"is_closed"] intValue] == 0 ? @NO : @YES;
            gisAdmin =  [i[@"is_admin"] intValue]==0 ? @NO : @YES;
            gisMember =  [i[@"is_member"] intValue]==0 ? @NO : @YES;
            gsite = i[@"site"] && i[@"site"] != nil ? i[@"site"] : @"";
            gcountry = i[@"country"] && i[@"country"][@"title"] != nil ? i[@"country"][@"title"] : @"";
            gtype = i[@"type"] && i[@"type"] != nil ? i[@"type"] : @"";
            gscreenName = i[@"screen_name"] && i[@"screen_name"] != nil ? i[@"screen_name"] : @"";
            gcity = i[@"city"] && i[@"city"][@"title"]!=nil ? i[@"city"][@"title"] : @"";
            //
            
            [groupDataById addObject:@{@"name":i[@"name"], @"id":[NSString stringWithFormat:@"%@",i[@"id"]], @"deactivated":gdeactivated, @"desc":gdesc, @"photo":gphoto, @"members_count":gmembersCount, @"status":gstatus, @"site":gsite, @"start_date":gstartDate, @"country":gcountry, @"city":gcity, @"type":gtype, @"screen_name":gscreenName, @"is_member":gisMember, @"finish_date":gfinishDate}];
            
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSPoint mouseLoc = [NSEvent mouseLocation];
            //    int x = mouseLoc.x;
            int y = mouseLoc.y;
            CGRect rect=CGRectMake(0, y, 0, 0);
            NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
            FullGroupInfoViewController *contr = [story instantiateControllerWithIdentifier:@"GroupFullInfo"];
            contr.receivedData=groupDataById[0];
//            NSLog(@"%@", groupDataById[0]);
            [self presentViewController:contr asPopoverRelativeToRect:rect ofView:favesGroupsList preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
        });
    
    }]resume];
}
@end
