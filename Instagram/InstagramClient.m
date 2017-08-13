//
//  InstagramClient.m
//  MasterAPI
//
//  Created by sim on 04.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "InstagramClient.h"

@implementation InstagramClient
-(id)init{
    self = [super self];
    instaRWD = [[InstagramRWD alloc]init];
    _base_request_url = @"https://api.instagram.com/v1/";
    _session = [NSURLSession  sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    return self;
}
-(id)initWithTokensFromCoreData{
    self = [self init];
    NSDictionary *appInfoData =[instaRWD readInstagramTokens];
    _client_id = appInfoData[@"client_id"];
    _client_secret = appInfoData[@"client_secret"];
    _token = appInfoData[@"access_token"];
    return self;
}
-(void)APIRequest:(NSString *)params completion:(OnComplete)completion{
    fullRequestURL = [NSString stringWithFormat:@"%@%@?access_token=%@", _base_request_url, params, _token];
    NSLog(@"FULL INSTA API REQUEST %@", fullRequestURL);
    [[_session dataTaskWithURL:[NSURL URLWithString:fullRequestURL]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completion(data);
    }] resume];
}
-(void)getUserInfo:(OnComplete)completion{
    [[_session dataTaskWithURL:[NSURL URLWithString:@"https://instagram.com/kostyabobby/?__a=1"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completion(data);
    }]resume];
}
-(void)apiRequest:(NSString *)params completion:(OnComplete)completion{
    [[_session dataTaskWithURL:[NSURL URLWithString:params]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completion(data);
    }] resume];
}
@end
