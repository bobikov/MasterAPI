//
//  PhotoCopyViewController.m
//  vkapp
//
//  Created by sim on 20.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "PhotoCopyViewController.h"
#import "appInfo.h"
@interface PhotoCopyViewController () <NSTableViewDataSource>

@end

@implementation PhotoCopyViewController
@synthesize arrayController1, arrayController2;
- (void)viewDidLoad {
    [super viewDidLoad];
    photoAlbums = [[NSMutableArray alloc]init];
    photoAlbums2 = [[NSMutableArray alloc]init];
    [privacyList selectItemAtIndex:2];
    _app = [[appInfo alloc]init];
    [progressSpin startAnimation:self];
    _captchaHandler = [[VKCaptchaHandler alloc]init];
    groupsPopupData = [[NSMutableArray alloc]init];
    handleUpdate = [[updatesHandler alloc]init];
    [groupsPopupList removeAllItems];
    [groupsPopupData addObject:_app.person];
    [groupsPopupList addItemWithTitle:@"Personal"];
    [self loadGroupsPopup];

}
-(void)viewDidAppear{
    [self photoAlbumsLoad:_app.person :NO];
}
- (IBAction)showAlbumsFrom:(id)sender {
    [self photoAlbumsLoad:publicId.stringValue :NO];
    NSLog(@"%@", publicId.stringValue);

}
- (IBAction)groupsPopupListAction:(id)sender {
    [self photoAlbumsLoad:[groupsPopupData objectAtIndex:[groupsPopupList indexOfSelectedItem]] :NO];
    
}
-(void)loadGroupsPopup{
    
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
            [groupsPopupData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
            [groupsPopupList addItemWithTitle:i[@"name"]];
            
        }
    }]resume];
}

- (IBAction)stopCopy:(id)sender {
    stopped=YES;
    runPhotoCopy=NO;
}
- (IBAction)resetAction:(id)sender {
    
    albumFromId.stringValue = @"";
    publicId.stringValue = @"";
    count.stringValue = @"";
    progressLabel.stringValue = @"0 / 0";
    progress.doubleValue = 0;
    albumToId.stringValue = @"";
}

