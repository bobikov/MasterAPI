//
//  InstaPrefsInfo.m
//  MasterAPI
//
//  Created by sim on 04.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "InstaPrefsInfo.h"

@interface InstaPrefsInfo ()

@end

@implementation InstaPrefsInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    instaRWD = [[InstagramRWD alloc]init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadAppInfoFromCoreData:) name:@"loadInstagramAppInfoInPrefs" object:nil];
//    [instaRWD removeAllInstagramAppInfo];
    [self loadAppInfo];
//    token.stringValue=appData[@"token"];
}
-(void)loadAppInfoFromCoreData:(NSNotification*)notification{
    [self loadAppInfo];
}
-(void)loadAppInfo{
    if([instaRWD InstagramTokensEcxistsInCoreData]){
        NSDictionary *appData = [instaRWD readInstagramTokens];
        clientId.stringValue=appData[@"client_id"];
        client_secret.stringValue=appData[@"client_secret"];
        accessToken.stringValue=appData[@"access_token"];
    }else{
        NSLog(@"Instagram app info is not exist.");
    }
}
@end
