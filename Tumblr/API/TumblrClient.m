//
//  TumblrClient.m
//  MyTumblrLibrary
//
//  Created by sim on 06.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TumblrClient.h"
//#import "NSString+RMURLEncoding.h"
#import <NSHash/NSString+NSHash.h>
#import <NAHMAC.h>
#import "NSString+SHA1HMAC.h"
#import "NSString+MD5HMAC.h"
@implementation TumblrClient
@synthesize  request;

-(id)init{
    self = [super self];
    _TSession = [NSURLSession  sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    _oauth_request_token_url = @"https://www.tumblr.com/oauth/request_token";
    _oauth_authorize_url = @"https://www.tumblr.com/oauth/authorize";
    _oauth_access_token_url = @"https://www.tumblr.com/oauth/access_token";
    _oauth_callback = @"tumblr.com/auth";
    _oauth_version = @"1.0";
    _timeInSeconds = [[NSDate date] timeIntervalSince1970];
    _oauth_timestamp = [NSString stringWithFormat:@"%.f", _timeInSeconds];
    _oauth_signature_method = @"HMAC-SHA1";
    _oauth_base_method = @"https://api.tumblr.com/v2/";
    request = [[NSMutableURLRequest alloc]init];
    return self;
}
- (id)initWithParams:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret{
    _TSession = [NSURLSession  sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    self = [self init];
    _oauth_consumer_key = consumerKey;
    _oauth_consumer_secret_key = consumerSecret;
    return self;
}
- (id)initWithTokensFromCoreData{
    _TSession = [NSURLSession  sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    self = [self init];
    _TumblrRWD= [[TumblrRWData alloc]init];
    NSDictionary *tokens = [_TumblrRWD readTumblrTokens];
    
    return [self initWithToken:tokens[@"token"] secretToken:tokens[@"secret_token"] consumerKey:tokens[@"consumer_key"] consumerSecret:tokens[@"consumer_secret_key"]];
}
- (id)initWithToken:(NSString*)token secretToken:(NSString*)secretToken consumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret{
    self = [self init];
    _TSession = [NSURLSession  sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    _oauth_token = token;
    _oauth_token_secret = secretToken;
    _oauth_consumer_key = consumerKey;
    _oauth_consumer_secret_key = consumerSecret;
    return self;
}



-(void)APIRequest:(NSString*)owner rmethod:(NSString*)rmethod query:(NSDictionary*)rparams handler:(OnCompleteRequest)completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSString *queryString;
        __block NSString *HttpMethod;
        __block NSString *method;
//        __block NSString *requestHeader;
        
        NSURLComponents *queryComponents = [[NSURLComponents alloc] init];

//        NSLog(@"rparams %@", rparams);
        queryComponents.queryItems = [rparams count] > 0 ? [self getQueryItems:rparams] : nil;
        queryString = queryComponents.queryItems!=nil ? [queryComponents query] : nil;
    
        method =  [self createAndEncodeMethod:owner :rmethod];
//        NSLog(@"method %@", method);
        if([rmethod isEqual:@"followers"]){
            HttpMethod = @"GET";
            _oauth_signature = [self createSignature:method httpMethod:HttpMethod media:nil query:queryString];
            [self setStandardHeaders:HttpMethod :queryString];
        }
        else if([rmethod isEqual:@"following"]){
            HttpMethod = @"GET";
             _oauth_signature = [self createSignature:method httpMethod:HttpMethod media:nil query:queryString];
            [self setStandardHeaders:HttpMethod :queryString];
//
        }
        else if([rmethod isEqual:@"post"]){
            HttpMethod = @"POST";
            _oauth_signature =  [self createSignature:method httpMethod:HttpMethod media:nil query:queryString];
//            [self setStandardHeaders:HttpMethod :queryString];
             [self setHeadersWithBody:queryString];
//            NSLog(@"%@", queryString);
            
        }
        else if([rmethod isEqual:@"posts/photo"]){
            HttpMethod = @"GET";
            _oauth_signature = [self createSignature:method httpMethod:HttpMethod media:nil query:queryString];
            [self setStandardHeaders:HttpMethod :queryString];
        }
        else if([rmethod isEqual:@"info"]){
            HttpMethod = @"GET";
            _oauth_signature = [self createSignature:method httpMethod:HttpMethod media:nil query:queryString];
            [self setStandardHeaders:HttpMethod :queryString];
        }
        else if([rmethod isEqual:@"tagged"]){
            HttpMethod = @"GET";
            _oauth_signature = [self createSignature:method httpMethod:HttpMethod media:nil query:queryString];
            [self setStandardHeaders:HttpMethod :queryString];
        }
        [self startRequest:^(NSData *data) {
            completion(data);
        }];
    });
}



-(void)startRequest:(OnCompleteRequest)completion{
    [[_TSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        completion(data);
//        NSString *resp = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", resp);
        
        
    }]resume];
}
-(void)createTimestampAndNonce{
    _oauth_timestamp = [NSString stringWithFormat:@"%.f", _timeInSeconds];
    _oauth_nonce = [self createNonce];
}
-(id)createAndEncodeMethod:(id)ownerInJoinedParams :(id)methodInJoinedParams{
    NSString *method;
    _adMethodsJoin = ownerInJoinedParams ? [NSString stringWithFormat:@"%@/%@", ownerInJoinedParams, methodInJoinedParams] : [NSString stringWithFormat:@"%@", methodInJoinedParams] ;
    method = [NSString stringWithFormat:@"%@%@", _oauth_base_method, _adMethodsJoin ];
    method = [[NSString stringWithFormat:@"%@", method] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    return method;
}
-(void)setHeadersWithBody:(id)queryString{
    
    [request setHTTPMethod:@"POST"];
    [request valueForHTTPHeaderField:[NSString stringWithFormat:@"%@ /v2/%@", @"POST", _adMethodsJoin]];
    [request setValue:[self createHeader] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"api.tumblr.com" forHTTPHeaderField:@"Host"];

    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _oauth_base_method, _adMethodsJoin ]]];
    [request setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
    
}
-(void)setStandardHeaders:(id)httpMethod :(id)queryString{
//    NSLog(@"Query string %@", queryString);
    [request setHTTPMethod:httpMethod];
    [request valueForHTTPHeaderField:[NSString stringWithFormat:@"%@ /v2/%@%@", httpMethod, _adMethodsJoin, queryString!=nil ? [NSString stringWithFormat:@"%@&", queryString] : @""]];
    [request setValue:[self createHeader] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"api.tumblr.com" forHTTPHeaderField:@"Host"];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", _oauth_base_method, _adMethodsJoin, queryString!=nil ? [NSString stringWithFormat:@"?%@", queryString] : @""]] ];
//    NSLog(@"%@", [NSString stringWithFormat:@"%@%@%@", _oauth_base_method, _adMethodsJoin, queryString!=nil ? [NSString stringWithFormat:@"?%@", queryString] : @""]);
}
-(id)getQueryItems:(id)query{
    NSURLComponents *queryComponents = [[NSURLComponents alloc] init];
    NSMutableArray *queryItems = [[NSMutableArray alloc]init];
    NSArray *allKeys = [query allKeys];
//    NSData *imgData;
    NSString *encodedData;
    if(query[@"data64"]){
//        imgData =[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:query[@"data64"][0][@"data"][@"items"][@"photoBig"] ? query[@"data64"][0][@"data"][@"items"][@"photoBig"] : query[@"data64"][0][@"data"][@"url"]]];
//        encodedData = [self encodeDataString:imgData];
        encodedData = query[@"data64"][0][@"data"][@"items"][@"photoBig"] ? [self encodeString:query[@"data64"][0][@"data"][@"items"][@"photoBig"] ] :[self encodeString:query[@"data64"][0][@"data"][@"url"] ];
//        encodedData = [[NSString alloc] initWithData:imgData encoding:NSASCIIStringEncoding ];
    }
//
    for(int i = 0; i<[[query allKeys] count]; i++){
    
      
        [queryItems addObject:[NSURLQueryItem queryItemWithName:[allKeys[i] isEqual:@"data64"] ? @"source" :allKeys[i]  value:[NSString stringWithFormat:@"%@",  [allKeys[i] isEqual:@"data64"] ? encodedData : [query valueForKey:allKeys[i]]]]];
    }
    queryComponents.queryItems = queryItems;
     NSLog(@"%@", [queryComponents query]);
    return queryComponents.queryItems;
}

