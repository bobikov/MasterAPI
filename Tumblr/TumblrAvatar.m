//
//  TumblrAvatar.m
//  MasterAPI
//
//  Created by sim on 08.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TumblrAvatar.h"

@interface TumblrAvatar ()

@end

@implementation TumblrAvatar

- (void)viewDidLoad {
    [super viewDidLoad];

}
-(void)viewDidAppear{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSImage *image = [[NSImage alloc]initWithContentsOfURL:[NSURL URLWithString:@"https://api.tumblr.com/v2/blog/hfdui2134.tumblr.com/avatar/512"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [tumblrAvatar setImage:image];
        });
    });
    
}


@end