- (IBAction)copyAction:(id)sender {
    
    albumToCopyTo = albumToId.stringValue;
    albumToCopyFrom = albumFromId.stringValue;
    privacy_view = privacyList.stringValue;
    publicIdFrom = publicId.stringValue;
    NSLog(@"Public id:%@", publicIdFrom);
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
            if([handleUpdate readFromFile:@"photo" source:source publicId:publicIdFrom]){
                updateDate = [NSString stringWithFormat:@"%@", [handleUpdate readFromFile:@"photo" source:source publicId:publicIdFrom] ];
                NSLog(@"Now update date %@", updateDate);
            }
            else{
                NSLog(@"Update date did not set.");
            }
            if ([publicIdFrom intValue]<0){
                publicIdIntTemp = abs([publicIdFrom intValue]);
                publicIdPhotoFromPlus = [NSString stringWithFormat:@"%d", publicIdIntTemp];
                publicIdPhotoFrom = publicIdPhotoFromPlus;
                url = @"https://api.vk.com/method/groups.getById?group_id=%@&access_token=%@&v=%@";
            }
            else{
                publicIdPhotoFrom = publicIdFrom;
                url=@"https://api.vk.com/method/users.get?user_ids=%@&fields=nickname&access_token=%@&v=%@";
                
            }
            
            NSURLSessionDataTask *getNameOfAlbum=[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:url, publicIdPhotoFrom, _app.token, _app.version
                                                                                                     ]]completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSDictionary *getNameResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSString *nameGet;
                
                if ([publicIdFrom intValue]<0){
                    nameGet = getNameResponse[@"response"][0][@"name"];
                }
                else{
                    nameGet = [NSString stringWithFormat:@"%@ %@", getNameResponse[@"response"][0][@"first_name"], getNameResponse[@"response"][0][@"last_name"]];
                }
                newAlbumName =[[NSString stringWithFormat:@"%@", nameGet] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
                
            }];
            [getNameOfAlbum resume];
            sleep(1);
            NSLog(@"New album name: %@", [newAlbumName stringByRemovingPercentEncoding]);
            if(!updateDate || [albumToId.stringValue isEqual:@""]){
                NSURLSessionDataTask *createAlbum=[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.createAlbum?owner_id=%@&access_token=%@&v=%@&privacy_view=%@&title=%@", _app.person, _app.token, _app.version, privacy_view, newAlbumName]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    NSDictionary *createAlbumResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    targetAlbumId = [NSString stringWithFormat:@"%@", createAlbumResponse[@"response"][@"id"]];
                    NSLog(@"Album created. Target album %@", targetAlbumId);
                }];
                [createAlbum resume];
                
            }
        }
        
        //        sleep(1);
        if(captchaEditPhoto || captchaCopyPhoto){
            targetAlbumId = targetAlbum;
            NSLog(@"Target album now:%@\nOffset:%lu\nCaptcha_sid:%@\nCaptcha_key:%@", targetAlbumId, step, captcha_sid, captcha_key);
        }
        else{
            //        if(!updateDate){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/wall.get?owner_id=%@&count=%d&v=%@&access_token=%@", publicIdFrom, 2,  _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSDictionary *wallGetData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                publicName = newAlbumName ? [newAlbumName stringByRemovingPercentEncoding] : @"namenamename";
                //            NSLog(@"Public If from %@",publicIdFrom);
                //            NSLog(@"Public Name %@",publicName);
                //            NSLog(@"Date %@", wallGetData[@"response"][@"items"][0][@"date"]);
                NSString *newDate;
                for (NSDictionary *i in wallGetData[@"response"][@"items"]){
                    if(!i[@"is_pinned"]){
                        newDate=[NSString stringWithFormat:@"%@", i[@"date"]];
                    }
                    
                }
                
                [handleUpdate writeToFile:@"photo" source:source newDataToFile:@{@"id":publicIdFrom, @"name":publicName, @"date":newDate}];
                
                
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
                            //                            capturedText = [@"Captured Text" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
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
                                                                                    
                                                                                    NSInteger result = [[_captchaHandler handleCaptcha:editPhotoResponse[@"error"][@"captcha_img"]] runModal];
                                                                                    if (result == NSAlertFirstButtonReturn){
                                                                                        captchaKey=_captchaHandler.enterCode.stringValue;
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
                break;
            }
        }
        runPhotoCopy=NO;
        
    };
    
    copyFromAlbum = ^(NSString *source, id targetAlbum, BOOL captchaCopyPhoto, BOOL captchaEditPhoto, NSInteger offset, NSString *captcha_sid, NSString *captcha_key){
        step=0;
        NSString *url;
        
        if(!captchaCopyPhoto && !captchaEditPhoto){
            //            if([handleUpdate readFromFile:@"photo" source:source publicId:publicIdFrom]){
            //                updateDate = [NSString stringWithFormat:@"%@", [handleUpdate readFromFile:@"photo" source:source publicId:publicIdFrom] ];
            //                NSLog(@"Now update date %@", updateDate);
            //            }
            //            else{
            //                NSLog(@"Update date did not set.");
            //            }
            if ([publicIdFrom intValue]<0){
                //                publicIdIntTemp = abs([publicIdFrom intValue]);
                //                publicIdPhotoFromPlus = [NSString stringWithFormat:@"%i", publicIdIntTemp];
                publicIdPhotoFrom = [NSString stringWithFormat:@"%i", abs([publicIdFrom intValue])];
                url = [NSString stringWithFormat:@"https://api.vk.com/method/groups.getById?group_id=%@&access_token=%@&v=%@", publicIdPhotoFrom, _app.token, _app.version];
            }
            else{
                publicIdPhotoFrom = publicIdFrom;
                url=[NSString stringWithFormat:
                     @"https://api.vk.com/method/users.get?user_ids=%@&fields=nickname&access_token=%@&v=%@",  publicIdPhotoFrom, _app.token, _app.version];
                
            }
            
            NSURLSessionDataTask *getNameOfAlbum=[_app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSDictionary *getNameResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSString *nameGet;
                
                if ([publicIdFrom intValue]<0){
                    nameGet = getNameResponse[@"response"][0][@"name"];
                }
                else{
                    nameGet = [NSString stringWithFormat:@"%@ %@", getNameResponse[@"response"][0][@"first_name"], getNameResponse[@"response"][0][@"last_name"]];
                }
                newAlbumName =[[NSString stringWithFormat:@"%@", nameGet] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
                
            }];
            [getNameOfAlbum resume];
            sleep(1);
            NSLog(@"New album name: %@", [newAlbumName stringByRemovingPercentEncoding]);
            //            if(!updateDate || [albumToId.stringValue isEqual:@""]){
            NSURLSessionDataTask *createAlbum=[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.createAlbum?owner_id=%@&access_token=%@&v=%@&privacy_view=%@&title=%@", _app.person, _app.token, _app.version, privacy_view, newAlbumName]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                NSDictionary *createAlbumResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                targetAlbumId = [NSString stringWithFormat:@"%@", createAlbumResponse[@"response"][@"id"]];
                NSLog(@"Album created. Target album %@", targetAlbumId);
            }];
            [createAlbum resume];
            
            //            }
            
        }
        if(captchaEditPhoto || captchaCopyPhoto){
            targetAlbumId = targetAlbum;
            NSLog(@"Target album now:%@\nOffset:%lu\nCaptcha_sid:%@\nCaptcha_key:%@", targetAlbumId, step, captcha_sid, captcha_key);
        }
        [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.get?owner_id=%@&album_id=%@&count=1&offset=%li&access_token=%@&v=%@", publicIdFrom, albumFromId.stringValue, step, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *getPhotosCountResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            countPhotos = [getPhotosCountResponse[@"response"][@"count"] intValue];
        }]resume];
        sleep(1);
