//
//  InstagramAuth.m
//  MasterAPI
//
//  Created by sim on 04.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "InstagramAuth.h"

@implementation InstagramAuth
@synthesize clientSecret,clientId,requestAccessTokenURL,redirect_uri,responseType,authorize_url,authorizeFullURL,scope;
-(id)init{
    self = [super self];
    instaClient = [[InstagramClient alloc]init];
    authorize_url = @"https://api.instagram.com/oauth/authorize/?";
    scope = @"basic+public_content+follower_list+comments+relationships+likes";
//    scope = @"follower_list";
    redirect_uri = [@"https://instagram.com/auth" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    requestAccessTokenURL=@"https://api.instagram.com/oauth/access_token";
    responseType = @"code";
//    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
//    instaLoginContr = [story instantiateControllerWithIdentifier:@"InstagramLoginViewController"];
    return self;
}

-(id)initWithParams:(NSString *)client_id client_secret:(NSString*)client_secret{
    self = [self init];
    clientId = client_id;
    clientSecret = client_secret;
    authorizeFullURL =[NSString stringWithFormat:@"%@client_id=%@&redirect_uri=%@&scope=%@&response_type=%@", authorize_url,clientId,redirect_uri,scope,responseType];
    
    return self;
}
-(void)requestCode{

    [[NSNotificationCenter defaultCenter] postNotificationName:@"authorizeInstagramInBrowser" object:nil userInfo:@{@"url":authorizeFullURL}];
//    [instaLoginContr.webView setMainFrameURL:authorizeFullURL];
//    instaLoginContr.webView.hidden=NO;

    
}
-(void)requestAccessToken:(NSString*)code completion:(OnComplete)completion{
    NSLog(@"%@", [NSString stringWithFormat:@"%@client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@", requestAccessTokenURL, clientId, clientSecret, redirect_uri, code]);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setHTTPMethod:@"POST"];
    [request setURL:[NSURL URLWithString:requestAccessTokenURL]];
    [request setHTTPBody:[[NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@", clientId, clientSecret, redirect_uri, code] dataUsingEncoding:NSUTF8StringEncoding]];
    [[instaClient.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        completion(data);
    }]resume];
    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:requestAccessTokenURL];
}
@end
