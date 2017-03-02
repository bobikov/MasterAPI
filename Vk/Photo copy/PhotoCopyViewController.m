//
//  PhotoCopyViewController.m
//  vkapp
//
//  Created by sim on 20.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "PhotoCopyViewController.h"
#import "appInfo.h"
@interface PhotoCopyViewController () <NSTableViewDataSource,NSTableViewDelegate, NSTextFieldDelegate>
typedef void(^OnComplete) (NSMutableArray *);
typedef void(^OnCompleteCreateAlbum)(BOOL isNewAlbumCreated);
typedef void(^OnCompleteGetOwnerName)(NSString *ownerName);
typedef void(^OnCompleteGetAlbumFromInfo)(NSString *albumFromName);
typedef void(^OnCompleteCreateNewAlbumName)(NSString *albumName);
-(void)createAlbum:(OnCompleteCreateAlbum)completion;
-(void)getAllPhotoInAlbum:(NSString*)album completion:(OnComplete)completion;
-(void)getOwnerName:(OnCompleteGetOwnerName)completion;
-(void)createNewAlbumName:(OnCompleteCreateNewAlbumName)completion;
@end

@implementation PhotoCopyViewController
@synthesize arrayController1, arrayController2;
- (void)viewDidLoad {
    [super viewDidLoad];
    toTableView.delegate=self;
    toTableView.dataSource=self;
    fromTableView.delegate=self;
    fromTableView.dataSource=self;
    personalAlbums = [[NSMutableArray alloc]init];
    fromOwnerAlbums = [[NSMutableArray alloc]init];
    [privacyList selectItemAtIndex:2];
    _app = [[appInfo alloc]init];
    [progressSpin startAnimation:self];
    captchaHandler = [[VKCaptchaHandler alloc]init];
    groupsPopupData = [[NSMutableArray alloc]init];
    handleUpdate = [[updatesHandler alloc]init];
    [groupsPopupList removeAllItems];
    [groupsPopupData addObject:_app.person];
    [groupsPopupList addItemWithTitle:@"Personal"];
    publicId.delegate=self;
    [self setControlButtonsState];
    [self loadGroupsPopup];

}
-(void)controlTextDidChange:(NSNotification *)obj{
    if(obj.object == publicId){
        [self setControlButtonsState];
    }
}
- (void)viewDidAppear{
    [self photoAlbumsLoad:_app.person :NO];
}
- (IBAction)showAlbumsFrom:(id)sender {
    [self photoAlbumsLoad:publicId.stringValue :NO];
    NSLog(@"%@", publicId.stringValue);
}
- (IBAction)groupsPopupListAction:(id)sender {
    [self photoAlbumsLoad:[groupsPopupData objectAtIndex:[groupsPopupList indexOfSelectedItem]] :NO];
    ownerID=groupsPopupData[[groupsPopupList indexOfSelectedItem]];
    publicId.stringValue = ownerID;
    
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
- (void)loadGroupsPopup{
    
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
            [groupsPopupData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
            [groupsPopupList addItemWithTitle:i[@"name"]];
            
        }
    }]resume];
}

