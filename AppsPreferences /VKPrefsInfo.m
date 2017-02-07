//
//  VKPrefsInfo.m
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "VKPrefsInfo.h"

@interface VKPrefsInfo ()

@end

@implementation VKPrefsInfo

- (void)viewDidLoad {
    [super viewDidLoad];
    _VKInfoHandler = [[keyHandler alloc]init];
    [self setAppInfo];
//    NSLog(@"%@", appData);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateAppInfo:) name:@"updateVkAppInfo" object:nil];
}
-(void)updateAppInfo:(NSNotification*)obj{
    [self setAppInfo];
}
-(void)setAppInfo{
    NSDictionary *appData = [_VKInfoHandler readAppInfo:nil];
    NSLog(@"%@", appData);
    if(appData){
        appId.stringValue = appData[@"appId"];
        appTitle.stringValue = appData[@"title"];
        appToken.stringValue = appData[@"token"];
        appVersion.stringValue = appData[@"version"];
    }
}
- (IBAction)setupTokens:(id)sender {
    
//    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
//    NSViewController *contr = [story instantiateControllerWithIdentifier:@"VKLoginViewController"];
//    [contr presentViewControllerAsModalWindow:contr];
}
- (IBAction)setupVKPrefs:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppsSetupPrefsSelect" object:nil userInfo:@{@"name":@"vkontakte"}];
}
@end
