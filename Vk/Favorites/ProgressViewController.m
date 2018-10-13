//
//  ProgressViewController.m
//  MasterAPI
//
//  Created by sim on 06/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import "ProgressViewController.h"

@interface ProgressViewController ()

@end

@implementation ProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _current=0;
    _total=_total?_total:0;
    _app = [[appInfo alloc]init];
    [self setProcess];
    if(_savePhotoToSaved){
        [self addToSavedPhotos];
        titleLabel.stringValue = @"Add to saved:";
    }else{
        titleLabel.stringValue = @"Unlike:";
        [self unlike];
    }
//    NSLog(@"HAHA");
    offset_counter=0;
}
- (void)setProcess{
    proccessLabel.stringValue = [NSString stringWithFormat:@"%li/%li",_current,_total];
}
- (IBAction)cancel:(id)sender {
    stopped=YES;
    [self dismissController:self];
}

- (void)addToSavedPhotos{
    //    NSLog(@"Selected _items: %@", items);
    _total = [_items count];
    if(offset_counter<_total){
        _ownerId = _items[offset_counter][@"items"][@"owner_id"];
        _photoId = _items[offset_counter][@"items"][@"id"];
//        progressBar.maxValue=[_items count];
        NSDictionary *params = @{@"owner_id":_ownerId,@"photo_id":_photoId};
        NSLog(@"%li", offset_counter);
        NSLog(@"%@", params);
        [_app addToSavedPhotos:params captcha_sid:nil captcha_key:nil captcha:NO comletionHandler:^(NSDictionary * _Nonnull response) {
            if(response[@"error"]){
                if([response[@"error"][@"error_code"] intValue] == 14){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSInteger result = [[_app.captchaHandler handleCaptcha:response[@"error"][@"captcha_img"]]runModal];
                        if(result == NSAlertFirstButtonReturn){
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [_app addToSavedPhotos:params captcha_sid:response[@"captcha_sid"] captcha_key:_app.captchaHandler.enterCode.stringValue captcha:YES comletionHandler:^(NSDictionary * _Nonnull response) {
                                    
                                }];
                            });
                        }
                    });
                }
                else if([response[@"error"][@"error_code"] intValue] == 800){
                    NSLog(@"%@:%@", response[@"error"][@"error_msg"], response[@"error"][@"error_code"]);
                    offset_counter++;
                }
            }else{
                offset_counter++;
                _current = offset_counter;
                NSLog(@"Photo saved successfully to saved album");
                sleep(1);
                dispatch_async(dispatch_get_main_queue(), ^{
//                    progressBar.doubleValue=offset_counter;
                    [self setProcess];
                    if(_current==_total){
                        [self dismissController:self];
                    }
                    
                });
                [self addToSavedPhotos];
            }
        }];
    }
}
- (void)unlike{
    __block void (^unlikeBlock)(NSString *captcha_key, NSString *captcha_sid, NSInteger offset, BOOL unlikeVideoCaptcha);
    unlikeBlock = ^(NSString *captcha_key,NSString *captcha_sid, NSInteger offset, BOOL unlikeVideoCaptcha){
        stopped=NO;
        captchaOpened=NO;
       
        for (NSDictionary *i in [_items subarrayWithRange:NSMakeRange(offset_counter, [_items count])]){
             url = unlikeVideoCaptcha ? [NSString stringWithFormat:@"https://api.vk.com/method/likes.delete?type=video&item_id=%@&owner_id=%@&access_token=%@&v=%@&captcha_sid=%@&captcha_key=%@", i[@"items"][@"id"], i[@"items"][@"owner_id"], _app.token, _app.version, captcha_sid, captcha_key] : [NSString stringWithFormat:@"https://api.vk.com/method/likes.delete?type=photo&item_id=%@&owner_id=%@&access_token=%@&v=%@", i[@"items"][@"id"], i[@"items"][@"owner_id"], _app.token, _app.version];
            if(stopped){
                break;
            }
            else{
                [[_app.session dataTaskWithURL:[NSURL URLWithString:url]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if(data){
                        NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        NSLog(@"%@", obj);
                        if(obj[@"error"]){
                            if([obj[@"error"][@"error_code"] intValue] == 14){
                                stopped=YES;
                                __block NSString *captchaKey;
                                
                                if(!captchaOpened){
                                    captchaOpened=YES;
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        NSInteger result = [[_app.captchaHandler handleCaptcha:obj[@"error"][@"captcha_img"]] runModal];
                                        if (result == NSAlertFirstButtonReturn){
                                            captchaKey=[_app.captchaHandler readCode];
                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                                unlikeBlock(captchaKey, obj[@"error"][@"captcha_sid"], offset_counter, YES);
                                            });
                                            captchaOpened=NO;
                                            
                                        }
                                        else if(result == NSAlertSecondButtonReturn){
                                            stopped=YES;
                                        }

                                    });
                                }
                            }else if(([obj[@"error"][@"error_code"] intValue] == 15)||([obj[@"error"][@"error_code"] intValue] == 800)) {
                                
                            }
                            
                        }else if(obj[@"response"][@"likes"]){
                            _current+=1;
                           
                        }
                    }else{
                        NSLog(@"No data");
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self setProcess];
                        if(_current==_total){
                            [self dismissController:self];
                        }
                    });
                   
                }]resume];
                sleep(1);
                offset_counter+=1;
            }
        }
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        unlikeBlock(nil, nil, 0,  NO);
    });
    
   
}
@end
