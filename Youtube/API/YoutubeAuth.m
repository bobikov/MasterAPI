//
//  YoutubeAuth.m
//  MasterAPI
//
//  Created by sim on 12.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "YoutubeAuth.h"
#import "YoutubePerms.h"
@implementation YoutubeAuth

-(id)init{
    self = [super self];
    _client = [[YoutubeClient alloc]init];
    return self;
}
-(id)initWithParams:(NSString*)client_id   client_secret:(NSString*)client_secret{
    
    self = [self init];
    _client = [[YoutubeClient alloc]init];
    _client.oauth_client_id = client_id;
    _client.oauth_client_secret = client_secret;
    
    return self;
}
-(void)requestTempToken{
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
    YoutubePerms *youtubePerms = [story instantiateControllerWithIdentifier:@"YoutubePerms"];
    _client.oauth_callback = [_client.oauth_callback stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *requestTempTokenURL = [NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=%@&scope=%@&access_type=%@&prompt=consent", _client.request_temp_token_url, _client.oauth_client_id, _client.oauth_callback, _client.oauth_response_type, _client.oauth_scope, _client.oauth_access_type];
    NSLog(@"%@", requestTempTokenURL);
    [youtubePerms presentViewControllerAsModalWindow:youtubePerms];
//    [_client.YSession dataTaskWithURL:[NSURL URLWithString:requestTempTokenURL]];
    [[youtubePerms webView]setMainFrameURL:requestTempTokenURL];
}
-(void)requestAccessToken:(id)oauth_code{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    NSString *requestBody = [NSString stringWithFormat:@"code=%@&client_id=%@&client_secret=%@&redirect_uri=%@&grant_type=%@", oauth_code, _client.oauth_client_id, _client.oauth_client_secret, _client.oauth_callback, _client.oauth_grant_type];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"accounts.google.com" forHTTPHeaderField:@"Host"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [request setURL:[NSURL URLWithString:_client.request_access_token_url]];
    [[_client.YSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *getAccessTokenResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", getAccessTokenResponse);
        NSDictionary *tokenData =@{@"access_token":getAccessTokenResponse[@"access_token"], @"client_id":_client.oauth_client_id, @"client_secret":_client.oauth_client_secret, @"token_type":getAccessTokenResponse[@"token_type"] ? getAccessTokenResponse[@"token_type"] : @"", @"refresh_token":getAccessTokenResponse[@"refresh_token"] ? getAccessTokenResponse[@"refresh_token"] : @""};
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ObserveReadyYoutubeTempToken" object:nil userInfo:tokenData];
    }]resume];
}
@end
