//
//  TumblrPrefsInfo.m
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TumblrPrefsInfo.h"

@interface TumblrPrefsInfo ()

@end

@implementation TumblrPrefsInfo

- (void)viewDidLoad {
    [super viewDidLoad];
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeRefreshParams:) name:@"refreshTumblrParamsInFields"  object:nil];
    _tumblrRWD = [[TumblrRWData alloc]init];
  
//    NSLog(@"%@", appData);
    tumblrAuth = [[TumblrAuth alloc]init];
    [self loadData];
}
-(void)observeRefreshParams:(NSNotification*)obj{
    [self loadData];
}
-(void)loadData{
    NSDictionary *appData = [_tumblrRWD readTumblrTokens];
    consumerKey.stringValue = [appData count] ? appData[@"consumer_key"] : @"none";
    consumerSecret.stringValue = [appData count] ? appData[@"consumer_secret_key"] : @"none";
    secretToken.stringValue = [appData count] ? appData[@"secret_token"] : @"none";
    token.stringValue = [appData count] ? appData[@"token"] : @"none";
}
- (IBAction)setupTumblrPrefs:(id)sender {
     [[NSNotificationCenter defaultCenter] postNotificationName:@"AppsSetupPrefsSelect" object:nil userInfo:@{@"name":@"tumblr"}];
    
}

@end
