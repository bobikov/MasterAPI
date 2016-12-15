//
//  InstagramLoginViewController.m
//  MasterAPI
//
//  Created by sim on 04.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "InstagramLoginViewController.h"

@interface InstagramLoginViewController ()<WebFrameLoadDelegate>

@end

@implementation InstagramLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView.frameLoadDelegate=self;
    instaRWD = [[InstagramRWD alloc]init];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(authorize:) name:@"authorizeInstagramInBrowser" object:nil];
}
-(void)authorize:(NSNotification*)notification{
    _webView.hidden=NO;
    NSLog(@"%@", notification.userInfo[@"url"]);
    [_webView setMainFrameURL:notification.userInfo[@"url"]];
    
    
    
}
- (IBAction)acceptData:(id)sender {
    instaAuth = [[InstagramAuth alloc]initWithParams:clientId.stringValue client_secret:clientSecret.stringValue];
    [instaAuth requestCode];
    
    NSLog(@"%@",clientId.stringValue);
    NSLog(@"%@", clientSecret.stringValue);
}
-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
//    NSString *fullQuery = [[NSURL URLWithString:[[sender mainFrameURL] stringByReplacingOccurrencesOfString:@"#" withString:@"?"]]query];
//    NSArray *queryComponents= [fullQuery componentsSeparatedByString:@"&"];
//    NSLog(@"%@", [_webView mainFrameURL]);
    if([[_webView mainFrameURL]containsString:@"code"]){
        NSURL *uuu = [NSURL URLWithString:[_webView mainFrameURL]];
        
        NSArray *urlComponents = [uuu.query componentsSeparatedByString:@"&"];
        
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc]init];
        NSString *code;
        for(NSString *query in urlComponents ){
            NSArray *pairComponents = [query componentsSeparatedByString:@"="];
            NSString *key = [pairComponents firstObject];
            NSString *value = [pairComponents lastObject];
            [queryStringDictionary setObject:value forKey:key];
        }
        NSLog(@"%@", queryStringDictionary);
        code = queryStringDictionary[@"code"];
         [instaAuth requestAccessToken:code completion:^(NSData *data) {
             if(data){
                 NSDictionary *requestTokenResp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                 NSLog(@"%@", requestTokenResp);
                 [instaRWD writeInstagramToken:@{@"data":requestTokenResp, @"client":@{@"clientId":instaAuth.clientId, @"clientSecret":instaAuth.clientSecret}}];
              
                 dispatch_async(dispatch_get_main_queue(),^{
                     
                     [[NSNotificationCenter defaultCenter]postNotificationName:@"loadInstagramAppInfoInPrefs" object:nil];
                     [self dismissController:self];
                 });
             }
         }];
          [_webView close];
        _webView.hidden=YES;
        
    }
//    if([[_webView mainFrameURL] containsString:@"code="]){
//        NSString *code;
//      
//        }];
//    }
}
@end
