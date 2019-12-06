//
//  TumblrLoginViewController.m
//  MasterAPI
//
//  Created by sim on 29/06/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "TumblrLoginViewController.h"

@interface TumblrLoginViewController ()

@end

@implementation TumblrLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ObserveReadyTumblrTokens:) name:@"ObserveReadyTumblrTokens" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetTumblrAccessToken:) name:@"GetTumblrAccessToken" object:nil];
    RWData = [[TumblrRWData alloc]init];
    [self setButtonDest];
    [self setFieldsEnabled];
}
- (IBAction)removeAndAdd:(id)sender {
    [progress startAnimation:self];
    if([RWData TumblrTokensEcxistsInCoreData]){
        [RWData removeAllTumblrAppInfo:^(BOOL resultRemoveApp) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setFieldsEnabled];
                [self setButtonDest];
                [progress stopAnimation:self];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTumblrParamsInFields" object:nil];
            });
            
        }];
    }
    else{
        [self addApp];
    }
}
- (IBAction)resetToken:(id)sender {
}
-(void)addApp{
    TAuth = [[TumblrAuth alloc] initWithParams:consumerKey.stringValue consumerSecret:consumerSecret.stringValue];
    [TAuth requestTempToken];
}
- (IBAction)backToTumblrPrefs:(id)sender {
      [[NSNotificationCenter defaultCenter]postNotificationName:@"backToInfo" object:nil userInfo:@{@"name":@"tumblr"}];
}
-(void)GetTumblrAccessToken:(NSNotification *)notification{
    [TAuth requestAccessTokenAndSecretToken:notification.userInfo[@"verifier"]];
}

-(void)ObserveReadyTumblrTokens:(NSNotification *)notification{
    NSLog(@"%@", notification.userInfo);
    [RWData writeTokens:notification.userInfo];
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTumblrParamsInFields" object:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"backToInfo" object:nil userInfo:@{@"name":@"tumblr"}];
        [self setButtonDest];
        [self setFieldsEnabled];
        [progress stopAnimation:self];
        
    });
}
-(void)setButtonDest{
    if([RWData TumblrTokensEcxistsInCoreData]){
        removeAndAddButton.title=@"Remove app";
        
        
    }else{
        removeAndAddButton.title = @"Add app";
    }
    
}
-(void)setFieldsEnabled{
    consumerKey.enabled=![RWData TumblrTokensEcxistsInCoreData];
    consumerSecret.enabled=![RWData TumblrTokensEcxistsInCoreData];
}

@end