//        countPhotos = 10;
        progress.maxValue = countPhotos;
        
        while(step<countPhotos){
            if(!stopped){
                semaphore = dispatch_semaphore_create(0);
                [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.get?owner_id=%@&album_id=%@&count=1&offset=%li&access_token=%@&v=%@", publicIdFrom, albumFromId.stringValue, step, _app.token, _app.version]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    NSDictionary *getPhotosResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                    NSLog(@"%@", getPhotosResponse);
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
                            NSLog(@"%@", photoIdToCopy);
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
                                                stopped=YES;
                                                
                                            }
                                            else{
                                                NSLog(@"Photo sucessfully moved:%@", movePhotoResponse[@"response"]);
                                                dispatch_semaphore_signal(semaphore);
                                                
                                            }
                                            
                                        }]resume];
                                        
//                                        sleep(1);
                                        
                                        if(captureText.state == 1 && capturedText ){
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
                                                                
                                                                NSInteger result = [[_captchaHandler handleCaptcha:editPhotoResponse[@"error"][@"captcha_img"] ]runModal];
                                                                if (result == NSAlertFirstButtonReturn){
                                                                    captchaKey = _captchaHandler.enterCode.stringValue;
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
                        }]resume];
                        
                        //                        sleep(1);
                    }
                }]resume];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                dispatch_semaphore_signal(semaphore);
                sleep(1);
                step++;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!stopped){
                        progress.doubleValue=step+1;
                        progressLabel.stringValue = [NSString stringWithFormat:@"%ld / %li", step, countPhotos];
                    }
                });
                
            }
            else{
                break;
                stopped = YES;
            }
        }
        
    };
    if (runPhotoCopy==YES){
        
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = [NSString stringWithFormat:@"%@", @"Copy photo"];
        alert.informativeText = [NSString stringWithFormat:@"%@", @"You have already running photo copy proccess.\n Press stop and try again."];
        
        [alert runModal];
    }
    else{
        
        //        if([albumFromId.stringValue isEqual:@"wall"] && ![publicId.stringValue isEqual:@""] && ![count.stringValue isEqual:@""]){
        //            NSLog(@"copy started");
        //            runPhotoCopy=YES;
        //
        //
        //                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //                        copyFromWall(@"wall", nil, NO, NO, 0, @"", @"");
        //                   });
        //
        //        }
        //        else{
        //            NSLog(@"Some fields are empty.");
        //        }
        if(!([albumFromId.stringValue isEqual:@""] && ![albumFromId.stringValue isEqual:@"wall"]) && ![publicId.stringValue isEqual:@""]){
            NSLog(@"copy started");
            runPhotoCopy=YES;
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                copyFromAlbum(@"album", nil, NO, NO, 0, @"", @"");
            });
            
            
            
        }
        else{
            NSLog(@"Some fields are empty.");
        }
        
    }
}

