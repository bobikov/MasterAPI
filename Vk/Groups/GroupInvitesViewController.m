//
//  GroupInvitesViewController.m
//  vkapp
//
//  Created by sim on 14.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "GroupInvitesViewController.h"
#import "GroupInvitesCustomCell.h"
@interface GroupInvitesViewController ()<NSTableViewDataSource, NSTableViewDelegate, NSSearchFieldDelegate>

@end

@implementation GroupInvitesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    groupInvitesList.delegate = self;
    groupInvitesList.dataSource = self;
    GroupInvitesData = [[NSMutableArray alloc]init];
    _app = [[appInfo alloc]init];
    [[groupInvitesScrollView contentView]setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(viewDidScroll:) name:NSViewBoundsDidChangeNotification object:nil];
    foundData = [[NSMutableArray alloc]init];
    _stringHighlighter=[[StringHighlighter alloc]init];
    [self loadGroupInvites:NO :NO];
    groupInvitesSearchCount.hidden=YES;
//    groupInvitesSearchBar.delegate=self;
    GroupInvitesDataFiltered = [[NSMutableArray alloc]init];


}
-(void)viewDidAppear{
    
}
- (IBAction)reloadGroupInvites:(id)sender {
    
    [self loadGroupInvites:NO :NO];
}
- (IBAction)goUP:(id)sender {
    [groupInvitesList scrollToBeginningOfDocument:self];
}
- (IBAction)goDown:(id)sender {
    [groupInvitesList scrollToEndOfDocument:self];
}
- (IBAction)joinGroup:(id)sender {
    NSIndexSet *rows;
    
    rows=[groupInvitesList selectedRowIndexes];
    NSMutableArray *selectedGroups=[[NSMutableArray alloc]init];
    void(^joinGroupBlock)()=^void(){
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            [selectedGroups addObject:@{@"id":GroupInvitesData[i][@"id"], @"index":[NSNumber numberWithInteger:i]}];
            
            
        }
        for(NSDictionary *i in selectedGroups){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.join?group_id=%@&v=%@&access_token=%@", i[@"id"], _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *gouprJoinResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
                
                NSLog(@"%@", gouprJoinResponse);
            }]resume];
            dispatch_async(dispatch_get_main_queue(), ^{
                [groupInvitesList deselectRow:[i[@"index"] intValue]];
                [GroupInvitesData removeObjectAtIndex:[i[@"index"]intValue]];
                
            });
            sleep(1);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [groupInvitesList reloadData];
            
        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        joinGroupBlock();
    });
    
}
- (IBAction)leaveGroup:(id)sender {
    
    NSIndexSet *rows;

    rows=[groupInvitesList selectedRowIndexes];
    NSMutableArray *selectedGroups=[[NSMutableArray alloc]init];
    void(^leaveGroupBlock)()=^void(){
        for (NSInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            [selectedGroups addObject:@{@"id":GroupInvitesData[i][@"id"], @"index":[NSNumber numberWithInteger:i]}];
            
            
        }
        for(NSDictionary *i in selectedGroups){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.leave?group_id=%@&v=%@&access_token=%@", i[@"id"], _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *groupLeaveResponse = [NSJSONSerialization JSONObjectWithData: data options:0 error:nil];
               
                NSLog(@"%@", groupLeaveResponse);
            }]resume];
            dispatch_async(dispatch_get_main_queue(), ^{
                [groupInvitesList deselectRow:[i[@"index"] intValue]];
//                [GroupInvitesData removeObjectAtIndex:[i[@"index"]intValue]];
                
            });
            sleep(1);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadGroupInvites:NO :NO];
            
        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        leaveGroupBlock();
    });
    
}


