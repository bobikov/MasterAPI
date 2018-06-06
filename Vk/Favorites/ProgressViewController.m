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
    captchaHandler = [[VKCaptchaHandler alloc]init];
    _app = [[appInfo alloc]init];
    [self setProcess];
    [self unlike];
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


- (void)unlike{
    __block void (^unlikeBlock)(NSString *captcha_key, NSString *captcha_sid, int offset, BOOL unlikeVideoCaptcha);
    unlikeBlock = ^(NSString *captcha_key,NSString *captcha_sid, int offset, BOOL unlikeVideoCaptcha){
        stopped=NO;
        captchaOpened=NO;
       
        for (NSDictionary *i in [_items subarrayWithRange:NSMakeRange(offset_counter, [_items count])]){
             url = unlikeVideoCaptcha ? [NSString stringWithFormat:@"https://api.vk.com/method/likes.delete?type=video&item_id=%@&owner_id=%@&access_token=%@&v=%@&captcha_sid=%@&captcha_key=%@", i[@"id"], i[@"owner_id"], _app.token, _app.version, captcha_sid, captcha_key] : [NSString stringWithFormat:@"https://api.vk.com/method/likes.delete?type=video&item_id=%@&owner_id=%@&access_token=%@&v=%@", i[@"id"], i[@"owner_id"], _app.token, _app.version];
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
                                        
                                        NSInteger result = [[captchaHandler handleCaptcha:obj[@"error"][@"captcha_img"]] runModal];
                                        if (result == NSAlertFirstButtonReturn){
                                            captchaKey=[captchaHandler readCode];
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
