//
//  TumblrAuth.h
//  MyTumblrLibrary
//
//  Created by sim on 06.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "TumblrClient.h"
@interface TumblrAuth : NSObject{
    NSString *oauth_consumer_key;
    NSString *oauth_consumer_secret_key;
    NSString *oauth_request_token_url;
    NSString *oauth_authorize_url;
    NSString *oauth_access_token_url;
    
    NSString *oauth_callback;
    NSString *oauth_nonce;
    NSString *oauth_version;
    NSString *oauth_signature_method ;
    NSString *oauth_timestamp;
    NSString *oauth_signature;
    NSTimeInterval timeInSeconds;
    NSString *api_token;
    NSString *keyForHash;
    NSString *dataForHash;
    NSMutableDictionary *queryStringDictionary;
    NSArray *urlComponents;
    
    NSString *oauth_token;
    NSString *oauth_token_secret;
    NSString *oauth_verifier;
    
    NSString *requestTokenResponse;
    
}
@property(nonatomic, readwrite)TumblrClient *client;
-(id)initWithParams:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret;
-(void)requestTempToken;
-(void)requestAccessTokenAndSecretToken:(id)verifier;

@end
