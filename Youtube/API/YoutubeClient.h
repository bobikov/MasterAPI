//
//  YoutubeClient.h
//  MasterAPI
//
//  Created by sim on 12.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YoutubeRWData.h"
@interface YoutubeClient : NSObject
@property(nonatomic, readwrite)NSString *oauth_client_id;
@property(nonatomic, readwrite)NSString *oauth_client_secret;
@property(nonatomic, readwrite)NSString *oauth_temp_token;
@property(nonatomic, readwrite)NSString *oauth_callback;
@property(nonatomic, readwrite)NSString *request_temp_token_url;
@property(nonatomic, readwrite)NSString *request_access_token_url;
@property(nonatomic, readwrite)NSString *oauth_response_type;
@property(nonatomic, readwrite)NSString *oauth_scope;
@property(nonatomic, readwrite)NSString *oauth_access_type;
@property(nonatomic, readwrite)NSString *oauth_grant_type;
@property(nonatomic, readwrite)NSString *oauth_access_token;
@property(nonatomic, readwrite)NSString *oauth_token_type;
@property(nonatomic, readwrite)NSString *base_api_URL;
@property(nonatomic, readwrite)YoutubeRWData *YoutubeRWD;
@property(nonatomic, readwrite) NSURLSession *YSession;
- (id)initWithParams:(NSString*)client_id client_secret:(NSString*)client_secret;
- (id)initWithToken:(NSString*)access_token client_id:(NSString*)client_id client_secret:(NSString*)client_secret token_type:(NSString*)token_type;
- (id)initWithTokensFromCoreData;
    typedef void (^OnComplete3) (NSData *data);
-(void)APIRequest:(NSString*)method  query:(NSDictionary*)rparams handler:(OnComplete3)completion;
-(void)refreshToken:(OnComplete3)completion;
@end
