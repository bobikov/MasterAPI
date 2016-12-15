//
//  TwitterClient.h
//  MasterAPI
//
//  Created by sim on 11.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonHMAC.h>
#import "TwitterRWData.h"

@interface TwitterClient : NSObject <NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property(nonatomic, readwrite) NSString *oauth_request_token_url;
@property(nonatomic, readwrite) NSString *oauth_authorize_url;
@property(nonatomic, readwrite) NSString *oauth_access_token_url;
@property(nonatomic, readwrite) NSString *oauth_temp_token_secret;
@property(nonatomic, readwrite) NSString *oauth_temp_token;
@property(nonatomic, readwrite) NSString *oauth_token_secret;
@property(nonatomic, readwrite) NSString *oauth_token;
@property(nonatomic, readwrite) NSTimeInterval timeInSeconds;
@property(nonatomic, readwrite) NSString *oauth_callback;
@property(nonatomic, readwrite) NSString *oauth_version;
@property(nonatomic, readwrite) NSString *oauth_timestamp;
@property(nonatomic, readwrite) NSString *oauth_nonce;
@property(nonatomic, readwrite) NSString *oauth_signature_method;
@property(nonatomic, readwrite) NSString *oauth_signature;
@property(nonatomic, readwrite) NSString *oauth_consumer_key;
@property(nonatomic, readwrite) NSString *oauth_consumer_secret_key;
@property(nonatomic, readwrite) NSString *oauth_verifier;
@property(nonatomic, readwrite) NSString *keyForHash;
@property(nonatomic, readwrite)NSMutableURLRequest *request;
@property(nonatomic, readwrite)TwitterRWData *TwitterRWD;
@property (nonatomic, strong)NSURLSession *backgroundSession;
@property(nonatomic, readwrite)NSString *oauth_base_method;
@property(nonatomic, readwrite)NSString *adMethodsJoin;
//@property(nonatomic, readwrite)TwitterUpdateAvatarController *controller;


@property(nonatomic, readwrite) NSURLSession *TSession;

- (id)initWithTokensFromCoreData;
- (id)initWithToken:(NSString*)token secretToken:(NSString*)secretToken consumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret;
- (id)initWithParams:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret;
- (NSString *)hash:(NSString *)data secret:(NSString *)key;
- (NSString*)createNonce;
typedef void (^OnComplete) (NSData *data);

-(void)APIRequest:(NSString*)amethod rmethod:(NSString*)bmethod query:(NSDictionary*)rparams handler:(OnComplete)completion;
@end
