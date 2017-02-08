//
//  VideoCopyViewController.m
//  vkapp
//
//  Created by sim on 20.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "VideoCopyViewController.h"

@interface VideoCopyViewController ()<NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>
typedef void(^OnCompleteCreateAlbum)(BOOL isNewAlbumCreated);
typedef void(^OnCompleteGetOwnerName)(NSString *ownerName);
typedef void(^OnCompleteGetAlbumFromInfo)(NSString *albumFromName);
typedef void(^OnCompleteCreateNewAlbumName)(NSString *albumName);
-(void)createAlbum:(OnCompleteCreateAlbum)completion;
//-(void)getAllPhotoInAlbum:(NSString*)album completion:(OnComplete)completion;
//-(void)getOwnerName:(OnCompleteGetOwnerName)completion;
-(void)createNewAlbumName:(OnCompleteCreateNewAlbumName)completion;
@end

@implementation VideoCopyViewController

@synthesize  ArrayController1,ArrayController2;
- (void)viewDidLoad {
    [super viewDidLoad];
    ids =[[NSMutableArray alloc]init];
    personalAlbums = [[NSMutableArray alloc]init];
    fromOwnerAlbums = [[NSMutableArray alloc]init];
    _captchaHandler = [[VKCaptchaHandler alloc]init];
    _app = [[appInfo alloc]init];
    [progressSpin startAnimation:self];
    [privacyList selectItemAtIndex:2];
    [self setControlButtonsState];
    publicId.delegate=self;
}
-(void)controlTextDidChange:(NSNotification *)obj{
    if(obj.object == publicId){
        [self setControlButtonsState];
    }
}
-(void)viewDidAppear{
      [self videoAlbumsLoad:@"copy" publicId:_app.person];
}
- (IBAction)showAlbumsFromAction:(id)sender {
    [progressSpin startAnimation:self];
    [self videoAlbumsLoad:@"copy" publicId:publicId.stringValue];
}
- (IBAction)copyAction:(id)sender {

    privacy =  privacyList.stringValue;
    selectedAlbumId = albumFromId.stringValue;
    selectedPublicId = publicId.stringValue;
    NSRegularExpression *regex=[NSRegularExpression regularExpressionWithPattern:@"[\\W0-9]" options:0 error:nil];
    __block void (^copyFromVideobox)(NSString *, BOOL, NSInteger, NSString *, NSString *);
    __block void (^copyFromWall)(NSString *, BOOL, NSInteger, NSString *, NSString *);
 
    __block NSMutableArray *Albums1000=[[NSMutableArray alloc]init];;
    __block NSMutableArray *AlbumsNo1000=[[NSMutableArray alloc]init];
    
    isCopying=YES;
    [self setControlButtonsState];
    
    copyFromWall=^(NSString *targetAlbum, BOOL captcha, NSInteger offset, NSString *captcha_sid, NSString *captcha_key){
      
        __block NSInteger step = 0;
         NSString *countVar = count.stringValue;
        __block NSString *url;
        stopFlag = NO;
        __block BOOL captchaOpened = NO;
//        __block NSString *url;
        __block bool captcha_state;
        __block bool nextLoop=NO;
        if (offset>0)
            step = offset-2;
        if (captcha){
            captcha_state = captcha;
        }
        else{
            captcha_state = NO;
        }
        if(![albumToId.stringValue  isEqual:@""]){
            targetVideoAlbumId = albumToId.stringValue;
        }
        progress.maxValue=(float)[countVar intValue];
        NSLog(@"Target album: %@", targetAlbum);
        NSLog(@"Offset: %lu", step);
        NSLog(@"Captcha sid: %@", captcha_sid);
        NSLog(@"Captcha key: %@", captcha_key);
  
        while (step<[countVar intValue]){
            if (!stopFlag){
                if(nextLoop){
                    nextLoop=NO;
                    continue;
                    
                }
                 dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.get?owner_id=%@&offset=%lu&count=1&v=%@&access_token=%@", selectedPublicId, step, _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSDictionary *wallGetData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if(wallGetData[@"error"]){
                        NSLog(@"%@:%@", wallGetData[@"error"][@"error_code"], wallGetData[@"error"][@"error_msg"]);
                    }
                    else{
                        for (NSDictionary *i in wallGetData[@"response"][@"items"]){
                        
                            if (i[@"attachments"]){
                                for (NSDictionary *a in i[@"attachments"]){
                                    
                                    if ([a[@"type"] isEqual:@"video"]){

                                        if (captcha_state){
                                            url =[NSString stringWithFormat:@"https://api.vk.com/method/video.addToAlbum?target_id=%@&album_id=%@&owner_id=%@&video_id=%@&v=%@&access_token=%@&offset=%lu&captcha_sid=%@&captcha_key=%@", _app.person, targetVideoAlbumId, a[@"video"][@"owner_id"], a[@"video"][@"id"], _app.version, _app.token, step, captcha_sid, captcha_key];
                                        }
                                        else{
                                            url = [NSString stringWithFormat:@"https://api.vk.com/method/video.addToAlbum?target_id=%@&album_id=%@&owner_id=%@&video_id=%@&v=%@&access_token=%@", _app.person, targetVideoAlbumId, a[@"video"][@"owner_id"], a[@"video"][@"id"], _app.version, _app.token ];
                                        }
                                        NSLog(@"Title:%@ Owner:%@", a[@"video"][@"title"], a[@"video"][@"owner_id"]);
                                        [[_app.session dataTaskWithURL:[NSURL URLWithString: url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                            NSDictionary *addToAlbumData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                            if(addToAlbumData[@"error"]){
                                                NSLog(@"%@ %@", addToAlbumData[@"error"][@"error_code"], addToAlbumData[@"error"][@"error_msg"]);
                                                if([addToAlbumData[@"error"][@"error_code"] intValue] == 14){
                                                    stopFlag=YES;
                                                    if(!captchaOpened){
                                                        captchaOpened=YES;
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            NSInteger result = [[_captchaHandler handleCaptcha:addToAlbumData[@"error"][@"captcha_img"]] runModal];
                                                            if(result == NSAlertFirstButtonReturn){
                                                                captcha_state=YES;
                                                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                    copyFromWall( targetVideoAlbumId, captcha_state, step, addToAlbumData[@"error"][@"captcha_sid"], _captchaHandler.enterCode.stringValue);
                                                                    captchaOpened=NO;
                                                                });
                                                            }
                                                            else if(result == NSAlertSecondButtonReturn) {
//                                                                dispatch_semaphore_signal(semaphore);
                                                            }
                                                        });
                                                    }
                                                   
                                                }
                                                else if([addToAlbumData[@"error"][@"error_code"] intValue] == 800){
                                                    nextLoop=YES;
                                                    NSLog(@"Next loop");
                                                    
                                                }
                                            }
                                            else if ([addToAlbumData[@"response"] intValue]==1){
                                                NSLog(@"Video copied sucessfully");

                                            }
                                        }] resume];
                                        sleep(1);
                                        
                                    }
                                }
                            }
                        }
                    }
                dispatch_semaphore_signal(semaphore);
                }] resume];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_semaphore_signal(semaphore);
                step++;
                sleep(1);
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress.doubleValue=(float)step;
                    progressLabel.stringValue = [NSString stringWithFormat:@"%lu / %@", step, countVar];
                    
                });
               
            }
            else{
                isCopying=NO;
                break;
            }
        }
        isCopying=NO;
    };
    
    copyFromVideobox = ^void(NSString *targetAlbum, BOOL captcha, NSInteger offset, NSString *captcha_sid, NSString *captcha_key){
        NSLog(@"%@", targetAlbum);
        __block NSInteger step = 0;
        stopFlag = NO;
        __block NSString *url;
        __block bool captcha_state;
        __block bool nextLoop=NO;
        __block bool captchaOpened=NO;
        if (offset>0)
            step = offset-1;
        if (captcha){
            captcha_state = captcha;
        }
        else{
            captcha_state = NO;
        }
        NSString *countVar = count.stringValue;
        progress.maxValue=(float)[countVar intValue];
        
        NSLog(@"Offset: %lu captcha_sid: %@\ncaptcha_key:%@", step, captcha_sid, captcha_key);
        while(step < [countVar intValue]){
            
            if (!stopFlag){
                if(nextLoop){
                    nextLoop=NO;
                    continue;
                    
                }
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.get?owner_id=%@&count=1&offset=%lu&v=%@&access_token=%@", selectedPublicId, step, _app.version, _app.token]]completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    NSDictionary *videoGetData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if(videoGetData[@"error"]){
                        NSLog(@"%@:%@", videoGetData[@"error"][@"error_code"], videoGetData[@"error"][@"error_msg"]);
                    }
                    else{
                        for (NSDictionary *i in videoGetData[@"response"][@"items"]){
//
                            if (captcha_state){
                                url =[NSString stringWithFormat:@"https://api.vk.com/method/video.addToAlbum?target_id=%@&album_id=%@&owner_id=%@&video_id=%@&v=%@&access_token=%@&offset=%lu&captcha_sid=%@&captcha_key=%@", _app.person, targetVideoAlbumId, i[@"owner_id"], i[@"id"], _app.version, _app.token, offset, captcha_sid, captcha_key];
                            }
                            else{
                                url = [NSString stringWithFormat:@"https://api.vk.com/method/video.addToAlbum?target_id=%@&album_id=%@&owner_id=%@&video_id=%@&v=%@&access_token=%@", _app.person, targetVideoAlbumId, i[@"owner_id"], i[@"id"], _app.version, _app.token ];
                            }
                            
                            NSLog(@"%@", i[@"title"]);
                           [[_app.session dataTaskWithURL:[NSURL URLWithString: url ] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                NSDictionary *addToAlbumData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                               if (addToAlbumData[@"error"]) {
                                   NSLog(@"%@:%@", addToAlbumData[@"error"][@"error_code"], addToAlbumData[@"error"][@"error_msg"] );
                                   if([addToAlbumData[@"error"][@"error_code"] intValue] == 14){
                                       stopFlag=YES;
                                       if(!captchaOpened){
                                           captchaOpened=YES;
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               NSInteger result = [[_captchaHandler handleCaptcha:addToAlbumData[@"error"][@"captcha_img"]] runModal];
                                               if(result == NSAlertFirstButtonReturn){
                                                   captcha_state=YES;
                                                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                       copyFromVideobox( targetVideoAlbumId, captcha_state, step, addToAlbumData[@"error"][@"captcha_sid"], _captchaHandler.enterCode.stringValue);
                                                       captchaOpened=NO;
                                                   });
                                               }
                                               else if(result == NSAlertSecondButtonReturn) {
                                                   //dispatch_semaphore_signal(semaphore);
                                               }
                                           });
                                       }
                                   }
                                   else if([addToAlbumData[@"error"][@"error_code"] intValue] == 800){
                                       nextLoop=YES;
                                        NSLog(@"Next loop");
                                   }
                               }
                               else if ([addToAlbumData[@"response"] intValue]==1){
                                   NSLog(@"Video copied sucessfully");
                                   
                               }
                             
                            }] resume];
                            sleep(1);
                        }
                        dispatch_semaphore_signal(semaphore);
                    }
                }] resume];
                

                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_semaphore_signal(semaphore);
                step++;
                //                NSLog(@"%lu", step);
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress.doubleValue=(float)step;
                    progressLabel.stringValue = [NSString stringWithFormat:@"%lu / %@", step, countVar];
                    
                });
              
