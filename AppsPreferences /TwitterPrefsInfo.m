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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeRefreshParams:) name:@"refreshTwitterParamsInFields"  object:nil];
    
    twitterRWD = [[TwitterRWData alloc]init];
    twitterAuth = [[TwitterAuth alloc]init];
    [self loadData];
//        NSLog(@"%@", appData);
}
-(void)observeRefreshParams:(NSNotification*)obj{
    [self loadData];
}
-(void)loadData{
    NSDictionary *appData = [twitterRWD readTwitterTokens];
    consumerKey.stringValue = [appData count] ? appData[@"consumer_key"] : @"none";
    consumerSecret.stringValue = [appData count] ? appData[@"consumer_secret_key"] : @"none";
    secretToken.stringValue = [appData count] ? appData[@"secret_token"] : @"none";
    token.stringValue = [appData count] ? appData[@"token"] : @"none";
   
}


- (IBAction)setupTwitterPrefs:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppsSetupPrefsSelect" object:nil userInfo:@{@"name":@"twitter"}];
}

@end
