//
//  TumblrPrefsInfo.h
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TumblrRWData.h"
#import "TumblrAuth.h"
@interface TumblrPrefsInfo : NSViewController{
    __weak IBOutlet NSTextField *consumerKey;
    __weak IBOutlet NSTextField *consumerSecret;
    __weak IBOutlet NSTextField *secretToken;
    __weak IBOutlet NSTextField *token;
    TumblrAuth *tumblrAuth;
}
@property(nonatomic)TumblrRWData *tumblrRWD;
@end
