//
//  YoutubeClient.m
//  MasterAPI
//
//  Created by sim on 12.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "YoutubeClient.h"

@implementation YoutubeClient
-(id)init{
    self = [super self];
    _request_temp_token_url = @"https://accounts.google.com/o/oauth2/auth";
    _oauth_callback = @"https://google.com/auth";
    _oauth_scope = @"https://www.googleapis.com/auth/youtube https://www.googleapis.com/auth/youtube.readonly https://www.googleapis.com/auth/youtube.upload";
    _request_access_token_url = @"https://accounts.google.com/o/oauth2/token";
    _oauth_access_type = @"offline";
    _oauth_response_type = @"code";
    _oauth_grant_type = @"authorization_code";
    _base_api_URL = @"https://www.googleapis.com/youtube/v3/";
    _YSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    return self;
}
- (id)initWithParams:(NSString*)client_id client_secret:(NSString*)client_secret{
    self = [self init];
    _oauth_client_id = client_id;
    _oauth_client_secret = client_secret;
    return self;
}
- (id)initWithToken:(NSString*)access_token client_id:(NSString*)client_id client_secret:(NSString*)client_secret token_type:(NSString*)token_type{
    self = [self init];
    _oauth_client_id = client_id;
    _oauth_client_secret = client_secret;
    _oauth_access_token = access_token;
    _oauth_token_type = token_type;
    return self;
}
- (id)initWithTokensFromCoreData{
    _YSession = [NSURLSession  sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    self = [self init];
    _YoutubeRWD= [[YoutubeRWData alloc]init];
    NSDictionary *tokens = [_YoutubeRWD readYoutubeTokens];
    
    return [self initWithToken:tokens[@"access_token"] client_id:tokens[@"client_id"] client_secret:tokens[@"client_secret"] token_type:tokens[@"token_type"]];
}
-(void)APIRequest:(NSString*)method  query:(NSDictionary*)params handler:(OnComplete)completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
   
    NSURLComponents *queryComponents = [[NSURLComponents alloc] init];
    NSMutableArray *queryItems = [[NSMutableArray alloc]init];
    for(int i = 0; i<[[params allKeys] count]; i++){
        [queryItems addObject:[NSURLQueryItem queryItemWithName:[params allKeys][i] value: [NSString stringWithFormat:@"%@",[params valueForKey:[params allKeys][i]]]]];
    }
    queryComponents.queryItems = queryItems;
    _oauth_access_token = [[[_oauth_access_token stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];

    NSString *requestURL=[NSString stringWithFormat:@"%@%@%@", _base_api_URL, method, [queryComponents.queryItems count] > 0 ? [NSString stringWithFormat:@"?%@",[queryComponents query]] : @""];
//    NSString *requestURL=[NSString stringWithFormat:@"%@%@%@&access_token=%@", _base_api_URL, method, [queryComponents.queryItems count] > 0 ? [NSString stringWithFormat:@"?%@",[queryComponents query]] : @"", _oauth_access_token];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    NSString *requestHeader = [NSString stringWithFormat:@"%@ %@", _oauth_token_type, _oauth_access_token];
//    NSLog(@"%@", requestURL);
//    NSLog(@"%@", requestHeader);
    [request setURL:[NSURL URLWithString:requestURL]];
//    [request setHTTPMethod:@"GET"];
    [request valueForHTTPHeaderField:[NSString stringWithFormat:@"GET /youtube/v3/%@%@", method, [queryComponents.queryItems count] > 0 ? [NSString stringWithFormat:@"?%@",[queryComponents query]] : @""]];
    [request setValue:@"www.googleapis.com" forHTTPHeaderField:@"Host"];
    [request setValue:requestHeader forHTTPHeaderField:@"Authorization"];
    [[_YSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSString *resp = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
//        NSLog(@"%@", resp);
        completion(data);
    }]resume];
//    [[_YSession dataTaskWithURL:[NSURL URLWithString:requestURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSString *resp = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
//                NSLog(@"%@", resp);
//    }]resume];
     });
    
}
-(void)refreshToken:(OnComplete)completion{
    _YoutubeRWD= [[YoutubeRWData alloc]init];
    NSDictionary *tokens=[_YoutubeRWD readYoutubeTokens];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    NSString *requestBody=[NSString stringWithFormat:@"client_id=%@&client_secret=%@&refresh_token=%@&grant_type=refresh_token", tokens[@"client_id"], tokens[@"client_secret"], tokens[@"refresh_token"]];
    [request setURL:[NSURL URLWithString:_request_access_token_url]];
    [request setHTTPMethod:@"POST"];
    [request valueForHTTPHeaderField:@"POST /o/oauth2/token HTTP/1.1"];
    [request setValue:@"accounts.google.com" forHTTPHeaderField:@"Host"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    [[_YSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSDictionary *refreshTokenResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"%@", refreshTokenResponse);
        completion(data);
    }]resume];
}
@end
