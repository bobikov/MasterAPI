//
//  LongPoll.m
//  vkapp
//
//  Created by sim on 28.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "LongPoll.h"

@implementation LongPoll


-(void)startLongPoll{
    NSLog(@"Long poll started");
    [self ssw];
}
-(void)ssw{
    [[_app.session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/messages.getLongPollServer?need_pts=1&use_ssl=1&v=%@&access_token=%@", _app.version, _app.token]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            NSLog(@"dataTaskWithUrl error: %@", error);
            return;
        }
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(jsonData[@"error"]){
            NSLog(@"%@", jsonData[@"error"][@"error_msg"]);
        }
        else{
            NSLog(@"%@", jsonData);
        }
        
        
    }] resume];
}
@end
