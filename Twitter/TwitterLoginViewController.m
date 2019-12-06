//
//  TwitterLoginViewController.m
//  MasterAPI
//
//  Created by sim on 05.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TwitterLoginViewController.h"

@interface TwitterLoginViewController ()<WebFrameLoadDelegate>

@end

@implementation TwitterLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView.frameLoadDelegate = self;
    RWData = [[TwitterRWData alloc]init];
    twitterAuth = [[TwitterAuth alloc]init];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authorize:) name:@"authorizeTwitterInBrowser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GetTwitterAccessToken:) name:@"GetTwitterAccessToken" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ObserveReadyTwitterTokens:) name:@"ObserveReadyTwitterTokens" object:nil];
    [self setFieldsEnabled];
    [self setButtonDest];
}
-(void)authorize:(NSNotification*)notification{
    _webView.hidden=NO;
    NSLog(@"%@", notification.userInfo[@"url"]);
    tempToken = notification.userInfo[@"temp_token"];
    tempTokenSecret = notification.userInfo[@"temp_token_secret"];
    [_webView setMainFrameURL:notification.userInfo[@"url"]];
    
    
    
}
- (IBAction)acceptData:(id)sender {
    
    
}
-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
    //    NSLog(@"%@", [_webView mainFrameURL]);
    if([[_webView mainFrameURL] containsString:@"oauth_verifier"]){
        NSURL *uuu = [NSURL URLWithString:[_webView mainFrameURL]];
        
        NSArray *urlComponents = [uuu.query componentsSeparatedByString:@"&"];
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc]init];
        NSString *oauth_verifier;
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            
            [queryStringDictionary setObject:value forKey:key];
        }
        //        oauth_token = queryStringDictionary[@"oauth_token"];
        oauth_verifier = queryStringDictionary[@"oauth_verifier"];
        NSLog(@"VERIFIER %@", oauth_verifier);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTwitterAccessToken" object:nil userInfo:@{@"verifier":oauth_verifier, @"consumer":consumerKey.stringValue,@"consumerSecret":consumerSecret.stringValue,@"tempToken":tempToken,@"tempTokenSecret":tempTokenSecret}];
        [_webView close];
        _webView.hidden=YES;
//        [self.view.window close];
        
       
    }
}
- (IBAction)backToPrefs:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:@"backToInfo" object:nil userInfo:@{@"name":@"twitter"}];
}
-(void)setFieldsEnabled{
    consumerKey.enabled=![RWData TwitterTokensEcxistsInCoreData];
    consumerSecret.enabled=![RWData TwitterTokensEcxistsInCoreData];
}
- (IBAction)removeAndAdd:(id)sender {
    [progress startAnimation:self];
    if([RWData TwitterTokensEcxistsInCoreData]){
        [RWData removeAllTwitterAppInfo:^(BOOL resultRemoveApp) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setFieldsEnabled];
                [self setButtonDest];
                [progress stopAnimation:self];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTwitterParamsInFields" object:nil];
            });
            
        }];
    }
    else{
        [self addApp];
    }
}
-(void)addApp{
    twitAuth = [[TwitterAuth alloc] initWithParams:consumerKey.stringValue consumerSecret:consumerSecret.stringValue];
    [twitAuth requestTempToken];
}
- (IBAction)resetToken:(id)sender {
    
}
-(void)setButtonDest{
    if([RWData TwitterTokensEcxistsInCoreData]){
        removeAndAddButton.title=@"Remove app";
        
        
    }else{
        removeAndAddButton.title = @"Add app";
    }
    
}
-(void)GetTwitterAccessToken:(NSNotification*)notification{
    [twitterAuth requestAccessTokenAndSecretToken:notification.userInfo[@"verifier"] :notification.userInfo[@"consumer"] :notification.userInfo[@"consumerSecret"] :notification.userInfo[@"tempToken"] :notification.userInfo[@"tempTokenSecret"]];
}
-(void)ObserveReadyTwitterTokens:(NSNotification*)notification{
    [RWData writeTokens:notification.userInfo];
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTwitterParamsInFields" object:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"backToInfo" object:nil userInfo:@{@"name":@"twitter"}];
        [self setButtonDest];
        [self setFieldsEnabled];
        [progress stopAnimation:self];
    
    });
    //    NSLog(@"%@", notification.userInfo);
}
@end
