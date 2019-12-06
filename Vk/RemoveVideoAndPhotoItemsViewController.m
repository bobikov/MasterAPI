//
//  RemoveVideoAndPhotoItemsViewController.m
//  MasterAPI
//
//  Created by sim on 12.01.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "RemoveVideoAndPhotoItemsViewController.h"

@interface RemoveVideoAndPhotoItemsViewController ()

@end

@implementation RemoveVideoAndPhotoItemsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"%@",_receivedData);
    currentRemovedItem = 0;
    app = [[appInfo alloc]init];
    [self setProgressStatus];
    
    [self removeItems];
}
-(void)setProgressStatus{
    progressBar.maxValue=[_receivedData count];
    progressLabel.stringValue = [NSString stringWithFormat:@"%li/%li", currentRemovedItem, [_receivedData count]];
    progressBar.doubleValue = currentRemovedItem;
}

-(void)removeItems{
    
    __block BOOL stopped;
    __block NSString *url;
    __block void (^removeVideoAlbumsBlock)(BOOL captcha, NSString *captchaSid, NSString *captchaKey);
    __block void (^removePhotoAlbumsBlock)();
    
    __block void (^removeVideoItemsBlock)();
    __block void(^removePhotoItemsBlock)();
    removeVideoAlbumsBlock = ^void(BOOL captcha, NSString *captchaSid, NSString *captchaKey){
        stopped=NO;
       
        for (NSDictionary *i in _receivedData){
            
            if(!stopped){
                if (captcha){
                    url = [NSString stringWithFormat:@"https://api.vk.com/method/video.deleteAlbum?owner_id=%@&album_id=%@&v=%@&access_token=%@&captcha_sid=%@&captcha_key=%@", app.person, i[@"id"], app.version, app.token, captchaSid, captchaKey];
                }
                else{
                    url = [NSString stringWithFormat:@"https://api.vk.com/method/video.deleteAlbum?owner_id=%@&album_id=%@&v=%@&access_token=%@", app.person, i[@"id"], app.version, app.token];
                }
                NSURLSessionDataTask *deleteAlbum = [app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
                                        
//                                        NSInteger result = [[_captchaHandler handleCaptcha:deleteAlbumResponse[@"error"][@"captcha_img"]]runModal];
//                                        if (result == NSAlertFirstButtonReturn){
                                            //                                            NSLog(@"%@", enterCode.stringValue);
//                                            NSLog(@"%@", deleteAlbumResponse[@"error"][@"captcha_sid"]);
//                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                                removeAlbumBlock(YES, deleteAlbumResponse[@"error"][@"captcha_sid"], _captchaHandler.enterCode.stringValue);
//                                            });
//                                        }
//                                        if (result == NSAlertSecondButtonReturn){
//                                            
//                                        }
                                    });
                                }
                                else{
                                    NSLog(@"%@", deleteAlbumResponse[@"error"]);
                                }
                            }
                        }
                        NSLog(@"%@", i);
                          dispatch_async(dispatch_get_main_queue(), ^{
                              currentRemovedItem = [_receivedData indexOfObject:i]+1;
                              [self setProgressStatus];
                          });
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
//        if(!stopped && [rows count]>0){
//            [self loadAlbums:_app.person];
//        }
        
        
        //        });
    };
    removePhotoAlbumsBlock = ^void(){
        stopped=NO;
        
        for (NSDictionary *i in _receivedData){
            
            if(!stopped){
                NSString *ownerParam = [NSString stringWithFormat:@"%@=%i&",[i[@"owner"] intValue]<0?@"group_id":@"owner_id",[i[@"owner"] intValue]<0?abs([i[@"owner"] intValue]):[i[@"owner"] intValue]];
                
                url = [NSString stringWithFormat:@"https://api.vk.com/method/photos.deleteAlbum?%@album_id=%@&v=%@&access_token=%@", ownerParam, i[@"id"], app.version, app.token];
             
                NSURLSessionDataTask *deleteAlbum = [app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
                                        
                                        //                                        NSInteger result = [[_captchaHandler handleCaptcha:deleteAlbumResponse[@"error"][@"captcha_img"]]runModal];
                                        //                                        if (result == NSAlertFirstButtonReturn){
                                        //                                            NSLog(@"%@", enterCode.stringValue);
                                        //                                            NSLog(@"%@", deleteAlbumResponse[@"error"][@"captcha_sid"]);
                                        //                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                        //                                                removeAlbumBlock(YES, deleteAlbumResponse[@"error"][@"captcha_sid"], _captchaHandler.enterCode.stringValue);
                                        //                                            });
                                        //                                        }
                                        //                                        if (result == NSAlertSecondButtonReturn){
                                        //
                                        //                                        }
                                    });
                                }
                                else{
                                    NSLog(@"%@", deleteAlbumResponse[@"error"]);
                                }
                            }
                        }
                        NSLog(@"%@", i);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            currentRemovedItem = [_receivedData indexOfObject:i]+1;
                            
                            [self setProgressStatus];
                        });
                    }
                }];
                [deleteAlbum resume];
                sleep(1);
                
            }
            else{
                break;
            }
            
        }
    };
    
    removeVideoItemsBlock = ^void(){
        stopped=NO;
        
        for (NSDictionary *i in _receivedData){
            NSLog(@"%@", i);
            if(!stopped){
                url = [NSString stringWithFormat:@"https://api.vk.com/method/video.delete?video_id=%@&owner_id=%@&target_id=%@&v=%@&access_token=%@", i[@"id"], i[@"owner_id"], i[@"albumOwner"], app.version, app.token];
              
               [[app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if(data){
                        if(error){
                            NSLog(@"Connection error");
                            return;
                        }
                        else{
                            NSDictionary *deleteItemResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            if(deleteItemResponse[@"error"]){
                                if([deleteItemResponse[@"error"][@"error_code"] intValue]==14){
                                    stopped=YES;
                                    NSLog(@"%@:%@", deleteItemResponse[@"error"][@"error_code"], deleteItemResponse[@"error"][@"error_msg"]);
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                   
                                    });
                                }
                                else{
                                    NSLog(@"%@", deleteItemResponse[@"error"]);
                                }
                            }
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            currentRemovedItem = [_receivedData indexOfObject:i]+1;
                            [self setProgressStatus];
                        });
                    }
                }]resume];
                sleep(1);
                
            }
            else{
                break;
            }
            
        }
        //        dispatch_async(dispatch_get_main_queue(), ^{
        //        if(!stopped && [rows count]>0){
        //            [self loadAlbums:_app.person];
        //        }
        
        
        //        });

        
    };
    
    removePhotoItemsBlock = ^void(){
        stopped=NO;
        NSLog(@"%@", _receivedData);
        for (NSDictionary *i in _receivedData){
            NSLog(@"%@", i);
            if(!stopped){
                url = [NSString stringWithFormat:@"https://api.vk.com/method/photos.delete?photo_id=%@&owner_id=%@&v=%@&access_token=%@", i[@"items"][@"id"], i[@"owner_id"], app.version, app.token];
                
                [[app.session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    if(data){
                        if(error){
                            NSLog(@"Connection error");
                            return;
                        }
                        else{
                            NSDictionary *deleteItemResponse=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                            if(deleteItemResponse[@"error"]){
                                if([deleteItemResponse[@"error"][@"error_code"] intValue]==14){
                                    stopped=YES;
                                    NSLog(@"%@:%@", deleteItemResponse[@"error"][@"error_code"], deleteItemResponse[@"error"][@"error_msg"]);
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                    });
                                }
                                else{
                                    NSLog(@"%@", deleteItemResponse[@"error"]);
                                }
                            }
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            currentRemovedItem = [_receivedData indexOfObject:i]+1;
                            [self setProgressStatus];
                        });
                    }
                }]resume];
                sleep(1);
                
            }
            else{
                break;
            }
        }
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(_receivedData){
            if([_mediaType isEqual:@"video"] ){
                if([_itemType isEqual:@"album"]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        titleLabel.stringValue=@"Removing video albums";
                        self.title=@"Remove video albums";
                    });
                    removeVideoAlbumsBlock(NO, @"", @"");
                }
                else if([_itemType isEqual:@"item"]){
                    removeVideoItemsBlock();
                }
            }
            else if([_mediaType isEqual:@"photo"]){
                if([_itemType isEqual:@"album"]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        titleLabel.stringValue=@"Removing photo albums";
                        self.title=@"Remove photo albums";
                    });
                    removePhotoAlbumsBlock();
                }
                else if([_itemType isEqual:@"item"]){
                    removePhotoItemsBlock();
                }
            };
        }
    });
}
@end
