//
//  TwitterPrefsInfo.m
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TwitterPrefsInfo.h"

@interface TwitterPrefsInfo ()

@end

@implementation TwitterPrefsInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetTwitterAccessToken:) name:@"GetTwitterAccessToken" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ObserveReadyTwitterTokens:) name:@"ObserveReadyTwitterTokens" object:nil];
    twitterRWD = [[TwitterRWData alloc]init];
    twitterAuth = [[TwitterAuth alloc]init];
    [self loadData];
//        NSLog(@"%@", appData);
}
-(void)loadData{
    NSDictionary *appData = [twitterRWD readTwitterTokens];
    consumerKey.stringValue=appData[@"consumer_key"];
    consumerSecret.stringValue=appData[@"consumer_secret_key"];
    secretToken.stringValue=appData[@"secret_token"];
    token.stringValue=appData[@"token"];
}
-(void)GetTwitterAccessToken:(NSNotification*)notification{
    [twitterAuth requestAccessTokenAndSecretToken:notification.userInfo[@"verifier"] :notification.userInfo[@"consumer"] :notification.userInfo[@"consumerSecret"] :notification.userInfo[@"tempToken"] :notification.userInfo[@"tempTokenSecret"]];
}
-(void)ObserveReadyTwitterTokens:(NSNotification*)notification{
    [twitterRWD writeTokens:notification.userInfo];
    dispatch_async(dispatch_get_main_queue(),^{

        [self loadData];
    });
//    NSLog(@"%@", notification.userInfo);
}

@end
