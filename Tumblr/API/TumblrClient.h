//
//  TumblrClient.h
//  MyTumblrLibrary
//
//  Created by sim on 06.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TumblrSession.h"
#import <CommonCrypto/CommonHMAC.h>
#import "TumblrRWData.h"
@interface TumblrClient : NSObject{

}
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
@property(nonatomic, readwrite) NSString *oauth_base_method;
@property(nonatomic, readwrite) NSString *adMethodsJoin;
@property(nonatomic, readwrite) NSString *keyForHash;
@property(nonatomic, readwrite) NSMutableURLRequest *request;
@property(nonatomic, readwrite) TumblrRWData *TumblrRWD;


@property(nonatomic, readwrite) NSURLSession *TSession;
//- (void)dashboard:(NSDictionary*)params;
//- (void)following:(NSDictionary*)params;
- (id)initWithTokensFromCoreData;
- (id)initWithToken:(NSString*)token secretToken:(NSString*)secretToken consumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret;
- (id)initWithParams:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret;
- (NSString *)hash:(NSString *)data secret:(NSString *)key;
- (NSString*)createNonce;
 typedef void (^OnComplete) (NSData *data);
-(void)APIRequest:(NSString*)owner rmethod:(NSString*)rmethod query:(NSDictionary*)rparams handler:(OnComplete)completion;
@end
