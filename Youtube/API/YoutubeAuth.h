//
//  YoutubeAuth.h
//  MasterAPI
//
//  Created by sim on 12.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YoutubeClient.h"
@interface YoutubeAuth : NSObject
@property(nonatomic,readwrite)YoutubeClient *client;
-(id)initWithParams:(NSString*)client_id   client_secret:(NSString*)client_secret;
-(void)requestTempToken;
-(void)requestAccessToken:(id)oauth_code;
@end
