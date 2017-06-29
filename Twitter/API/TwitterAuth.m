//
//  TwitterAuth.m
//  MasterAPI
//
//  Created by sim on 11.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TwitterAuth.h"
#import "TwitterPerms.h"
@implementation TwitterAuth

-(id)init{
    self = [super self];
    _client = [[TwitterClient alloc]init];
    queryStringDictionary = [[NSMutableDictionary alloc]init];
    return self;
}
-(id)initWithParams:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret{
    
    self = [self init];
  
    _client = [[TwitterClient alloc]init];
    _client.oauth_consumer_key = consumerKey;
    _client.oauth_consumer_secret_key = consumerSecret;
    
    return self;
}
-(void)requestTempToken{
    
    keyForHash = [NSString stringWithFormat:@"%@&", [_client.oauth_consumer_secret_key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    _client.oauth_nonce = [_client createNonce];
    _client.oauth_timestamp = [NSString stringWithFormat:@"%.f", _client.timeInSeconds];
    _client.oauth_request_token_url = [[NSString stringWithFormat:@"%@&", _client.oauth_request_token_url] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    _client.oauth_callback = [_client.oauth_callback stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    _client.oauth_consumer_key = [_client.oauth_consumer_key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    _client.oauth_nonce = [_client.oauth_nonce stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    _client.oauth_signature_method = [_client.oauth_signature_method stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    _client.oauth_timestamp = [_client.oauth_timestamp stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    _client.oauth_version = [_client.oauth_version stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    _client.oauth_signature = [[[[NSString stringWithFormat:@"oauth_callback=%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_version=%@", _client.oauth_callback, _client.oauth_consumer_key, _client.oauth_nonce, _client.oauth_signature_method, _client.oauth_timestamp, _client.oauth_version] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    
    _client.oauth_signature = [NSString stringWithFormat:@"POST&%@%@", _client.oauth_request_token_url, _client.oauth_signature];
    _client.oauth_signature =  [[[[[_client hash:_client.oauth_signature secret:keyForHash] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"] stringByReplacingOccurrencesOfString:@"\\" withString:@"%5C"]stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    
    NSString *requestHeader=[NSString stringWithFormat:@"OAuth oauth_callback=\"%@\",oauth_consumer_key=\"%@\",oauth_nonce=\"%@\",oauth_signature=\"%@\",oauth_signature_method=\"%@\",oauth_timestamp=\"%@\",oauth_version=\"%@\"",  _client.oauth_callback, _client.oauth_consumer_key, _client.oauth_nonce, _client.oauth_signature, _client.oauth_signature_method, _client.oauth_timestamp, _client.oauth_version] ;
//    NSLog(@"%@", requestHeader);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:requestHeader forHTTPHeaderField:@"Authorization"];
    [[_client.TSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *requestTokenResp = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
//        NSLog(@"%@", requestTokenResp);
        urlComponents = [requestTokenResp componentsSeparatedByString:@"&"];;
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            
            [queryStringDictionary setObject:value forKey:key];
        }
        _client.oauth_temp_token = queryStringDictionary[@"oauth_token"];
        _client.oauth_temp_token_secret = queryStringDictionary[@"oauth_token_secret"];
        //        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetTumblrToken" object:self userInfo:@{@"oauth_temp_token":_client.oauth_temp_token, @"oauth_temp_secret_token":_client.oauth_temp_token_secret }];
        authorizeFullURL = [NSString stringWithFormat:@"%@?oauth_token=%@&oauth_token_secret=%@",_client.oauth_authorize_url, _client.oauth_temp_token, _client.oauth_temp_token_secret];
//        NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
//        TwitterPerms *TContr = [story instantiateControllerWithIdentifier:@"TwitterPerms"];
        dispatch_async(dispatch_get_main_queue(), ^{
             [[NSNotificationCenter defaultCenter] postNotificationName:@"authorizeTwitterInBrowser" object:nil userInfo:@{@"url":authorizeFullURL, @"temp_token":_client.oauth_temp_token, @"temp_token_secret":_client.oauth_temp_token_secret}];
        });
        
    }]resume];
    
    
}

-(void)requestAccessTokenAndSecretToken:(id)verifier :(NSString*)consumer :(NSString*)comsumerSecret :(NSString*)tempToken :(NSString *)tempTokenSecret{
    
    _client.oauth_nonce = [NSString stringWithFormat:@"%@",  [_client createNonce]];
    _client.oauth_timestamp = [NSString stringWithFormat:@"%.f", _client.timeInSeconds];
    keyForHash = [NSString stringWithFormat:@"%@&%@", [consumer stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], [tempTokenSecret stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    _client.oauth_access_token_url = [[NSString stringWithFormat:@"%@&", _client.oauth_access_token_url] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    _client.oauth_signature = [[[[NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_verifier=%@&oauth_version=%@",  consumer, _client.oauth_nonce, _client.oauth_signature_method, _client.oauth_timestamp, tempToken, verifier, _client.oauth_version] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    _client.oauth_signature = [NSString stringWithFormat:@"POST&%@%@", _client.oauth_access_token_url, _client.oauth_signature];
    _client.oauth_signature =  [[[[[_client hash:_client.oauth_signature secret:keyForHash] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"] stringByReplacingOccurrencesOfString:@"\\" withString:@"%5C"]stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    
    NSString *requestHeader=[NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\",oauth_nonce=\"%@\",oauth_signature=\"%@\",oauth_signature_method=\"%@\",oauth_timestamp=\"%@\",oauth_token=\"%@\",oauth_verifier=\"%@\",oauth_version=\"%@\"",   consumer, _client.oauth_nonce, _client.oauth_signature, _client.oauth_signature_method, _client.oauth_timestamp, tempToken, verifier, _client.oauth_version] ;
    NSLog(@"%@", requestHeader);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:requestHeader forHTTPHeaderField:@"Authorization"];
    [[_client.TSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *requestAccessTokenResp = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
//        NSDictionary *requestAccessTokenResp =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"%@", requestAccessTokenResp);
        urlComponents = [requestAccessTokenResp componentsSeparatedByString:@"&"];
        [queryStringDictionary removeAllObjects];
        for (NSString *keyValuePair in urlComponents)
        {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
            NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
            
            [queryStringDictionary setObject:value forKey:key];
        }
        _client.oauth_token = queryStringDictionary[@"oauth_token"];
        _client.oauth_token_secret = queryStringDictionary[@"oauth_token_secret"];
//        NSLog(@"%@",  _client.oauth_token );
//        NSLog(@"%@",   _client.oauth_token_secret );
//        NSLog(@"%@",queryStringDictionary );
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ObserveReadyTwitterTokens" object:nil userInfo:@{@"oauth_token":_client.oauth_token, @"oauth_token_secret":_client.oauth_token_secret, @"consumer_key":consumer, @"consumer_secret_key":comsumerSecret}];
        

        
    }]resume];
}
@end