-(void)viewDidScroll:(NSNotification *)notification{
    if([notification.object isEqual:groupInvitesClipView]){
        NSInteger scrollOrigin = [[groupInvitesScrollView contentView]bounds].origin.y+NSMaxY([groupInvitesScrollView visibleRect]);
//        NSInteger numberRowHeights = [groupInvitesList numberOfRows] * [groupInvitesList rowHeight];
        NSInteger boundsHeight = groupInvitesList.bounds.size.height;
//        NSInteger frameHeight = groupInvitesList.frame.size.height;
        if (scrollOrigin == boundsHeight+2) {
            //Refresh here
            //         NSLog(@"The end of table");
//            if([foundData count]<=0){
                [self loadGroupInvites:NO :YES];
//            }
        }
        //        NSLog(@"%ld", scrollOrigin);
        //        NSLog(@"%ld", boundsHeight);
        //    NSLog(@"%fld", frameHeight-300);
        //
    }
}
- (IBAction)filterEvent:(id)sender {
    if(filterEvent.state==1 && foundData){
        GroupInvitesData = tempData;

        [groupInvitesList reloadData];
//        groupInvitesSearchCount.title = [NSString stringWithFormat:@"%lu", [GroupInvitesData count]];
        groupInvitesSearchCount.hidden = YES;
    }
    else{
        [self filterInvites];
    }
}
//- (IBAction)filterPage:(id)sender {
//    foundDataByFilter=YES;
//    [self filterInvites];
//}
- (IBAction)filterGroup:(id)sender {
    if(filterGroup.state==1 && foundData){
        GroupInvitesData = tempData;
        [groupInvitesList reloadData];
//        groupInvitesSearchCount.title = [NSString stringWithFormat:@"%lu", [GroupInvitesData count]];
        groupInvitesSearchCount.hidden = YES;
        
    }
    else{
        [self filterInvites];
    }
}
-(void)filterInvites{
    NSInteger counter=0;
    [groupInvitesList scrollToBeginningOfDocument:self];
//    if([groupInvitesList numberOfRows]>2){
//        [groupInvitesList removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [GroupInvitesData count])] withAnimation:NSTableViewAnimationEffectNone];
//    }
    [foundData removeAllObjects];
    
    tempData = [[NSMutableArray alloc]initWithArray:GroupInvitesData];;
    for(NSDictionary *i in GroupInvitesData){
        
        
        if( filterEvent.state==1 && filterGroup.state==1){
            if([i[@"type"] isEqual:@"event"] || [i[@"type"] isEqual:@"group"]){
                [foundData addObject:i];
                foundDataByFilter=NO;
                counter++;
            }
        }
   
        else if(filterEvent.state==0 && filterGroup.state==1){
            if([i[@"type"] isEqual:@"group"]){
                [foundData addObject:i];
                counter++;
            }
        }
        else if(filterEvent.state==0 && filterGroup.state==0){
            
            [foundData removeAllObjects];
            break;
            
        }
        else if(filterEvent.state==1 && filterGroup.state==0){
            if([i[@"type"] isEqual:@"event"]){
                [foundData addObject:i];
                counter++;
            }
        }

    }
    if([foundData count] > 0){
        [GroupInvitesData removeAllObjects];
        GroupInvitesData= [[NSMutableArray alloc]initWithArray:foundData];
//        arrayController.content=foundData;
        filterData = YES;
//        NSLog(@"%lu", [foundData count]);
//        NSLog(@"%lu", [GroupInvitesData count]);
        groupInvitesSearchCount.title=[NSString stringWithFormat:@"%lu", counter];
        groupInvitesSearchCount.hidden=NO;
        //        subscribersCountInline.title = [NSString stringWithFormat:@"%lu", [subscribersData count]];
        [groupInvitesList reloadData];
        //[self loadSubscribers:NO :NO];
    }

    
}