- (void)photoAlbumsLoad:(NSString*)owner :(BOOL)searchByName{
    [progressSpin startAnimation:self];
    if (![owner isEqual:_app.person]){
        
        [fromOwnerAlbums removeAllObjects];
        [fromOwnerAlbums addObject:@{@"title":@"profile",@"id":@"profile"}];
        [fromOwnerAlbums addObject:@{@"title":@"wall", @"id":@"wall"}];
    }
    else{
        [personalAlbums removeAllObjects];
    }
    void (^loadAlbums)() = ^() {
        //        __block NSArray *found;
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.getAlbums?owner_id=%@&v=%@&access_token=%@", owner, _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error){
                NSLog(@"Check your connection");
            }
            else{
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([jsonData objectForKey:@"error"]){
                    if([jsonData[@"error"][@"error_code"] intValue] == 15){
                        //                        [fromOwnerAlbums addObject:@{@"title":@"profile",@"id":@"profile"}];
                        //                        [fromOwnerAlbums addObject:@{@"title":@"wall", @"id":@"wall"}];
                        arrayController2.content=fromOwnerAlbums;
                        [fromTableView reloadData];
                    }
                    NSLog(@"%@:%@", jsonData[@"error"][@"error_code"], jsonData[@"error"][@"error_msg"]);
                }
                else{
                    for (NSDictionary *a in jsonData[@"response"][@"items"]){
                        NSDictionary *object=@{@"id":[NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@",a[@"id"]]], @"title":a[@"title"]};
                        if([owner isEqual:_app.person]){
                            //if (searchByName){
                            // found = [regex matchesInString:a[@"title"] options:0 range:NSMakeRange(0, [a[@"title"] length])];
                            //  if([found count]>0){
                            //   [photoAlbums addObject:dataDict];
                            // }
                            //
                            //}
                            //else{
                            [personalAlbums addObject:object];
                            //}
                            
                        }
                        else{
                            //if (searchByName){
                            // found = [regex matchesInString:a[@"title"] options:0 range:NSMakeRange(0, [a[@"title"] length])];
                            // if([found count]>0){
                            //  [fromOwnerAlbums addObject:dataDict];
                            // }
                            //
                            //
                            // }
                            // else{
                            [fromOwnerAlbums addObject:object];
                        }
                        //}
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([owner isEqual:_app.person]){
                            arrayController1.content=personalAlbums;
                            [toTableView reloadData];
                        }
                        else{
                            arrayController2.content=fromOwnerAlbums;
                            [fromTableView reloadData];
                        }
                    });
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressSpin stopAnimation:self];
            });
        }]resume];
        //[photoAlbums removeAllObjects];
    };
    loadAlbums();
}

- (IBAction)stopCopy:(id)sender {
    stopped=YES;
    runPhotoCopy=NO;
    [self setControlButtonsState];
}
- (IBAction)resetAction:(id)sender {
    albumToCopyFrom = nil;
    albumToCopyTo = nil;
    albumFromId.stringValue = @"";
    publicId.stringValue = @"";
    count.stringValue = @"";
    progressLabel.stringValue = @"0 / 0";
    progress.doubleValue = 0;
    albumToId.stringValue = @"";
}