-(id)sortSignComponents:(id)signComponents{
    
    
    NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc]init];
    
    for (NSString *keyValuePair in signComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents firstObject] ;
        NSString *value = [pairComponents lastObject] ;
        
        [queryStringDictionary setObject:value forKey:key];
    }
    
    NSArray *sortedKeys = [queryStringDictionary allKeys];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
    sortedKeys = [sortedKeys sortedArrayUsingDescriptors:@[sd]];
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    NSMutableArray *queryItems = [[NSMutableArray alloc] init];
    
    for(NSString *key in sortedKeys){
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key  value:queryStringDictionary[key]]];
    }
    components.queryItems = queryItems;
    return [components query];
}

-(id)createSignature:(id)method httpMethod:(id)httpMethod media:(id)mediaData query:(id)query{
    [self createTimestampAndNonce];
    NSString *preparedSignatureComponents;
    NSString *preparedSignature;
    NSString *encodedBuiltSignature;
    NSString *encodedSignComponents;
    _keyForHash = [NSString stringWithFormat:@"%@&%@", [_oauth_consumer_secret_key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], [_oauth_token_secret stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
//    NSLog(@"%@", mediaData);
//    if(mediaData){
//        preparedSignatureComponents = [NSString stringWithFormat:@"%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_version=%@", [NSString stringWithFormat:@"image=%@", mediaData], _oauth_consumer_key, _oauth_nonce, _oauth_signature_method, _oauth_timestamp, _oauth_token, _oauth_version];
//    }
//    else if(httpMethod==nil && mediaData==nil && query==nil){
//        preparedSignatureComponents = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_version=%@", _oauth_consumer_key, _oauth_nonce, _oauth_signature_method, _oauth_timestamp, _oauth_token, _oauth_version];
//    }
//    else {
//    NSLog(@"query %@", query);
        preparedSignatureComponents = [NSString stringWithFormat:@"%@oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_version=%@", query!=nil ? [NSString stringWithFormat:@"%@&",query] : @"" , _oauth_consumer_key, _oauth_nonce, _oauth_signature_method, _oauth_timestamp, _oauth_token, _oauth_version];
//    }
    
    
//// [[[[[[ ,   .   ! *  +]]]] ______ NOT SUPPORTING_____ WHY????
    
    NSString *sortedSignComponents = [self sortSignComponents:[preparedSignatureComponents componentsSeparatedByString:@"&"]];
    
//    encodedSignComponents = [[[[[[[[[[[[sortedSignComponents stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"*" withString:@"%2A"]stringByReplacingOccurrencesOfString:@"\\" withString:@"%5C"]stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"]stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"] stringByReplacingOccurrencesOfString:@"!" withString:@"%21"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]stringByReplacingOccurrencesOfString:@"'" withString:@"%27"]stringByReplacingOccurrencesOfString:@"(" withString:@"%28"]stringByReplacingOccurrencesOfString:@")" withString:@"%29"];
    encodedSignComponents = sortedSignComponents;
//    encodedSignComponents = [sortedSignComponents rm_URLEncodedString];
//    encodedSignComponents = [sortedSignComponents stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet characterSetWithCharactersInString:@" \"#%/:<>?@[\\]^`{|}"] invertedSet]];
    NSLog(@"%@", encodedSignComponents);
    if(httpMethod==nil && mediaData==nil && query==nil){
        preparedSignature = [NSString stringWithFormat:@"%@&%@&%@", @"POST", method, encodedSignComponents];
        //        preparedSignature =  encodedSignComponents;
    }
    else{
        preparedSignature = [NSString stringWithFormat:@"%@&%@&%@", httpMethod, method, encodedSignComponents];
    }
    encodedBuiltSignature = [self hash:preparedSignature secret:_keyForHash];

//    NSData *mac1 = [NAHMAC HMACForKey:[_keyForHash dataUsingEncoding:NSUTF8StringEncoding] data:[preparedSignature dataUsingEncoding:NSUTF8StringEncoding]  algorithm:NAHMACAlgorithmSHA2_512];
//    encodedBuiltSignature = [mac1 base64EncodedStringWithOptions:0];
//    encodedBuiltSignature = [preparedSignature MD5HMACWithKey:_keyForHash encoding:NSASCIIStringEncoding];
//    NSLog(@"%@", encodedBuiltSignature);
    return encodedBuiltSignature;
}
-(id)createHeader{
    NSString *header = [NSString stringWithFormat:@"OAuth  oauth_consumer_key=\"%@\",oauth_nonce=\"%@\",oauth_signature=\"%@\",oauth_signature_method=\"%@\",oauth_timestamp=\"%@\",oauth_token=\"%@\",oauth_version=\"%@\"",  _oauth_consumer_key, _oauth_nonce, _oauth_signature,_oauth_signature_method, _oauth_timestamp, _oauth_token,  _oauth_version ] ;
//    NSLog(@"header %@", header);
    return header;
}
-(NSString*)createNonce{
    NSString *alphabetPlusDigits = @"0123456789";
    int length =  (int) [alphabetPlusDigits length];
    
    NSMutableString *nonceString = [[NSMutableString alloc]init];
    for(NSInteger i=0; i<17; i++){
        i++;
        [nonceString appendString:[NSString stringWithFormat:@"%C", [alphabetPlusDigits characterAtIndex:arc4random_uniform(length)]]];
        
    }
    return nonceString;
}
- (NSString *)hash:(NSString *)data secret:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *hmac = [[NSData alloc] initWithBytes:cHMAC
                                          length:sizeof(cHMAC)];
    
    NSMutableString* hash = [[NSMutableString alloc]init];
    const char* bytes = [hmac bytes];
    for (int i = 0; i < [hmac length]; i++) {
        [hash appendFormat:@"%02.2hhx", bytes[i]];
    }
    
    return [hmac base64EncodedStringWithOptions:0];
}
-(NSString *)encodeDataString:(NSData *)data{
    NSString *dataString =[[[[[[[[[[[[[[[data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"*" withString:@"%2A"]stringByReplacingOccurrencesOfString:@"\\" withString:@"%5C"]stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"]stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"] stringByReplacingOccurrencesOfString:@"!" withString:@"%21"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]stringByReplacingOccurrencesOfString:@"'" withString:@"%27"]stringByReplacingOccurrencesOfString:@"(" withString:@"%28"]stringByReplacingOccurrencesOfString:@")" withString:@"%29"]stringByReplacingOccurrencesOfString:@"~" withString:@"%7E"]stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    return dataString;
}
-(NSString *)encodeString:(NSString*)string{
    NSString *dataString =[[[[[[[[[[[[[[string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"*" withString:@"%2A"]stringByReplacingOccurrencesOfString:@"\\" withString:@"%5C"]stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"]stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"] stringByReplacingOccurrencesOfString:@"!" withString:@"%21"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]stringByReplacingOccurrencesOfString:@"'" withString:@"%27"]stringByReplacingOccurrencesOfString:@"(" withString:@"%28"]stringByReplacingOccurrencesOfString:@")" withString:@"%29"]stringByReplacingOccurrencesOfString:@"~" withString:@"%7E"]stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    return dataString;
}
@end
