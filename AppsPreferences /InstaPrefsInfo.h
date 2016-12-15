//
//  InstaPrefsInfo.h
//  MasterAPI
//
//  Created by sim on 04.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InstagramRWD.h"
@interface InstaPrefsInfo : NSViewController{
    InstagramRWD *instaRWD;
    __weak IBOutlet NSTextField *clientId;
    __weak IBOutlet NSTextField *client_secret;
    __weak IBOutlet NSTextField *accessToken;
}

@end