-(void)photoAlbumsLoad:(NSString *)owner :(BOOL)searchByName{
//    toTableView.delegate=self;
//    toTableView.dataSource=self;
//    fromTableView.delegate=self;
//    fromTableView.dataSource=self;
    [progressSpin startAnimation:self];
    
//    NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:searchBar.stringValue options: NSRegularExpressionCaseInsensitive error:nil];
    if (![owner isEqual:_app.person]){
        
        [photoAlbums2 removeAllObjects];
        [photoAlbums2 addObject:@{@"title":@"profile",@"id":@"profile"}];
        [photoAlbums2 addObject:@{@"title":@"wall", @"id":@"wall"}];
    }
    else{
        [photoAlbums removeAllObjects];
    }
    void (^loadAlbumsTo)() = ^() {
//        __block NSArray *found;
        NSURLSessionDataTask *getAlbumsTo = [_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/photos.getAlbums?owner_id=%@&v=%@&access_token=%@", owner, _app.version, _app.token]] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error){
                NSLog(@"Check your connection");
            }
            else{
                NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([jsonData objectForKey:@"error"]){
                    if([jsonData[@"error"][@"error_code"] intValue] == 15){
//                        [photoAlbums2 addObject:@{@"title":@"profile",@"id":@"profile"}];
//                        [photoAlbums2 addObject:@{@"title":@"wall", @"id":@"wall"}];
                       arrayController2.content=photoAlbums2;
                        
                        [fromTableView reloadData];
                    }
                    NSLog(@"%@:%@", jsonData[@"error"][@"error_code"], jsonData[@"error"][@"error_msg"]);
                }
                else{
                    for (NSDictionary *a in jsonData[@"response"][@"items"]){
                        NSDictionary *dataDict=@{@"id":[NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@",a[@"id"]]], @"title":a[@"title"]};
                        if([owner isEqual:_app.person]){
//                            if (searchByName){
//                                found = [regex matchesInString:a[@"title"] options:0 range:NSMakeRange(0, [a[@"title"] length])];
//                                if([found count]>0){
//                                    [photoAlbums addObject:dataDict];
//                                }
//                           
//                            }
//                            else{
                                 [photoAlbums addObject:dataDict];
//                            }
                           
                        }
                        else{
//                            if (searchByName){
//                                found = [regex matchesInString:a[@"title"] options:0 range:NSMakeRange(0, [a[@"title"] length])];
//                                if([found count]>0){
//                                    [photoAlbums2 addObject:dataDict];
//                                }
//                           
//                        
//                            }
//                            else{
                                [photoAlbums2 addObject:dataDict];
                            }
//                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([owner isEqual:_app.person]){
                            arrayController1.content=photoAlbums;
                            [toTableView reloadData];
                        }
                        else{
                            arrayController2.content=photoAlbums2;
                            [fromTableView reloadData];
                        }
                    });
                }
                
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [progressSpin stopAnimation:self];
            });
        }];
        [getAlbumsTo resume];
//        [photoAlbums removeAllObjects];
   
        
    };
    loadAlbumsTo();


}


@end
