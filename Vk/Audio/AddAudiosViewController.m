//
//  AddAudiosViewController.m
//  MasterAPI
//
//  Created by sim on 16.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "AddAudiosViewController.h"

@interface AddAudiosViewController ()

@end

@implementation AddAudiosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [[appInfo alloc]init];
    _captchaHandle = [[VKCaptchaHandler alloc]init];
    userGroupsByAdminData = [[NSMutableArray alloc]init];
    [userGroupsByAdmin removeAllItems];
    [userGroupsByAdmin addItemWithTitle:@"Personal"];
    [userGroupsByAdminData addObject:_app.person];
    [self loadGroupsByAdmin];
    offsetAddAudios = 0;
    progressBar.maxValue=[_receivedData count];
//    NSLog(@"%@", _receivedData);
}
-(void)loadGroupsByAdmin{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/groups.get?user_id=%@&filter=admin&extended=1&access_token=%@&v=%@", _app.person, _app.token, _app.version]]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *groupsGetResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                for(NSDictionary *i in groupsGetResponse[@"response"][@"items"]){
                    [userGroupsByAdminData addObject:[NSString stringWithFormat:@"-%@",i[@"id"]]];
                    [userGroupsByAdmin addItemWithTitle:i[@"name"]];
                    
                }
            }]resume];
        });
    });
}
- (IBAction)userGroupsByAdminSelect:(id)sender {
    owner = userGroupsByAdminData[[userGroupsByAdmin indexOfSelectedItem]];
}
- (IBAction)add:(id)sender {
    __block void (^addAudios)( BOOL, NSInteger, NSString *, NSString *);
    stopFlag=NO;
    addAudios = ^void(BOOL captcha, NSInteger offset, NSString *captcha_sid, NSString *captcha_key){
        while(offsetAddAudios < [_receivedData count]){
            [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.add?owner_id=%@%@&audio_id=%@&access_token=%@&v=%@%@", _receivedData[offsetAddAudios][@"owner_id"],[owner isEqual:_app.person ]? @"" : [NSString stringWithFormat:@"&group_id=%i", abs([owner intValue])] , _receivedData[offsetAddAudios][@"id"], _app.token,_app.version,  captcha ? [NSString stringWithFormat:@"&captcha_sid=%@&captcha_key=%@", captcha_sid, captcha_key ] : @""]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                NSDictionary *addAudiosResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSLog(@"%@", addAudiosResp);
                if(addAudiosResp[@"response"]){
                   
                    offsetAddAudios++;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        progressBar.doubleValue=offsetAddAudios;
                    });
                }else if(addAudiosResp[@"error"]){
                     stopFlag=YES;
                    if([addAudiosResp[@"error"][@"error_code"] intValue]==14){
                        
                        
                            NSInteger result = [[_captchaHandle handleCaptcha:addAudiosResp[@"error"][@"captcha_img"]]runModal];
                            if(result == NSAlertFirstButtonReturn){
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    addAudios(YES, offsetAddAudios, addAudiosResp[@"error"][@"captcha_sid"], _captchaHandle.enterCode.stringValue);
                                });
                            }
//                        }
                    }
                }
                
            }]resume];
            sleep(1);
            if(stopFlag){
                break;
            }
        }
    };
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       addAudios(NO, 0, nil, nil);
   });
    
    
    
}

@end
