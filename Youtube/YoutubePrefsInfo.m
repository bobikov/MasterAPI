//
//  YoutubePrefsInfo.m
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "YoutubePrefsInfo.h"

@interface YoutubePrefsInfo ()

@end

@implementation YoutubePrefsInfo

- (void)viewDidLoad {
    [super viewDidLoad];
   
    youtubeRWD = [[YoutubeRWData alloc]init];
    [self setParamsToFields];
    youtubeAuth = [[YoutubeAuth alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeRefreshParams:) name:@"refreshYoutubeParamsInFields"  object:nil];
//    NSLog(@"%@", appData);
//    [youtubeRWD removeAllYoutubeAppInfo:^(BOOL removeAppResult) {
//        
//    }];
}
-(void)observeRefreshParams:(NSNotification*)obj{
    [self setParamsToFields];
}
- (IBAction)youtubeSetupPrefs:(id)sender {
    
     [[NSNotificationCenter defaultCenter] postNotificationName:@"AppsSetupPrefsSelect" object:nil userInfo:@{@"name":@"youtube"}];
}
-(void)setParamsToFields{
    NSDictionary *appData = [youtubeRWD readYoutubeTokens];
    
    clientId.stringValue = [appData count] ? appData[@"client_id"] : @"none";
    accessToken.stringValue = [appData count] ? appData[@"access_token"] : @"none";
    clientSecret.stringValue = [appData count] ? appData[@"client_secret"] : @"none";
    refreshToken.stringValue = [appData count] ? appData[@"refresh_token"] : @"none";
}
@end