- (IBAction)copyAction:(id)sender {
    stopped=NO;
    ownerID = publicId.stringValue;
    isCopying=YES;
    [self setControlButtonsState];
    __block void (^copyFromWall)(NSString *source, id targetAlbum, BOOL captchaCopyPhoto, BOOL captchaEditPhoto, NSInteger offset, NSString *captcha_sid, NSString *captcha_key);
    __block void (^copyFromAlbum)(NSString *source, id targetAlbum, BOOL captchaCopyPhoto, BOOL captchaEditPhoto, NSInteger offset, NSString *captcha_sid, NSString *captcha_key);
    
    copyFromWall = ^(NSString *source, id targetAlbum, BOOL captchaCopyPhoto, BOOL captchaEditPhoto, NSInteger offset, NSString *captcha_sid, NSString *captcha_key){
        
        stopped=NO;
        step=0;
        
        stoppedAttachLoop=NO;
        captchaOpened=NO;
        if(offset>0){
            step=offset;
        }

        if(![albumToId.stringValue isEqual:@""]){
            targetAlbumId = albumToId.stringValue;
            NSLog(@"Target album id %@", targetAlbumId);
        }
        
        publicIdFrom = publicId.stringValue;
        countPhotos = [count.stringValue intValue];
        runPhotoCopy = YES;
        NSString *url;
        progress.maxValue=countPhotos;
        privacy_view= privacyList.stringValue;

        if(!captchaCopyPhoto && !captchaEditPhoto){
//            if([handleUpdate readFromFile:@"photo" source:source publicId:publicIdFrom]){
//                updateDate = [NSString stringWithFormat:@"%@", [handleUpdate readFromFile:@"photo" source:source publicId:publicIdFrom] ];
//                NSLog(@"Now update date %@", updateDate);
//            }
//            else{
//                NSLog(@"Update date did not set.");
//            }
            if ([publicIdFrom intValue]<0){
                publicIdIntTemp = abs([publicIdFrom intValue]);
//                publicIdPhotoFromPlus = [NSString stringWithFormat:@"%d", publicIdIntTemp];
//                publicIdPhotoFrom = publicIdPhotoFromPlus;
                url = @"https://api.vk.com/method/groups.getById?group_id=%@&access_token=%@&v=%@";
            }
            else{
//                publicIdPhotoFrom = publicIdFrom;
                url=@"https://api.vk.com/method/users.get?user_ids=%@&fields=nickname&access_token=%@&v=%@";
                
            }
            
        }
        
        if(captchaEditPhoto || captchaCopyPhoto){
            targetAlbumId = targetAlbum;
            NSLog(@"Target album now:%@\nOffset:%lu\nCaptcha_sid:%@\nCaptcha_key:%@", targetAlbumId, step, captcha_sid, captcha_key);
        }
        else{
            //        if(!updateDate){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.get?owner_id=%@&count=%d&v=%@&access_token=%@", publicIdFrom, 2,  _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSDictionary *wallGetData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                publicName = newAlbumName ? [newAlbumName stringByRemovingPercentEncoding] : @"namenamename";
                //            NSLog(@"Public If from %@",publicIdFrom);
                //            NSLog(@"Public Name %@",publicName);
                //            NSLog(@"Date %@", wallGetData[@"response"][@"items"][0][@"date"]);
                NSString *newDate;
                for (NSDictionary *i in wallGetData[@"response"][@"items"]){
                    if(!i[@"is_pinned"]){
                        newDate=[NSString stringWithFormat:@"%@", i[@"date"]];
                    }
                    
                }
                
//                [handleUpdate writeToFile:@"photo" source:source newDataToFile:@{@"id":publicIdFrom, @"name":publicName, @"date":newDate}];
                
                
            }]resume];
        }
        //        }
        
        while (step<countPhotos){
            if(!stopped){
                semaphore = dispatch_semaphore_create(0);
                NSURLSessionDataTask *getWall=[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.get?owner_id=%@&count=%d&offset=%ld&v=%@&access_token=%@", publicIdFrom, 1, step, _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    NSDictionary *jsonData=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    for (NSDictionary *i in jsonData[@"response"][@"items"]){
                        if(i[@"is_pinned"] && !stopped){
                            continue;
                        }
                        if(updateDate){
                            
                            if([updateDate isEqualToString: [NSString stringWithFormat:@"%@", i[@"date"]]] ){
                                NSLog(@"Stopped by update date.");
                                stopped=YES;
                                break;
                            }
                        }
                        if(captureText.state==1){
                            capturedText = i[@"text"];
                            capturedText = [capturedText stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
                        }
                        if (i[@"attachments"]){
                            for (NSDictionary *a in i[@"attachments"]){
                                if(!stoppedAttachLoop){
                                    if ([a[@"type"] isEqual:@"photo"]){
                                        if(!stopped){
                                            if(captchaCopyPhoto){
                                                urlPhotoCopy = [NSString stringWithFormat:@"https://api.vk.com/method/photos.copy?owner_id=%@&photo_id=%@&access_token=%@&v=%@&captcha_sid=%@&captcha_key=%@", a[@"photo"][@"owner_id"], a[@"photo"][@"id"], _app.token, _app.version, captcha_sid, captcha_key];
                                            }
                                            else{
                                                urlPhotoCopy = [NSString stringWithFormat:@"https://api.vk.com/method/photos.copy?owner_id=%@&photo_id=%@&access_token=%@&v=%@", a[@"photo"][@"owner_id"], a[@"photo"][@"id"], _app.token, _app.version];
                                            }
                                            
                                            NSURLSessionDataTask *copyPhoto = [_app.session dataTaskWithURL:[NSURL URLWithString:urlPhotoCopy] completionHandler:^(NSData  *data, NSURLResponse *response, NSError *error) {
                                                NSDictionary *copyPhotoResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                photoIdToCopy = copyPhotoResponse[@"response"];
                                                if(error){
                                                    stopped=YES;
                                                    stoppedAttachLoop=YES;
                                                    NSLog(@"Photo copy process interrupted. Bad Connection");
                                                    return;
                                                }
                                                if (copyPhotoResponse[@"error"]){
                                                    if([copyPhotoResponse[@"error"][@"error_code"] intValue] == 14){
                                                        
                                                        stopped=YES;
                                                        
                                                        
                                                    }
                                                    NSLog(@"%@", copyPhotoResponse[@"error"][@"error_code"]);
                                                }
                                                else{
                                                    if(photoIdToCopy){
                                                        NSLog(@"Photo Id to copy: %@", photoIdToCopy);
                                                        if (copyPhotoResponse[@"response"] != nil){
                                                            NSURLSessionDataTask *movePhoto = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.move?owner_id=%@&target_album_id=%@&photo_id=%@&v=%@&access_token=%@", _app.person, targetAlbumId,  copyPhotoResponse[@"response"], _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                if(error){
                                                                    NSLog(@"Move photo interrrupted. Bad Connection");
                                                                    return;
                                                                }
                                                                NSDictionary *movePhotoResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                if(movePhotoResponse[@"error"]){
                                                                    NSLog(@"%@", movePhotoResponse[@"error"]);
                                                                    stopped=YES;
                                                                    stoppedAttachLoop=YES;
                                                                }
                                                                else{
                                                                    NSLog(@"Photo sucessfully moved:%@", movePhotoResponse[@"response"]);
                                                                    
                                                                }
                                                                
                                                            }];
                                                            
                                                            [movePhoto resume];
                                                            sleep(1);
                                                            
                                                            if(captureText.state==1 && capturedText ){
                                                                if(captchaEditPhoto){
                                                                    urlPhotoEdit =[NSString stringWithFormat:@"https://api.vk.com/method/photos.edit?owner_id=%@&photo_id=%@&caption=%@&v=%@&access_token=%@&captcha_sid=%@&captcha_key=%@", _app.person, photoIdToCopy, capturedText, _app.version, _app.token, captcha_sid, captcha_key];
                                                                }
                                                                else{
                                                                    urlPhotoEdit =[NSString stringWithFormat:@"https://api.vk.com/method/photos.edit?owner_id=%@&photo_id=%@&caption=%@&v=%@&access_token=%@", _app.person, photoIdToCopy, capturedText, _app.version, _app.token];
                                                                }
                                                                [[_app.session  dataTaskWithURL:[NSURL URLWithString:urlPhotoEdit]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                                    if(error){
                                                                        NSLog(@"Photo  edit interrupted. Bad Connection");
                                                                        return;
                                                                    }
                                                                    NSDictionary *editPhotoResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                    if (editPhotoResponse[@"error"]){
                                                                        NSLog(@"Photo edit error:%@:%@", editPhotoResponse[@"error"][@"error_code"], editPhotoResponse[@"error"][@"error_msg"]);
                                                                        if([editPhotoResponse[@"error"][@"error_code"] intValue] == 14){
                                                                            stopped=YES;
                                                                            stoppedAttachLoop=YES;
                                                                            __block NSString *captchaKey;
                                                                            
                                                                            if(!captchaOpened){
                                                                                
                                                                                
                                                                                captchaOpened=YES;

                                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                                    
                                                                                    NSInteger result = [[captchaHandler handleCaptcha:editPhotoResponse[@"error"][@"captcha_img"]] runModal];
                                                                                    if (result == NSAlertFirstButtonReturn){
                                                                                        captchaKey=[captchaHandler readCode];
                                                                                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                                            copyFromWall(source, targetAlbumId, NO, YES, step-3, editPhotoResponse[@"error"][@"captcha_sid"], captchaKey);
                                                                                            captchaOpened=NO;
                                                                                        });
                                                                                    }
                                                                                    if (result == NSAlertSecondButtonReturn){
                                                                                        
                                                                                    }
                                                                                });
                                                                            }
                                                                        }
                                                                        
                                                                    }
                                                                    else{
                                                                        NSLog(@"Photo sucessfully edited:%@", editPhotoResponse[@"response"]);
                                                                    }
                                                                }] resume];
                                                                usleep(900000);
                                                            }
                                                        }
                                                        else{
                                                            stopped=YES;
                                                            NSLog(@"Photo Id is unknown");
                                                        }
                                                    }
                                                    
                                                }
                                            }];
                                            [copyPhoto resume];
                                            sleep(1);
                                        }
                                    }
                                }
                                else{
                                    break;
                                    stopped = YES;
                                }
                            }
                        }
                        
                    }
                    dispatch_semaphore_signal(semaphore);
                }];
                [getWall resume];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_semaphore_signal(semaphore);
                step++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!stopped){
                        progress.doubleValue=(float) step+1;
                        progressLabel.stringValue = [NSString stringWithFormat:@"%ld / %li", step, countPhotos];
                    }
                });
                
            }
            else{
                isCopying=NO;
                break;
            }
        }
        isCopying=NO;
        runPhotoCopy=NO;
        
    };
    
    copyFromAlbum = ^(NSString *source, id targetAlbum, BOOL captchaCopyPhoto, BOOL captchaEditPhoto, NSInteger offset, NSString *captcha_sid, NSString *captcha_key){
        step=0;
        if(!captchaCopyPhoto && !captchaEditPhoto){
            //            if([handleUpdate readFromFile:@"photo" source:source publicId:publicIdFrom]){
            //                updateDate = [NSString stringWithFormat:@"%@", [handleUpdate readFromFile:@"photo" source:source publicId:publicIdFrom] ];
            //                NSLog(@"Now update date %@", updateDate);
            //            }
            //            else{
            //                NSLog(@"Update date did not set.");
            //            }
           
//                 newAlbumName =[[NSString stringWithFormat:@"%@", nameGet] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
            
            
        }
        if(captchaEditPhoto || captchaCopyPhoto){
            targetAlbumId = targetAlbum;
            NSLog(@"Target album now:%@\nOffset:%lu\nCaptcha_sid:%@\nCaptcha_key:%@", targetAlbumId, step, captcha_sid, captcha_key);
        }
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.get?owner_id=%@&album_id=%@&count=1&offset=%li&access_token=%@&v=%@", ownerID, albumToCopyFrom, step, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *getPhotosCountResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            countPhotos = [getPhotosCountResponse[@"response"][@"count"] intValue];
        }]resume];
        sleep(1);
        progress.maxValue = countPhotos;
        while(step<countPhotos){
            if(!stopped){
                semaphore = dispatch_semaphore_create(0);
                [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.get?owner_id=%@&album_id=%@&count=1&offset=%li&access_token=%@&v=%@", ownerID, albumToCopyFrom, step, _app.token, _app.version]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSDictionary *getPhotosResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                    NSLog(@"%@", getPhotosResponse);
                    dispatch_async(dispatch_get_main_queue(),^{
                        progressLabel.hidden=NO;
                    });
                    for (NSDictionary *i in getPhotosResponse[@"response"][@"items"]){
                        if(captchaCopyPhoto){
                            urlPhotoCopy = [NSString stringWithFormat:@"https://api.vk.com/method/photos.copy?owner_id=%@&photo_id=%@&access_token=%@&v=%@&captcha_sid=%@&captcha_key=%@", i[@"owner_id"], i[@"id"], _app.token, _app.version, captcha_sid, captcha_key];
                        }
                        else{
                            urlPhotoCopy = [NSString stringWithFormat:@"https://api.vk.com/method/photos.copy?owner_id=%@&photo_id=%@&access_token=%@&v=%@", i[@"owner_id"], i[@"id"], _app.token, _app.version];
                        }
                        NSLog(@"%@", i[@"id"]);
                        
                        [[_app.session dataTaskWithURL:[NSURL URLWithString:urlPhotoCopy] completionHandler:^(NSData  *data, NSURLResponse *response, NSError *error) {
                            NSDictionary *copyPhotoResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            photoIdToCopy = copyPhotoResponse[@"response"];
                            if(error){
                                stopped=YES;
                                //stoppedAttachLoop=YES;
                                NSLog(@"Photo copy process interrupted. Bad Connection");
                                return;
                            }
                            if (copyPhotoResponse[@"error"]){
                                if([copyPhotoResponse[@"error"][@"error_code"] intValue] == 14){
                                    stopped=YES;
                                }
                                NSLog(@"%@", copyPhotoResponse[@"error"][@"error_code"]);
                            }
                            else{
                                if(photoIdToCopy){
                                    NSLog(@"Photo Id to copy: %@", photoIdToCopy);
                                    if (copyPhotoResponse[@"response"] != nil){
                                        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.move?owner_id=%@&target_album_id=%@&photo_id=%@&v=%@&access_token=%@", _app.person, targetAlbumId,  copyPhotoResponse[@"response"], _app.version, _app.token]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                            if(error){
                                                NSLog(@"Move photo interrrupted. Bad Connection");
                                                return;
                                            }
                                            NSDictionary *movePhotoResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                            if(movePhotoResponse[@"error"]){
                                                NSLog(@"%@", movePhotoResponse[@"error"]);
                                                if([movePhotoResponse[@"error"][@"error_code"] intValue]==14){
                                                    if(!stopped){
                                                        stopped=YES;
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            NSInteger result = [[captchaHandler handleCaptcha:movePhotoResponse[@"error"][@"captcha_img"]]runModal];
                                                            if(result == NSAlertFirstButtonReturn){
                                                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                                    copyFromAlbum(@"album", targetAlbumId, YES, NO, offset, movePhotoResponse[@"error"][@"captcha_sid"],[captchaHandler readCode]);
                                                                });
                                                            }
                                                        });
                                                    }
                                                }
                                            }
                                            else{
                                                NSLog(@"Photo sucessfully moved:%@", movePhotoResponse[@"response"]);
                                                sleep(2);
                                                dispatch_semaphore_signal(semaphore);
                                            }
                                        }]resume];
                                        if(captureText.state  && capturedText ){
                                            if(captchaEditPhoto){
                                                urlPhotoEdit =[NSString stringWithFormat:@"https://api.vk.com/method/photos.edit?owner_id=%@&photo_id=%@&caption=%@&v=%@&access_token=%@&captcha_sid=%@&captcha_key=%@", _app.person, photoIdToCopy, capturedText, _app.version, _app.token, captcha_sid, captcha_key];
                                            }
                                            else{
                                                urlPhotoEdit =[NSString stringWithFormat:@"https://api.vk.com/method/photos.edit?owner_id=%@&photo_id=%@&caption=%@&v=%@&access_token=%@", _app.person, photoIdToCopy, capturedText, _app.version, _app.token];
                                            }
                                            [[_app.session  dataTaskWithURL:[NSURL URLWithString:urlPhotoEdit]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if(error){
                                                    NSLog(@"Photo  edit interrupted. Bad Connection");
                                                    return;
                                                }
                                                NSDictionary *editPhotoResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                if (editPhotoResponse[@"error"]){
                                                    NSLog(@"Photo edit error:%@:%@", editPhotoResponse[@"error"][@"error_code"], editPhotoResponse[@"error"][@"error_msg"]);
                                                    if([editPhotoResponse[@"error"][@"error_code"] intValue] == 14){
                                                        stopped=YES;
                                                        //                                                    stoppedAttachLoop=YES;
                                                        __block NSString *captchaKey;
                                                        
                                                        if(!captchaOpened){
                                                            captchaOpened=YES;
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                
                                                                NSInteger result = [[captchaHandler handleCaptcha:editPhotoResponse[@"error"][@"captcha_img"] ]runModal];
                                                                if (result == NSAlertFirstButtonReturn){
                                                                    captchaKey = [captchaHandler readCode];
                                                                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                                                        copyFromWall(source, targetAlbumId, NO, YES, step-3, editPhotoResponse[@"error"][@"captcha_sid"], captchaKey);
                                                                        captchaOpened=NO;
                                                                    });
                                                                }
                                                                if (result == NSAlertSecondButtonReturn){
                                                                    
                                                                }
                                                            });
                                                        }
                                                    }
                                                }
                                                else{
                                                    NSLog(@"Photo sucessfully edited:%@", editPhotoResponse[@"response"]);
                                                }
                                            }] resume];
                                            usleep(900000);
                                        }
                                    }
                                    else{
                                        stopped=YES;
                                        NSLog(@"Photo Id is unknown");
                                    }
                                }
                            }
                        }]resume];
                    }
                }]resume];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_semaphore_signal(semaphore);
                step++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!stopped){
                        progress.doubleValue=step;
                        progressLabel.stringValue = [NSString stringWithFormat:@"%ld / %li", step, countPhotos];
                    }
                });
            }
            else{
                break;
                stopped = YES;
            }
        }
        runPhotoCopy=NO;
        dispatch_async(dispatch_get_main_queue(),^{
            [self setControlButtonsState];
        });
    };
    
    
    
    if (runPhotoCopy==YES){
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = [NSString stringWithFormat:@"%@", @"Copy photo"];
        alert.informativeText = [NSString stringWithFormat:@"%@", @"You have already running photo copy proccess.\n Press stop and try again."];
        [alert runModal];
    }
    else{
        if((albumToCopyFrom && ![albumToCopyFrom isEqual:@"wall"]) && ownerID){
            stop.enabled=YES;
            copy.enabled=NO;
            NSLog(@"copy started");
            runPhotoCopy=YES;
            if(albumToCopyTo){
                NSLog(@"ALBUM TO COPY TO %@", albumToCopyTo);
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    copyFromAlbum(@"album", nil, NO, NO, 0, @"", @"");
                });
            }
            else{
               NSLog(@"ALBUM TO COPY TO %@", albumToCopyTo);
                [self createAlbum:^(BOOL isNewAlbumCreated){
                    if(isNewAlbumCreated){
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            copyFromAlbum(@"album", nil, NO, NO, 0, @"", @"");
                        });
                    }
                }];
            }
        }
        else if((albumToCopyFrom && [albumToCopyFrom isEqual:@"wall"]) && ownerID){
               if(albumToCopyTo){
                   NSLog(@"ALBUM TO COPY TO %@", albumToCopyTo);
                   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                       copyFromWall(@"wall", nil, NO, NO, 0, @"", @"");
                   });
               }
               else{
                   [self createAlbum:^(BOOL isNewAlbumCreated){
                       if(isNewAlbumCreated){
                           NSLog(@"ALBUM TO COPY TO %@", albumToCopyTo);
                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                               copyFromWall(@"wall", nil, NO, NO, 0, @"", @"");
                           });
                       }
                   }];
               }
        }
        else{
            NSLog(@"Some fields are empty.");
        }
    }
}
//- (void)setControlButtonsState{
//    stop.enabled=runPhotoCopy;
//    copy.enabled=[fromTableView selectedRow];
//}

