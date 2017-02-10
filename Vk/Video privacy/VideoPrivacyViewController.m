//
//  VideoPrivacyViewController.m
//  vkapp
//
//  Created by sim on 03.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "VideoPrivacyViewController.h"

@interface VideoPrivacyViewController ()<NSTableViewDataSource, NSTableViewDelegate>

@end

@implementation VideoPrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    videoAlbumsList.delegate=self;
    videoAlbumsList.dataSource=self;
    videoAlbums = [[NSMutableArray alloc]init];
    _app = [[appInfo alloc]init];
    [groupsPopupList removeAllItems];
    groupsPopupData=[[NSMutableArray alloc]init];
    [groupsPopupData addObject:_app.person];
    [groupsPopupList addItemWithTitle:@"Personal"];
    [self loadGroupsPopup];
    [self loadAlbums:_app.person];
    foundData = [[NSMutableArray alloc]init];
    tempData = [[NSMutableArray alloc]init];
    _captchaHandler = [[VKCaptchaHandler alloc]init];
//    videoAlbumsList.enclosingScrollView.wantsLayer=YES;
//    videoAlbumsList.enclosingScrollView.layer.cornerRadius=6;
}
- (void)viewDidAppear{
    
}
- (void)loadGroupsPopup{
    
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(data){
            for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
                [groupsPopupData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
                [groupsPopupList addItemWithTitle:i[@"name"]];
                
            }
        }
    }]resume];
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
    //    [albumsTable scrollToBeginningOfDocument:self];
    //    if([groupInvitesList numberOfRows]>2){
    //        [groupInvitesList removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [GroupInvitesData count])] withAnimation:NSTableViewAnimationEffectNone];
    //    }
    [foundData removeAllObjects];
    
    tempData = [[NSMutableArray alloc]initWithArray:videoAlbums];
    for(NSDictionary *i in videoAlbums){
        
        
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
        _arrayController.content=foundData;
        //        filterData = YES;
        //        NSLog(@"%lu", [foundData count]);
        //        NSLog(@"%lu", [GroupInvitesData count]);
        //        searchCountResults.title=[NSString stringWithFormat:@"%lu", counter];
        //        searchCountResults.hidden=NO;
        //        subscribersCountInline.title = [NSString stringWithFormat:@"%lu", [subscribersData count]];
        [videoAlbumsList reloadData];
        //[self loadSubscribers:NO :NO];
    }
    
}
- (IBAction)loadByAdminGroups:(id)sender {
    NSLog(@"%@",[groupsPopupData objectAtIndex:[groupsPopupList indexOfSelectedItem]] );
    [self loadAlbums:[groupsPopupData objectAtIndex:[groupsPopupList indexOfSelectedItem]]];
}
- (IBAction)deleteAlbumButtonAction:(id)sender {
    __block BOOL stopped;
    __block NSIndexSet *rows;
    __block NSString *url;
    __block void (^removeAlbumBlock)(BOOL captcha, NSString *captchaSid, NSString *captchaKey);
    removeAlbumBlock = ^void(BOOL captcha, NSString *captchaSid, NSString *captchaKey){
        stopped=NO;
        rows=[videoAlbumsList selectedRowIndexes];
        for (NSInteger i = captcha==YES ?[rows firstIndex]-1:[rows firstIndex]; i != NSNotFound; i = [rows indexGreaterThanIndex: i]){
            
            if(!stopped){
                if (captcha){
                    url = [NSString stringWithFormat:@"https://api.vk.com/method/video.deleteAlbum?owner_id=%@&album_id=%@&v=%@&access_token=%@&captcha_sid=%@&captcha_key=%@", _app.person, videoAlbums[i][@"id"], _app.version, _app.token, captchaSid, captchaKey];
                }
                else{
                    url = [NSString stringWithFormat:@"https://api.vk.com/method/video.deleteAlbum?owner_id=%@&album_id=%@&v=%@&access_token=%@", _app.person, videoAlbums[i][@"id"], _app.version, _app.token];
                }
                NSURLSessionDataTask *deleteAlbum = [_app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [videoAlbumsList deselectRow:i];
                    });
                    if(data){
                        if(error){
                            NSLog(@"Connection error");
                            return;
                        }
                        else{
                            NSDictionary *deleteAlbumResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            if(deleteAlbumResponse[@"error"]){
                                if([deleteAlbumResponse[@"error"][@"error_code"] intValue]==14){
                                    stopped=YES;
                                    NSLog(@"%@:%@", deleteAlbumResponse[@"error"][@"error_code"], deleteAlbumResponse[@"error"][@"error_msg"]);
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        NSInteger result = [[_captchaHandler handleCaptcha:deleteAlbumResponse[@"error"][@"captcha_img"]]runModal];
                                        if (result == NSAlertFirstButtonReturn){
                                            //                                            NSLog(@"%@", enterCode.stringValue);
                                            NSLog(@"%@", deleteAlbumResponse[@"error"][@"captcha_sid"]);
                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                removeAlbumBlock(YES, deleteAlbumResponse[@"error"][@"captcha_sid"], _captchaHandler.enterCode.stringValue);
                                            });
                                        }
                                        if (result == NSAlertSecondButtonReturn){
                                            
                                        }
                                    });
                                }
                                else{
                                    NSLog(@"%@", deleteAlbumResponse[@"error"]);
                                }
                            }
                        }
                        
                        NSLog(@"%lu", i);
                    }
                }];
                [deleteAlbum resume];
                sleep(1);
                
            }
            else{
                break;
            }
            
        }
        //        dispatch_async(dispatch_get_main_queue(), ^{
        if(!stopped && [rows count]>0){
            [self loadAlbums:_app.person];
        }
        
        
        //        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        removeAlbumBlock(NO, @"", @"");
    });
    
    
}
- (IBAction)changePrivacyAction:(id)sender {
    __block BOOL stopped;
    __block NSIndexSet *rows;
    __block NSString *url;
    __block NSString *privacy = privacyList.stringValue;
    __block void (^changePrivacyBlock)(BOOL captcha, NSString *captchaSid, NSString *captchaKey);
    changePrivacyBlock = ^void(BOOL captcha, NSString *captchaSid, NSString *captchaKey){
        stopped=NO;
        rows=[videoAlbumsList selectedRowIndexes];
        for (NSDictionary *i in [_arrayController selectedObjects]){
            
            if(!stopped){
                NSString *title = [i[@"title"] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet] ];
                if (captcha){
                    url = [NSString stringWithFormat:@"https://api.vk.com/method/video.editAlbum?owner_id=%@&album_id=%@&v=%@&access_token=%@&privacy=%@&title=%@&captcha_sid=%@&captcha_key=%@", _app.person, i[@"id"], _app.version, _app.token, privacy, title, captchaSid, captchaKey];
                }
                else{
                    url = [NSString stringWithFormat:@"https://api.vk.com/method/video.editAlbum?owner_id=%@&album_id=%@&v=%@&access_token=%@&privacy=%@&title=%@", _app.person, i[@"id"], _app.version, _app.token, privacy, title];
                }
                NSURLSessionDataTask *changePrivacy = [_app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [videoAlbumsList deselectRow:[videoAlbumsList selectedRow]];
                    });
                    if(data){
                        if(error){
                            NSLog(@"Connection error");
                            return;
                        }
                        else{
                            NSDictionary *changePrivacyResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            if(data){
                                if(changePrivacyResponse[@"error"]){
                                    if([changePrivacyResponse[@"error"][@"error_code"] intValue]==14){
                                        stopped=YES;
                                        NSLog(@"%@:%@", changePrivacyResponse[@"error"][@"error_code"], changePrivacyResponse[@"error"][@"error_msg"]);
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            
                                            NSInteger result = [[_captchaHandler handleCaptcha:changePrivacyResponse[@"error"][@"captcha_img"]]runModal];
                                            if (result == NSAlertFirstButtonReturn){
                                                //                                                NSLog(@"%@", enterCode.stringValue);
                                                NSLog(@"%@", changePrivacyResponse[@"error"][@"captcha_sid"]);
                                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                    changePrivacyBlock(YES, changePrivacyResponse[@"error"][@"captcha_sid"], _captchaHandler.enterCode.stringValue);
                                                });
                                            }
                                            if (result == NSAlertSecondButtonReturn){
                                                
                                            }
                                        });
                                    }
                                    else{
                                        NSLog(@"%@", changePrivacyResponse[@"error"]);
                                    }
                                }
                            }
                            
                            //                            NSLog(@"%@", i);
                        }
                    }
                }];
                [changePrivacy resume];
                sleep(1);
                
            }
            else{
                break;
            }
            
        }
        //        dispatch_async(dispatch_get_main_queue(), ^{
        if(!stopped && [rows count]>0){
            [self loadAlbums:_app.person];
        }
        
        
        //        });
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        changePrivacyBlock(NO, @"", @"");
    });
    
    
    
    
}
- (void) loadAlbums:(NSString *)owner{
    [progressLoad startAnimation:self];
    [videoAlbums removeAllObjects];
    __block NSString *totalAlbums;
    __block int step = 0;
    void (^load)()=^{
        NSURLSessionDataTask *getAlbumsTotal = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.getAlbums?owner_id=%@&v=%@&access_token=%@&extended=1&count=5", owner, _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(data){
                NSDictionary *getAlbumsResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                totalAlbums=[NSString stringWithFormat:@"%@", getAlbumsResponse[@"response"][@"count"]];
                if(getAlbumsResponse[@"error"]){
                    NSLog(@"%@,", getAlbumsResponse[@"error"]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [progressLoad stopAnimation:self];
                    });
                }else{
                    
                    if([totalAlbums intValue]!=0){
                        while (step < [totalAlbums intValue]){
                            NSURLSessionDataTask *getAlbums = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.getAlbums?owner_id=%@&v=%@&access_token=%@&extended=1&count=100&offset=%d", owner, _app.version, _app.token, step]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                
                                for (NSDictionary *i in jsonData[@"response"][@"items"]){
                                    
                                    [videoAlbums addObject:@{@"id": i[@"id"], @"title":i[@"title"],@"privacy":[ owner isEqual:_app.person] ? i[@"privacy"][0]:@"", @"count":i[@"count"]}];
                                }
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if([videoAlbums count]>0){
                                        _arrayController.content=videoAlbums;
                                        [videoAlbumsList reloadData];
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [progressLoad stopAnimation:self];
                                        });
                                    }
                                });
                            }];
                            
                            [getAlbums resume];
                            step+=100;
                            usleep(500000);
                            
                        }
                        
                    }
                    else{
                        NSLog(@"No vieo albums");
                        NSLog(@"%@", getAlbumsResponse);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [progressLoad stopAnimation:self];
                        });
                        
                    }
                }
            }
        }];
        [getAlbumsTotal resume];
    };
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        load();
    });
}


@end
