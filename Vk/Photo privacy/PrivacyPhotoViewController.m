//
//  PrivacyPhotoViewController.m
//  vkapp
//
//  Created by sim on 22.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "PrivacyPhotoViewController.h"

@interface PrivacyPhotoViewController ()<NSTableViewDataSource, NSTableViewDelegate>

@end

@implementation PrivacyPhotoViewController
@synthesize arrayController, SearchResultsController;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [albumsTable setDelegate:self];
    [albumsTable setDataSource:self];
    //    scrollViewAlbumTables.wantsLayer = TRUE;
    //    scrollViewAlbumTables.layer.cornerRadius = 6;
    _app=[[appInfo alloc]init];
    photoAlbums = [[NSMutableArray alloc]init];
    [privacyList selectItemAtIndex:2];
    [progressSpin startAnimation:self];
    tempData = [[NSMutableArray alloc]init];
    foundData = [[NSMutableArray alloc]init];
    groupsPopupData = [[NSMutableArray alloc]init];
    
    [groupsPopupList removeAllItems];
    [self loadGroupsPopup];
    [groupsPopupData addObject:_app.person];
    [groupsPopupList addItemWithTitle:@"Personal"];
    [progressSpin startAnimation:self];
    [self loadAlbums:_app.person];
    _captchaHandler = [[VKCaptchaHandler alloc]init];
}
- (void)loadGroupsPopup{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
                [groupsPopupData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [groupsPopupList addItemWithTitle:i[@"name"]];
                });
            }
        }]resume];
    });
}
- (IBAction)loadAlbumsByAdmin:(id)sender {
    NSLog(@"%@", [groupsPopupData objectAtIndex:[groupsPopupList indexOfSelectedItem]]);
    [self loadAlbums:[NSString stringWithFormat:@"%@", [groupsPopupData objectAtIndex:[groupsPopupList indexOfSelectedItem]]]];
}
- (IBAction)filterNobody:(id)sender {
    [self filterAlbumsByPrivacy];
}
- (IBAction)filterFriends:(id)sender {
    [self filterAlbumsByPrivacy];
}
- (IBAction)filterAll:(id)sender {
    [self filterAlbumsByPrivacy];
}
- (void)filterAlbumsByPrivacy{
    NSInteger counter=0;
    [albumsTable scrollToBeginningOfDocument:self];
    //    if([groupInvitesList numberOfRows]>2){
    //        [groupInvitesList removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [GroupInvitesData count])] withAnimation:NSTableViewAnimationEffectNone];
    //    }
    [foundData removeAllObjects];
    
    tempData = [[NSMutableArray alloc]initWithArray:photoAlbums];
    for(NSDictionary *i in photoAlbums){
        
        
        if( filterNobody.state==1 && filterFriends.state==1 && filterAll.state==1) {
            if([i[@"privacy"] isEqual: @"only_me"]  || [i[@"privacy"] isEqual: @"friends"] || [i[@"privacy"] isEqual: @"all"]  ){
                [foundData addObject:i];
                counter++;
            }
        }
        //
        else if(filterNobody.state==0 && filterFriends.state==1 && filterAll.state==1){
            if([i[@"privacy"] isEqual: @"friends"] || [i[@"privacy"] isEqual: @"all"]  ){
                [foundData addObject:i];
                counter++;
            }
        }
        else if(filterNobody.state==0 && filterFriends.state==0 && filterAll.state==1){
            if([i[@"privacy"] isEqual: @"all"]  ){
                [foundData addObject:i];
                counter++;
            }
            
        }
        else if(filterNobody.state==0 && filterFriends.state==0 && filterAll.state==0){
            [foundData removeAllObjects];
            //            break;
        }
        else if(filterNobody.state==1 && filterFriends.state==1 && filterAll.state==0){
            if([i[@"privacy"] isEqual: @"only_me"] || [i[@"privacy"] isEqual: @"friends"] ){
                [foundData addObject:i];
                counter++;
            }
            
        }
        else if(filterNobody.state==1 && filterFriends.state==0 && filterAll.state==0){
            if([i[@"privacy"] isEqual: @"only_me"]  ){
                [foundData addObject:i];
                counter++;
            }
            
        }
        else if(filterNobody.state==0 && filterFriends.state==1 && filterAll.state==0){
            if([i[@"privacy"] isEqual: @"friends"]  ){
                [foundData addObject:i];
                counter++;
            }
            
        }
        else if(filterNobody.state==1 && filterFriends.state==0 && filterAll.state==1){
            if([i[@"privacy"] isEqual: @"only_me"] || [i[@"privacy"] isEqual: @"all"]  ){
                [foundData addObject:i];
                counter++;
            }
            
        }
        
        
        
    }
    if([foundData count] > 0){
        //        [photoAlbums removeAllObjects];
        //        photoAlbums = [[NSMutableArray alloc]initWithArray:foundData];
        arrayController.content=foundData;
        //        filterData = YES;
        //        NSLog(@"%lu", [foundData count]);
        //        NSLog(@"%lu", [GroupInvitesData count]);
        //        searchCountResults.title=[NSString stringWithFormat:@"%lu", counter];
        //        searchCountResults.hidden=NO;
        //        subscribersCountInline.title = [NSString stringWithFormat:@"%lu", [subscribersData count]];
        [albumsTable reloadData];
        //[self loadSubscribers:NO :NO];
    }
    
}
- (void)viewDidAppear{
    
}
- (void)loadAlbums:(NSString *)owner{
    [photoAlbums removeAllObjects];
    //     [progressSpin startAnimation:self];
    NSURLSessionDataTask *dataTask2=[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.getAlbums?owner_id=%@&v=%@&access_token=%@", owner, _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error){
            NSLog(@"Connection error");
        }
        else{
            
            NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if(jsonData[@"error"]){
                NSLog(@"%@", jsonData[@"error"]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [progressSpin stopAnimation:self];
                });
            }else{
                //                NSLog(@"%@", jsonData[@"count"]);
                if([jsonData[@"response"][@"count"] intValue]>1){
                    NSLog(@"Found and more than one");
                    for (NSDictionary *i in jsonData[@"response"][@"items"]){
                        NSDictionary *dictData=@{@"id":i[@"id"], @"title":i[@"title"], @"privacy":i[@"privacy_view"][0]};
                        [photoAlbums addObject:dictData];
                        
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        arrayController.content = photoAlbums;
                        [albumsTable reloadData];
                        [progressSpin stopAnimation:self];
                        
                    });
                }
                else{
                    NSLog(@"Albums not found");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [progressSpin stopAnimation:self];
                    });
                }
                
                
            }
            
        }
    }];
    [dataTask2 resume];
    
}
- (IBAction)changePrivacy:(id)sender {
    
    NSIndexSet *rows=[albumsTable selectedRowIndexes];
    NSMutableArray *selectedAlbums;
    selectedAlbums = [[NSMutableArray alloc]init];
    __block NSString *url;
    __block void (^changePrivacyBlock)(BOOL captcha, NSString *captchaSid, NSString *captchaKey);
    changePrivacyBlock = ^void(BOOL captcha, NSString *captchaSid, NSString *captchaKey){
        [progressSpin startAnimation:self];
        for (NSUInteger i = [rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex:i]) {
            //            [selectedAlbums addObject:@{@"id":arrayController.content[i][@"id"], @"index":[NSNumber numberWithInteger:i]}];
            //            [selectedAlbums addObject:[arrayController.content[i] representedObject]];
            //             NSLog(@"%@", [arrayController.content representedObject]);
        }
        
        
        for(NSDictionary *i in [arrayController selectedObjects]){
            if(!stopped){
                if(captcha){
                    url =[NSString stringWithFormat:@"https://api.vk.com/method/photos.editAlbum?owner_id=%@&v=%@&access_token=%@&album_id=%@&privacy_view=%@&captcha_sid=%@&captcha_key=%@", _app.person, _app.version, _app.token,  i[@"id"], privacyList.stringValue, captchaSid, captchaKey];
                }else{
                    url =[NSString stringWithFormat:@"https://api.vk.com/method/photos.editAlbum?owner_id=%@&v=%@&access_token=%@&album_id=%@&privacy_view=%@", _app.person, _app.version, _app.token,  i[@"id"], privacyList.stringValue];
                }
                NSURLSessionDataTask *dataTask=[_app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if (error){
                        NSLog(@"Connection error");
                    }
                    else{
                        NSDictionary *changePrivacyResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        if (changePrivacyResponse[@"error"]){
                            if([changePrivacyResponse[@"error"][@"error_code"] intValue]==14){
                                stopped=YES;
                                NSLog(@"%@:%@", changePrivacyResponse[@"error"][@"error_code"], changePrivacyResponse[@"error"][@"error_msg"]);
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    NSInteger result = [[_captchaHandler handleCaptcha:changePrivacyResponse[@"error"][@"captcha_img"]]runModal];
                                    if (result == NSAlertFirstButtonReturn){
                                        //                                        NSLog(@"%@", enterCode.stringValue);
                                        NSLog(@"%@", changePrivacyResponse[@"error"][@"captcha_sid"]);
                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                            changePrivacyBlock(YES, changePrivacyResponse[@"error"][@"captcha_sid"], _captchaHandler.enterCode.stringValue);
                                        });
                                    }
                                    if (result == NSAlertSecondButtonReturn){
                                        
                                    }
                                });
                            }else{
                                NSLog(@"%@", changePrivacyResponse[@"error"]);
                            }
                            
                        }
                        else{
                            //                            for (NSDictionary *a in changePrivacyResponse){
                            NSLog(@"%@", changePrivacyResponse);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [albumsTable deselectRow:[arrayController selectionIndex]];
                            });
                            //                            }
                            
                        }
                    }
                }];
                [dataTask resume];
                usleep(500000);
            }else{
                break;
            }
        }
        if(!stopped && [rows count]>0){
            //            [self loadAlbums];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadAlbums:_app.person];
                [progressSpin stopAnimation:self];
            });
        }
        
        
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        changePrivacyBlock(NO, @"", @"");
        
    });
}




//-(void)tableViewSelectionDidChange:(NSNotification *)notification{
//
//}
//-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
//    if([photoAlbums count]>0){
//        return [photoAlbums count];
//    }
//    return 0;
//}
//-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
//    NSTableCellView *cell;
//    if([photoAlbums count]>0){
//        if([tableColumn.title isEqualToString:@"Title"]){
//            cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
//            [cell.textField setStringValue:photoAlbums[row][@"title"] ];
//            return cell;
//        }
//        else if([tableColumn.title isEqualToString:@"Privacy"]) {
//            cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
//            [cell.textField setStringValue:photoAlbums[row][@"privacy"] ];
//            return cell;
//        }
//    }
//    return nil;
//}

@end