- (void)getAllPhotoInAlbum:(NSString*)album completion:(OnComplete)completion{
    
    
}

- (void)getOwnerName:(OnCompleteGetOwnerName)completion{
    NSString *url;
    NSString *groupIDpositive;
    if ([ownerID intValue]<0){
        
        groupIDpositive = [NSString stringWithFormat:@"%i", abs([ownerID intValue])];
        url = [NSString stringWithFormat:@"https://api.vk.com/method/groups.getById?group_id=%@&access_token=%@&v=%@", groupIDpositive, _app.token, _app.version];
    }
    else{
       
        url=[NSString stringWithFormat:@"https://api.vk.com/method/users.get?user_ids=%@&fields=nickname&access_token=%@&v=%@",  ownerID, _app.token, _app.version];
    }
    
   [[_app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
       if(data){
           NSDictionary *getNameResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
           //NSLog(@"%@", getNameResponse);
           NSString *nameGet;
           
           if ([ownerID intValue]<0){
               nameGet = getNameResponse[@"response"][0][@"name"];
           }
           else{
               nameGet = [NSString stringWithFormat:@"%@ %@", getNameResponse[@"response"][0][@"first_name"], getNameResponse[@"response"][0][@"last_name"]];
           }
           //NSLog(@"%@", nameGet);
           completion(nameGet);
       }
    }]resume];

}
- (void)createNewAlbumName:(OnCompleteCreateNewAlbumName)completion{
    [self getOwnerName:^(NSString *ownerName) {
        newAlbumName=[[NSString stringWithFormat:@"%@ | %@", ownerName, albumFromTitle] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        completion(newAlbumName);
    }];
}
- (void)createAlbum:(OnCompleteCreateAlbum)completion{
    [self createNewAlbumName:^(NSString *albumName) {
        if(albumName){
            NSLog(@"NEW ALBUM NAME %@", albumName);
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.createAlbum?owner_id=%@&access_token=%@&v=%@&privacy_view=%@&title=%@", _app.person, _app.token, _app.version, privacy_view, newAlbumName]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if(data){
                    NSDictionary *createAlbumResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    targetAlbumId = [NSString stringWithFormat:@"%@", createAlbumResponse[@"response"][@"id"]];
                    NSLog(@"Album created. Target album %@", targetAlbumId);
                    if(createAlbumResponse[@"response"]){
                        dispatch_async(dispatch_get_main_queue(),^{
                           [self photoAlbumsLoad:_app.person :NO];
                        });
                    }
                    completion(createAlbumResponse[@"response"]?1:0);
                }
            }]resume];
        }
    }];
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification{
    if(notification.object == toTableView){
        if([toTableView selectedRow]>=0){
            albumToCopyTo = personalAlbums[[toTableView selectedRow]][@"id"];
            targetAlbumId = albumToCopyTo;
            albumToId.stringValue=albumToCopyTo;
        }else{
            albumToCopyTo = nil;
            albumToId.stringValue=@"";
        }
    }
    else if(notification.object == fromTableView){
        if([fromTableView selectedRow]>=0 && [fromOwnerAlbums count]>0 ){
            albumToCopyFrom = fromOwnerAlbums[[fromTableView selectedRow]][@"id"];
            albumFromTitle = fromOwnerAlbums[[fromTableView selectedRow]][@"title"];
            albumFromId.stringValue=albumToCopyFrom;
            //        NSLog(@"%@", fromOwnerAlbums[[fromTableView selectedRow]]);
            
        }else{
            albumToCopyFrom = nil;
            albumFromId.stringValue=@"";
        }
    }

    NSLog(@"TO %@", albumToCopyTo);
    NSLog(@"FROM %@", albumToCopyFrom);
//    if([[fromTableView selectedRowIndexes]count]==0){
//        copy.enabled=NO;
//    }else{
//        copy.enabled=YES;
//    }
    [self setControlButtonsState];
}

@end
