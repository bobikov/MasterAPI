//
//  YoutubePerms.m
//  MasterAPI
//
//  Created by sim on 12.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "YoutubePerms.h"

@interface YoutubePerms ()<WebFrameLoadDelegate>

@end

@implementation YoutubePerms

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView.frameLoadDelegate=self;
}
-(void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame{
    if([[_webView mainFrameURL]containsString:@"code"]){
        NSURL *uuu = [NSURL URLWithString:[_webView mainFrameURL]];
        
        NSArray *urlComponents = [uuu.query componentsSeparatedByString:@"&"];
        
        NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc]init];
        NSString *oauth_code;
        for(NSString *query in urlComponents ){
            NSArray *pairComponents = [query componentsSeparatedByString:@"="];
            NSString *key = [pairComponents firstObject];
            NSString *value = [pairComponents lastObject];
            [queryStringDictionary setObject:value forKey:key];
        }
//        NSLog(@"%@", queryStringDictionary);
        oauth_code = queryStringDictionary[@"code"];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"GetYoutubeAccessToken" object:nil userInfo:@{@"code":oauth_code}];
        [_webView close];
        [self.view.window close];
    }
    
}
@end
