//
//  TwitterClient.m
//  MasterAPI
//
//  Created by sim on 11.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TwitterClient.h"

@implementation TwitterClient
@synthesize  request, adMethodsJoin;
-(id)init{
    self = [super self];
    _TSession = [NSURLSession  sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    _oauth_request_token_url = @"https://api.twitter.com/oauth/request_token";
    _oauth_authorize_url = @"https://api.twitter.com/oauth/authorize";
    _oauth_access_token_url = @"https://api.twitter.com/oauth/access_token";
    _oauth_callback = @"https://twitter.com/auth";
    _oauth_version = @"1.0";
    _timeInSeconds = [[NSDate date] timeIntervalSince1970];
    _oauth_timestamp = [NSString stringWithFormat:@"%.f", _timeInSeconds];
    _oauth_signature_method = @"HMAC-SHA1";
    _oauth_base_method = @"https://api.twitter.com/1.1/";
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
    _TwitterRWD= [[TwitterRWData alloc]init];
    NSDictionary *tokens = [_TwitterRWD readTwitterTokens];
    
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
-(void)APIRequest:(NSString*)amethod rmethod:(NSString*)bmethod query:(NSDictionary*)rparams handler:(OnComplete)completion{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
       __block NSURLComponents *queryComponents = [[NSURLComponents alloc] init];
       __block NSString *queryString;
       __block NSString *HttpMethod;
        
        __block NSString *method;
        __block NSString *requestHeader;
        queryComponents.queryItems = [self getQueryItems:rparams];
        queryString = [queryComponents query];
        adMethodsJoin = [NSString stringWithFormat:@"%@/%@", amethod, bmethod];
        method = [[NSString stringWithFormat:@"%@%@", _oauth_base_method, adMethodsJoin] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        
        if([amethod isEqualToString:@"account"] && [bmethod isEqualToString:@"update_profile_image.json"]){
            HttpMethod = @"POST";
            
            NSString *filePath = [rparams[@"image"] absoluteString];
            filePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            NSLog(@"%@", filePath);
            NSData *imgData = [[NSData alloc] initWithContentsOfFile:rparams[@"image"]];
            NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imgData];
            NSData *data1 = [imageRep representationUsingType:NSJPEGFileType properties:nil];
            _oauth_signature = [self createSignature:method httpMethod:HttpMethod  media:[self encodeDataString:data1] query:nil];
            requestHeader = [self createHeader];
            [request setHTTPMethod:HttpMethod];
            [request setValue:requestHeader forHTTPHeaderField:@"Authorization"];
            [request setHTTPBody:[[NSString stringWithFormat:@"image=%@", [self encodeDataString:data1]] dataUsingEncoding:NSASCIIStringEncoding]];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/account/update_profile_image.json"]]];
            
            //            [[_TSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //                completion(data);
            //
            //            }]resume];
            NSURLSessionConfiguration *backgroundConfigurationObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"myBackgroundSessionIdentifierTwitter"];
            _backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfigurationObject delegate:self delegateQueue:[NSOperationQueue mainQueue]];
            NSURLSessionDataTask *uploadTask;
            uploadTask = [_backgroundSession dataTaskWithRequest:request];
            [uploadTask resume];
            
        }
  
        else if([amethod isEqualToString:@"statuses"] && [bmethod isEqual:@"update.json"]){
            
            HttpMethod = @"POST";
            
            if(rparams[@"image"]){
                HttpMethod = @"POST";
                method = [@"https://upload.twitter.com/1.1/media/upload.json" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
                _oauth_signature = [self createSignature:method httpMethod:nil  media:nil query:nil];
                requestHeader = [self createHeader];
                NSLog(@"FILE TO POST IN TWITTER %@", rparams[@"image"][0][@"data"][@"items"][@"photoBig"] ? rparams[@"image"][0][@"data"][@"items"][@"photoBig"] :  rparams[@"image"][0][@"data"][@"url"] );
                NSString *filename = rparams[@"image"][0][@"data"][@"items"][@"photoBig"] ? [rparams[@"image"][0][@"data"][@"items"][@"photoBig"] lastPathComponent] : rparams[@"image"][0][@"data"][@"title"];
//                NSLog(@"%@", filename);
                NSData *imgData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:rparams[@"image"][0][@"data"][@"items"][@"photoBig"] ? rparams[@"image"][0][@"data"][@"items"][@"photoBig"] : rparams[@"image"][0][@"data"][@"url"]]];
//                NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imgData];
//                NSData *data1 = [imageRep representationUsingType: !rparams[@"image"][0][@"data"][@"items"][@"photoBig"] ? NSGIFFileType :NSJPEGFileType properties:nil];
                NSString *fileType =  !rparams[@"image"][0][@"data"][@"items"][@"photoBig"] ? @"image/gif" : @"image/jpeg";
                [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
                [request setHTTPShouldHandleCookies:NO];
                [request setTimeoutInterval:30];
                [request setValue:requestHeader forHTTPHeaderField:@"Authorization"];
                [request setValue:@"upload.twitter.com" forHTTPHeaderField:@"Host"];
                NSMutableData *body = [NSMutableData data];
                NSString *boundary = @"******";
                [request setHTTPMethod:HttpMethod];
                [request setValue:[NSString stringWithFormat:@"multipart/form-data;  boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
                [request setURL:[NSURL URLWithString:@"https://upload.twitter.com/1.1/media/upload.json"]];

                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"media\"; type=%@; filename=\"%@\"\r\n\r\n",filename, fileType]
                                  dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:imgData];
                [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [request setHTTPBody:body];
                [[_TSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//                    completion(data);
                    NSDictionary *uploadMediaResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSLog(@"%@", uploadMediaResponse);
                    if(uploadMediaResponse[@"image"]){
                         method = [[NSString stringWithFormat:@"%@%@", _oauth_base_method, adMethodsJoin] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
                        queryComponents.queryItems = [self getQueryItems:@{@"status":rparams[@"status"], @"media_ids":uploadMediaResponse[@"media_id"]}];
                        queryString = [queryComponents query];
                        _oauth_signature = [self createSignature:method httpMethod:HttpMethod  media:nil query:queryString];
                        [self setStandardHeaders:HttpMethod :queryString];
                        [[_TSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                            completion(data);
                            
                        }]resume];
                    }
                    
                }]resume];
  
            }else{
                _oauth_signature = [self createSignature:method httpMethod:HttpMethod  media:nil query:queryString];
                [self setStandardHeaders:HttpMethod :queryString];
                [self startRequest:^(NSData *data) {
                    completion(data);
                    
                }];
            }
            
            
        }
        else if([amethod isEqualToString:@"friendships"] && [bmethod isEqualToString:@"create.json"]){
            HttpMethod = @"POST";
            _oauth_signature = [self createSignature:method httpMethod:HttpMethod  media:nil query:queryString];
            [self setHeadersWithBody:queryString];
//            [ self setStandardHeaders:HttpMethod :queryString];
            [self startRequest:^(NSData *data) {
                completion(data);
                
            }];
        }
        else{
            HttpMethod = @"GET";
            _oauth_signature = [self createSignature:method httpMethod:HttpMethod  media:nil query:queryString];
            [self setStandardHeaders:HttpMethod :queryString];
         
            [self startRequest:^(NSData *data) {
                completion(data);
                
            }];
        }
      
     
        
    });
}
-(void)startRequest:(OnComplete)completion{
    [[_TSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            completion(data);
        
    }]resume];
}
-(void)setHeadersWithBody:(id)queryString{
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request valueForHTTPHeaderField:[NSString stringWithFormat:@"%@ /1.1/%@?%@", @"POST", adMethodsJoin,queryString]];
    [request setValue:[self createHeader] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"api.twitter.com" forHTTPHeaderField:@"Host"];
     [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
      [request setValue:@"https://api.twitter.com" forHTTPHeaderField:@"X-Target-URI"];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", _oauth_base_method, adMethodsJoin ]]];
    [request setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
    
}
-(void)setStandardHeaders:(id)httpMethod :(id)queryString{
    
    [request setHTTPMethod:httpMethod];
    [request valueForHTTPHeaderField:[NSString stringWithFormat:@"%@ /1.1/%@?%@", httpMethod, adMethodsJoin, queryString]];
    [request setValue:[self createHeader] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"https://api.twitter.com" forHTTPHeaderField:@"X-Target-URI"];
    [request setValue:@"api.twitter.com" forHTTPHeaderField:@"Host"];
    [request setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", _oauth_base_method, adMethodsJoin, [[queryString componentsSeparatedByString:@"&"] count] > 0 ? [NSString stringWithFormat:@"?%@", queryString] : @""]] ];
    NSLog(@"%@", [NSString stringWithFormat:@"%@%@%@", _oauth_base_method, adMethodsJoin,[[queryString componentsSeparatedByString:@"&"] count] > 0 ? [NSString stringWithFormat:@"?%@", queryString] : @""]);
}
-(id)getQueryItems:(id)query{
    NSURLComponents *queryComponents = [[NSURLComponents alloc] init];
    NSMutableArray *queryItems = [[NSMutableArray alloc]init];
    for(int i = 0; i<[[query allKeys] count]; i++){
        //                [queryItems addObject:[NSString stringWithFormat:@"&%@=%@", [rparams allKeys][i], [rparams valueForKey:[rparams allKeys][i]]]];
        //            if(![[rparams allKeys][i] isEqual:@"limit"]){
        [queryItems addObject:[NSURLQueryItem queryItemWithName:[query allKeys][i] value: [NSString stringWithFormat:@"%@",[query valueForKey:[query allKeys][i]]]]];
        //            }
        //
    }
    queryComponents.queryItems = queryItems;
    
    return queryComponents.queryItems;
}

-(NSString *)encodeDataString:(NSData *)data{
    NSString *dataString =[[[[[[[[[[[[[[[data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"*" withString:@"%2A"]stringByReplacingOccurrencesOfString:@"\\" withString:@"%5C"]stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"]stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"] stringByReplacingOccurrencesOfString:@"!" withString:@"%21"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]stringByReplacingOccurrencesOfString:@"'" withString:@"%27"]stringByReplacingOccurrencesOfString:@"(" withString:@"%28"]stringByReplacingOccurrencesOfString:@")" withString:@"%29"]stringByReplacingOccurrencesOfString:@"~" withString:@"%7E"]stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    return dataString;
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
    _oauth_timestamp = [NSString stringWithFormat:@"%.f", _timeInSeconds];
    _oauth_nonce = [self createNonce];
    NSString *preparedSignatureComponents;
    NSString *preparedSignature;
    NSString *encodedBuiltSignature;
    NSString *encodedSignComponents;
    _keyForHash = [NSString stringWithFormat:@"%@&%@", [_oauth_consumer_secret_key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]], [_oauth_token_secret stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    NSLog(@"%@", mediaData);
    if(mediaData){
        preparedSignatureComponents = [NSString stringWithFormat:@"%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_version=%@", [NSString stringWithFormat:@"image=%@", mediaData], _oauth_consumer_key, _oauth_nonce, _oauth_signature_method, _oauth_timestamp, _oauth_token, _oauth_version];
    }
    else if(httpMethod==nil && mediaData==nil && query==nil){
         preparedSignatureComponents = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_version=%@", _oauth_consumer_key, _oauth_nonce, _oauth_signature_method, _oauth_timestamp, _oauth_token, _oauth_version];
    }
    else {
        preparedSignatureComponents = [NSString stringWithFormat:@"%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_token=%@&oauth_version=%@", query , _oauth_consumer_key, _oauth_nonce, _oauth_signature_method, _oauth_timestamp, _oauth_token, _oauth_version];
    }
    
    NSString *sortedSignComponents = [self sortSignComponents:[preparedSignatureComponents componentsSeparatedByString:@"&"]];
    
    encodedSignComponents = [[[[[[[[[[[[sortedSignComponents stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]] stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"] stringByReplacingOccurrencesOfString:@"&" withString:@"%26"] stringByReplacingOccurrencesOfString:@"*" withString:@"%2A"]stringByReplacingOccurrencesOfString:@"\\" withString:@"%5C"]stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"]stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"] stringByReplacingOccurrencesOfString:@"!" withString:@"%21"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]stringByReplacingOccurrencesOfString:@"'" withString:@"%27"]stringByReplacingOccurrencesOfString:@"(" withString:@"%28"]stringByReplacingOccurrencesOfString:@")" withString:@"%29"];
    
    if(httpMethod==nil && mediaData==nil && query==nil){
        preparedSignature = [NSString stringWithFormat:@"%@&%@&%@", @"POST", method, encodedSignComponents];
//        preparedSignature =  encodedSignComponents;
    }
    else{
        preparedSignature = [NSString stringWithFormat:@"%@&%@&%@", httpMethod, method, encodedSignComponents];
    }
     NSLog(@"%@", preparedSignature);
    encodedBuiltSignature =  [[[[[[[[[self hash:preparedSignature secret:_keyForHash] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]stringByReplacingOccurrencesOfString:@"*" withString:@"%2A"] stringByReplacingOccurrencesOfString:@"\\" withString:@"%5C"]stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"] stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
   
    return encodedBuiltSignature;
}
-(id)createHeader{
    NSString *header = [NSString stringWithFormat:@"OAuth  oauth_consumer_key=\"%@\",oauth_nonce=\"%@\",oauth_signature=\"%@\",oauth_signature_method=\"%@\",oauth_timestamp=\"%@\",oauth_token=\"%@\",oauth_version=\"%@\"",  _oauth_consumer_key, _oauth_nonce, _oauth_signature,_oauth_signature_method, _oauth_timestamp, _oauth_token,  _oauth_version ] ;
    
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
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    
}
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
   didReceiveData:(NSData *)data {
    
    NSDictionary *uplData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSLog(@" UPLOAD DATA %@", uplData);
    
    
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setMaxValue" object:nil userInfo:@{@"max":[NSNumber numberWithInteger:totalBytesExpectedToSend]}];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setValue" object:nil userInfo:@{@"value":[NSNumber numberWithInteger:totalBytesSent]}];
}
@end
