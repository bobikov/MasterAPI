//
//  TwitterPrefsInfo.h
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TwitterRWData.h"
#import "TwitterAuth.h"
@interface TwitterPrefsInfo : NSViewController{
    
    __weak IBOutlet NSTextField *consumerKey;
    __weak IBOutlet NSTextField *consumerSecret;
    __weak IBOutlet NSTextField *secretToken;
    __weak IBOutlet NSTextField *token;
    TwitterRWData *twitterRWD;
    TwitterAuth *twitterAuth;
}

@end