-(void)loadGroupInvites:(BOOL)searchByName :(BOOL)makeOffset{
    //        filterData=YES;
    if(makeOffset){
        groupInvitesOffset=groupInvitesOffset+20;
    }else{
        [GroupInvitesData removeAllObjects];
        groupInvitesOffset=0;
        offsetCounter=0;
    }
    [progressSpin startAnimation:self];
    __block NSInteger totalCount;
    __block NSInteger startInsertIndex=[GroupInvitesData count];
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.getInvites?v=%@&access_token=%@&extended=1&count=20&offset=%lu&fields=description,city,country",  _app.version, _app.token, groupInvitesOffset]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *groupInvitesGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        //            NSLog(@"%@", groupInvitesGetResponse);
        dispatch_async(dispatch_get_main_queue(), ^{
            groupInvitesCountTotal.title = [NSString stringWithFormat:@"%@", groupInvitesGetResponse[@"response"][@"count"]];
        });
        NSString *desc;
        NSString *photo;
        
        for(NSDictionary *i in groupInvitesGetResponse[@"response"][@"items"]){
            if(i[@"description"]){
                desc=i[@"description"];
            }else{
                desc=@"";
            }
            if(i[@"photo_100"]){
                photo=i[@"photo_100"];
            }else{
                photo=i[@"photo_50"];
            }
            //            [groupsData addObject:@{@"name":i[@"name"],@"photo":photo}];
            //                [GroupInvitesData addObject:@{@"name":i[@"name"], @"desc":desc, @"photo":photo, @"type":i[@"type"]}];
            //                offsetCounter++;
            if( filterEvent.state==1 && filterGroup.state==1){
                if([i[@"type"] isEqual:@"event"] || [i[@"type"] isEqual:@"group"]){
                    [GroupInvitesData addObject:@{@"name":i[@"name"], @"is_closed":i[@"is_closed"], @"id":i[@"id"], @"desc":desc, @"photo":photo, @"type":i[@"type"]}];
                    offsetCounter++;
                    
                }
            }
            else if(filterEvent.state==1 && filterGroup.state==1){
                if( [i[@"type"] isEqual:@"event"] || [i[@"type"] isEqual:@"group"]){
                    [GroupInvitesData addObject:@{@"name":i[@"name"], @"is_closed":i[@"is_closed"], @"desc":desc, @"id":i[@"id"], @"photo":photo, @"type":i[@"type"]}];
                    offsetCounter++;
                }
            }
            else if(filterEvent.state==0 && filterGroup.state==1){
                if([i[@"type"] isEqual:@"group"]){
                    [GroupInvitesData addObject:@{@"name":i[@"name"],@"is_closed":i[@"is_closed"], @"desc":desc, @"id":i[@"id"], @"photo":photo, @"type":i[@"type"]}];
                    offsetCounter++;
                }
            }
            else if(filterEvent.state==0 && filterGroup.state==0){
                if([i[@"type"]isEqual:@"page"]){
                    [GroupInvitesData removeAllObjects];
                    break;
                }
            }
            else if(filterEvent.state==1 && filterGroup.state==0){
                if([i[@"type"] isEqual:@"event"]){
                    [GroupInvitesData addObject:@{@"name":i[@"name"], @"is_closed":i[@"is_closed"], @"id":i[@"id"], @"desc":desc, @"photo":photo, @"type":i[@"type"]}];
                    offsetCounter++;
                }
            }
            
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //                arrayController.content = GroupInvitesData;
            if(makeOffset && groupInvitesOffset < totalCount){
                [groupInvitesList insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(startInsertIndex, [GroupInvitesData count]-1)] withAnimation:NSTableViewAnimationSlideDown];
                [groupInvitesList reloadData];
            }else{
                [groupInvitesList reloadData];
            }
            groupInvitesCountOffset.title = [NSString stringWithFormat:@"%li", offsetCounter];
            
            [progressSpin stopAnimation:self];
        });
    }]resume];
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    
    
}
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [GroupInvitesData count];
}
-(NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    GroupInvitesCustomCell *cell=[[GroupInvitesCustomCell alloc]init];
    cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
    cell.nameOfGroup.stringValue = GroupInvitesData[row][@"name"];
    cell.typeInvite.stringValue = GroupInvitesData[row][@"type"];
//    cell.descriptionOfGroup.stringValue = GroupInvitesData[row][@"desc"];
    [cell.descriptionOfGroup setAllowsEditingTextAttributes:YES];
    cell.descriptionOfGroup.attributedStringValue = [_stringHighlighter highlightStringWithURLs:GroupInvitesData[row][@"desc"] Emails:YES fontSize:12];
    [cell.descriptionOfGroup setFont:[NSFont fontWithName:@"Helvetica" size:12]];
    cell.groupImage.wantsLayer=YES;
    cell.groupImage.layer.masksToBounds=YES;
    cell.groupImage.layer.cornerRadius = 70/2;
    cell.typeInvite.wantsLayer=YES;
    cell.typeInvite.layer.masksToBounds=YES;
    cell.typeInvite.layer.cornerRadius = 8;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:GroupInvitesData[row][@"photo"]]];
         image.size = NSMakeSize(70, 70);
        dispatch_async(dispatch_get_main_queue(), ^{
            [cell.groupImage setImage:image];
        });
    });

    return cell;
}
@end
