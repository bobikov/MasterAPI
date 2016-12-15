//
//  TumblrPermsController.m
//  MasterAPI
//
//  Created by sim on 07.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TumblrPermsController.h"
#import "TumblrAuth.h"
@interface TumblrPermsController ()<WebFrameLoadDelegate>

@end

@implementation TumblrPermsController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView.frameLoadDelegate = self;
    
    
}
-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTumblrAccessToken" object:nil userInfo:@{@"verifier":oauth_verifier}];
        [_webView close];
        [self.view.window close];
    }
}
@end
