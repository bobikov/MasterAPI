//
//  InstagramClient.h
//  MasterAPI
//
//  Created by sim on 04.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstagramRWD.h"
@interface InstagramClient : NSObject{
    InstagramRWD *instaRWD;
    NSString *fullRequestURL;
}
@property(nonatomic,readwrite)NSString *client_id;
@property(nonatomic,readwrite)NSString *client_secret;
@property(nonatomic,readwrite)NSString *token;
@property(nonatomic,readwrite)NSString *base_request_url;
@property(nonatomic,readwrite)NSString *scope;
@property(nonatomic,readwrite)NSURLSession *session;
typedef void(^OnComplete)(NSData *data);
-(id)initWithTokensFromCoreData;
-(void)APIRequest:(NSString *)params completion:(OnComplete)completion;
@end
