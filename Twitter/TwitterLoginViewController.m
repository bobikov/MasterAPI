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
   
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(authorize:) name:@"authorizeTwitterInBrowser" object:nil];
}
-(void)authorize:(NSNotification*)notification{
    _webView.hidden=NO;
    NSLog(@"%@", notification.userInfo[@"url"]);
    tempToken = notification.userInfo[@"temp_token"];
    tempTokenSecret = notification.userInfo[@"temp_token_secret"];
    [_webView setMainFrameURL:notification.userInfo[@"url"]];
    
    
    
}
- (IBAction)acceptData:(id)sender {
     twitAuth = [[TwitterAuth alloc]initWithParams:consumerKey.stringValue consumerSecret:consumerSecret.stringValue];
    [twitAuth requestTempToken];
    
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
        
        //        TumblrAuth *auth = [[TumblrAuth alloc]init];
        //        [auth requestAccessTokenAndSecretToken:oauth_verifier];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTwitterAccessToken" object:nil userInfo:@{@"verifier":oauth_verifier, @"consumer":consumerKey.stringValue,@"consumerSecret":consumerSecret.stringValue,@"tempToken":tempToken,@"tempTokenSecret":tempTokenSecret}];
        [_webView close];
        [self.view.window close];
    }
}
@end
