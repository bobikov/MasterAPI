//
//  appInfo.m
//  vkapp
//
//  Created by sim on 20.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "appInfo.h"

@implementation appInfo

-(id)init{
    
    self = [super self];
    _keyHandle = [[keyHandler alloc]init];
//    if([_keyHandle readAppInfo:nil]){
        NSDictionary *object = [[_keyHandle readAppInfo:nil]copy];
//        NSLog(@"%@", object);
        _person = object[@"id"];
        _appId = object[@"appId"];
        _token = object[@"token"];
        _version = object[@"version"];
//        _selected = [object[@"selected"] boolValue];
        _icon = object[@"icon"];
        _session=[NSURLSession  sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        return self;
//    }
 
    return nil;
}
@end
