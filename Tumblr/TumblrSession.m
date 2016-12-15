//
//  TumblrSession.m
//  MyTumblrLibrary
//
//  Created by sim on 06.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TumblrSession.h"

@implementation TumblrSession
-(id)init{
    self = [super self];
    _session = [NSURLSession  sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    return self;
}
@end