//                sleep(1);
            }
            else{
                isCopying=NO;
                break;
            }
        }
        isCopying=NO;
    };
   

    if (![albumToId.stringValue isEqual:@""]){
        targetVideoAlbumId = albumToId.stringValue;
        if([selectedAlbumId  isEqual: @"wall"]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               
                copyFromWall(targetVideoAlbumId, NO, 0, @"", @"");
            });
        }
        else if ([selectedAlbumId isEqual: @"videobox"]){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                copyFromVideobox(targetVideoAlbumId, NO, 0, @"", @"");
            });
        }
    }else{
        //    NSLog(@"%@\n %@", videoPublicTitleNewAlbum, title2);
        for (NSDictionary *i in personalAlbums){
            
            title1 = [regex stringByReplacingMatchesInString:i[@"title"] options:0 range:NSMakeRange(0, [i[@"title"] length]) withTemplate:@""];
            
            if([title1 isEqualToString: title2]){
                [ids addObject:@{@"id":i[@"id"], @"title":i[@"title"], @"count":i[@"count"]}];
                //            NSLog(@"%@", ids);
            }
        }
        
        if([ids count]!=0){
            for(NSDictionary *i in ids){
                if([i[@"count"] intValue]==1000){
                    [Albums1000 addObject:i[@"id"]];
                }
                else{
                    [AlbumsNo1000 addObject:i[@"id"]];
                }
            }
            //        for (NSDictionary *i in ids){
            if([AlbumsNo1000 count]>0){
                targetVideoAlbumId=AlbumsNo1000[0];
                NSLog(@"Ablum not created. Now target album id: %@", targetVideoAlbumId );
                //                NSLog(@"%@", i);
                if([selectedAlbumId  isEqual: @"wall"]){
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       
                        copyFromWall(targetVideoAlbumId, NO, 0, @"", @"");
                        
                    });
                    
                }
                else if ([selectedAlbumId isEqual: @"videobox"]){
                  
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        copyFromVideobox(targetVideoAlbumId, NO, 0, @"", @"");
                    });
                }
            }
            else{
                if(!targetVideoAlbumId){
                    [self createAlbum:^(BOOL isNewAlbumCreated) {
                        if(isNewAlbumCreated){
                            if([selectedAlbumId  isEqual: @"wall"]){
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    copyFromWall(targetVideoAlbumId, NO, 0, @"", @"");
                                });
                            }
                            else if ([selectedAlbumId isEqual: @"videobox"]){
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    copyFromVideobox(targetVideoAlbumId, NO, 0, @"", @"");
                                });
                            }
                        }
                    }];
                }
            }
        }
        else{
            [self createAlbum:^(BOOL isNewAlbumCreated) {
                if(isNewAlbumCreated){
                    title2 = [regex stringByReplacingMatchesInString:videoPublicTitleNewAlbum options:0 range:NSMakeRange(0, [videoPublicTitleNewAlbum length]) withTemplate:@""];
                    NSLog(@"Ablum created. Now target album id: %@", targetVideoAlbumId );
                    if([selectedAlbumId  isEqual: @"wall"]){
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            copyFromWall(targetVideoAlbumId, NO, 0, @"", @"");
                        });
                    }
                    else if ([selectedAlbumId isEqual: @"videobox"]){
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            copyFromVideobox(targetVideoAlbumId, NO, 0, @"", @"");
                        });
                    }
                }
            }];
        }
    }
    
    [self videoAlbumsLoad:@"copy" publicId:_app.person];

}
- (IBAction)stopAction:(id)sender {
    stopFlag = YES;
    
}
- (IBAction)resetAction:(id)sender {
    publicId.stringValue=@"";
    albumFromId.stringValue=@"";
    albumToId.stringValue=@"";
    count.stringValue=@"";
    progressLabel.stringValue = @"0 / 0";
    progress.doubleValue=0.0;
}
-(void)setControlButtonsState{
    if(isCopying){
        stop.enabled=YES;
        copy.enabled=NO;
        reset.enabled=NO;
    }else{
        stop.enabled=NO;
        copy.enabled=![publicId.stringValue isEqual:@""];
        reset.enabled=YES;
    }
}
-(void)videoAlbumsLoad:(NSString *)source publicId:(NSString *)public{
    fromTableView.delegate = self;
    fromTableView.dataSource = self;
    toTableView.delegate = self;
    toTableView.dataSource = self;

    __block int step = 0;
    if (![public isEqual:_app.person]){
        [fromOwnerAlbums removeAllObjects];
        [fromOwnerAlbums addObject:@{@"title":@"videobox"}];
        [fromOwnerAlbums addObject:@{@"title":@"wall"}];
    }
    else{
        [personalAlbums removeAllObjects];
        
    }
    void (^loadAlbums)()=^{
        __block NSString *totalAlbums;
        NSURLSessionDataTask *getAlbums1 = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.getAlbums?owner_id=%@&v=%@&access_token=%@&extended=1&count=5", public, _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *jsonData1 = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            totalAlbums=[NSString stringWithFormat:@"%@", jsonData1[@"response"][@"count"]];
            if([totalAlbums intValue]!=0){
                while (step < [totalAlbums intValue]){
                    NSURLSessionDataTask *getAlbums = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.getAlbums?owner_id=%@&v=%@&access_token=%@&extended=1&count=100&offset=%d", public, _app.version, _app.token, step]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        for (NSDictionary *i in jsonData[@"response"][@"items"]){

                            if(public == _app.person){
                                [personalAlbums addObject:@{@"id": i[@"id"], @"title":i[@"title"], @"privacy":i[@"privacy"][0], @"count":i[@"count"]}];
                            }
                            else{
                                [fromOwnerAlbums addObject:@{@"id": i[@"id"], @"title":i[@"title"], @"count":i[@"count"]}];
                            }
                        }

                        dispatch_async(dispatch_get_main_queue(), ^{
                            if ([source  isEqual: @"copy"] && ![public isEqual:_app.person]){
                                ArrayController2.content=fromOwnerAlbums;
                                [fromTableView reloadData];
                            }
                            if([source isEqual:@"copy"] && [public isEqual:_app.person]){
                                ArrayController1.content=personalAlbums;
                                [toTableView reloadData];
                            }
                            [progressSpin stopAnimation:self];
                        });
                     
                    }];
                    [getAlbums resume];
                    step+=100;
                    usleep(500000);
                    
                }
              
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([source  isEqual: @"copy"] && ![public isEqual:_app.person] ){
                         ArrayController2.content=fromOwnerAlbums;
                        [fromTableView reloadData];
                    }
                    if([source isEqual:@"copy"] && [public isEqual:_app.person]){
                        ArrayController1.content=personalAlbums;
                        [toTableView reloadData];
                        
                      
                    }
                    [progressSpin stopAnimation:self];
                });
            }
        }];
        [getAlbums1 resume];
        
    };
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        loadAlbums();
    });
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSInteger row;
    NSString *item;
    if([notification.object isEqual: toTableView]){
        if([[toTableView selectedRowIndexes]count]>0){
            row = [toTableView selectedRow];
            item = [NSString stringWithFormat:@"%@", personalAlbums[row][@"id"]];
            albumToId.stringValue = item;
            title2=ArrayController1.content[row][@"title"];
        }
    }
    else if([notification.object isEqual: fromTableView]){
        if([[fromTableView selectedRowIndexes]count]>0){
            row = [fromTableView selectedRow];
            if (row == 0){
                item=@"videobox";
            }
            else if(row == 1){
                item=@"wall";
            }
            else{
                
                item = [NSString stringWithFormat:@"%@", fromOwnerAlbums[row][@"id"]];
            }
            albumFromId.stringValue = item;
        }
        
    }
}




