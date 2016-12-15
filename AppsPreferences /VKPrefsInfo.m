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
    NSDictionary *appData = [_VKInfoHandler readAppInfo:nil];
    appId.stringValue = appData[@"appId"];
    appTitle.stringValue = appData[@"title"];
    appToken.stringValue = appData[@"token"];
    appVersion.stringValue = appData[@"version"];
//    NSLog(@"%@", appData);
}
- (IBAction)setupTokens:(id)sender {
    
//    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
//    NSViewController *contr = [story instantiateControllerWithIdentifier:@"VKLoginViewController"];
//    [contr presentViewControllerAsModalWindow:contr];
}
@end
