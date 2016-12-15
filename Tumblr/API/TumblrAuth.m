//
//  TumblrAuth.m
//  MyTumblrLibrary
//
//  Created by sim on 06.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TumblrAuth.h"
#import "TumblrPermsController.h"
@implementation TumblrAuth
-(id)init{
    self = [super self];
     _client = [[TumblrClient alloc]init];
    return self;
}
-(id)initWithParams:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret{
    
    self = [self init];
    queryStringDictionary = [[NSMutableDictionary alloc]init];
    _client = [[TumblrClient alloc]init];
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
    _client.oauth_signature =  [_client hash:_client.oauth_signature secret:keyForHash];
    
    NSString *requestHeader=[NSString stringWithFormat:@"OAuth oauth_callback=\"%@\",oauth_consumer_key=\"%@\",oauth_nonce=\"%@\",oauth_signature=\"%@\",oauth_signature_method=\"%@\",oauth_timestamp=\"%@\",oauth_version=\"%@\"",  _client.oauth_callback, _client.oauth_consumer_key, _client.oauth_nonce, _client.oauth_signature, _client.oauth_signature_method, _client.oauth_timestamp, _client.oauth_version] ;

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://www.tumblr.com/oauth/request_token"]];
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
        NSStoryboard *story = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
        TumblrPermsController *TContr = [story instantiateControllerWithIdentifier:@"TumblrPerms"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [TContr presentViewControllerAsModalWindow:TContr];
            
            [[TContr webView]setMainFrameURL:[NSString stringWithFormat:@"%@?oauth_token=%@&oauth_token_secret=%@",_client.oauth_authorize_url, _client.oauth_temp_token, _client.oauth_temp_token_secret]];
        });
   
    }]resume];
   
    
}

-(void)requestAccessTokenAndSecretToken:(id)verifier{
    
    _client.oauth_nonce = [NSString stringWithFormat:@"%@",  _client.createNonce];
    _client.oauth_timestamp = [NSString stringWithFormat:@"%.f", _client.timeInSeconds];
    keyForHash = [NSString stringWithFormat:@"%@&%@", [_client.oauth_consumer_secret_key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], [_client.oauth_temp_token_secret stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    _client.oauth_access_token_url = [[NSString stringWithFormat:@"%@&", _client.oauth_access_token_url] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    _client.oauth_signature = [[[[NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_verifier=%@&oauth_version=%@",  _client.oauth_consumer_key, _client.oauth_nonce, _client.oauth_signature_method, _client.oauth_timestamp, _client.oauth_temp_token, verifier, _client.oauth_version] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    _client.oauth_signature = [NSString stringWithFormat:@"POST&%@%@", _client.oauth_access_token_url, _client.oauth_signature];
    _client.oauth_signature =  [_client hash:_client.oauth_signature secret:keyForHash];
    NSString *requestHeader=[NSString stringWithFormat:@"OAuth oauth_consumer_key=\"%@\",oauth_nonce=\"%@\",oauth_signature=\"%@\",oauth_signature_method=\"%@\",oauth_timestamp=\"%@\",oauth_token=\"%@\",oauth_verifier=\"%@\",oauth_version=\"%@\"",   _client.oauth_consumer_key, _client.oauth_nonce, _client.oauth_signature, _client.oauth_signature_method, _client.oauth_timestamp, _client.oauth_temp_token, verifier, _client.oauth_version] ;
    NSLog(@"%@", requestHeader);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:@"https://www.tumblr.com/oauth/access_token"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:requestHeader forHTTPHeaderField:@"Authorization"];
    [[_client.TSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *requestAccessTokenResp = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
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
        
//        NSLog(@"oauth_token %@", _client.oauth_token);
//        NSLog(@"oauth_token_secret %@", _client.oauth_token_secret);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ObserveReadyTumblrTokens" object:nil userInfo:@{@"oauth_token":_client.oauth_token, @"oauth_token_secret":_client.oauth_token_secret, @"consumer_key":_client.oauth_consumer_key, @"consumer_secret_key":_client.oauth_consumer_secret_key}];
//        return @{@"oauth_token":_client.oauth_token, @"oauth_token_secret":_client.oauth_token_secret};
        
    }]resume];
   
}



@end
