//
//  InstagramAuth.h
//  MasterAPI
//
//  Created by sim on 04.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstagramClient.h"
//#import "InstagramLoginViewController.h"
@interface InstagramAuth : NSObject{
  
   
 
     InstagramClient *instaClient;
   

  
    
//    InstagramLoginViewController *instaLoginContr;
   
}
-(id)init;
-(void)requestCode;
typedef void(^OnComplete)(NSData *data);
@property(nonatomic,readwrite) NSString *clientId;
@property(nonatomic,readwrite) NSString *clientSecret;
@property(nonatomic,readwrite) NSString *authorize_url;
@property(nonatomic,readwrite) NSString *scope;
@property(nonatomic,readwrite) NSString *redirect_uri;
@property(nonatomic,readwrite) NSString *responseType;
@property(nonatomic,readwrite) NSString *requestAccessTokenURL;
@property(nonatomic,readwrite) NSString *authorizeFullURL;

-(void)requestAccessToken:(NSString*)code completion:(OnComplete)completion;
-(id)initWithParams:(NSString *)client_id client_secret:(NSString*)client_secret;

@end