-(void)createNewAlbumName:(OnCompleteCreateNewAlbumName)completion{
   [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.getById?group_id=%d&fields=description&v=%@&access_token=%@", abs([selectedPublicId intValue]), _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        videoPublicTitleNewAlbum = jsonData[@"response"][0][@"name"];
       if([ids count]!=0){
           videoPublicTitleNewAlbum =  [[NSString stringWithFormat:@"%@ %lu", videoPublicTitleNewAlbum, [ids count]+1] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
       }else{
           videoPublicTitleNewAlbum =  [[NSString stringWithFormat:@"%@ %@", videoPublicTitleNewAlbum, @1] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
       }
       completion(videoPublicTitleNewAlbum);
       
    }]resume];
   
}
-(void)createAlbum:(OnCompleteCreateAlbum)completion{
    [self createNewAlbumName:^(NSString *albumName) {
        if(albumName){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/video.addAlbum?owner_id=%@&title=%@&v=%@&access_token=%@&privacy=%@", _app.person, videoPublicTitleNewAlbum, _app.version, _app.token, privacy]]completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                targetVideoAlbumId = jsonData[@"response"][@"album_id"];
                completion(targetVideoAlbumId?1:0);
                NSLog(@"Target album id: %@", targetVideoAlbumId);
            }]resume];
        }
    }];

    
}
//-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
//    if([tableView isEqual:toTableView]){
//        if([personalAlbums count]>0){
//            return [personalAlbums count];
//        }
//    }
//    else if([tableView isEqual:fromTableView]){
//        if ([fromOwnerAlbums count]>0) {
//            return [fromOwnerAlbums count];
//        }
//    }
//    return 0;
//}
//-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:

//(NSTableColumn *)tableColumn row:(NSInteger)row{
//    if([tableView isEqual:toTableView]){
//        if ([personalAlbums count]>0){
//            NSTableCellView *cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
//            [cell.textField setStringValue:personalAlbums[row][@"title"] ];
//            return cell;
//        }
//    }
//    else if([tableView isEqual: fromTableView]){
//        if([fromOwnerAlbums count]>0) {
//            NSTableCellView *cell = [tableView makeViewWithIdentifier:@"MainCell" owner:self];
//            [cell.textField setStringValue:fromOwnerAlbums[row][@"title"]];
//            return cell;
//        }
//        
//    }
//    return nil;
//    
//    return nil;
//}
@end
