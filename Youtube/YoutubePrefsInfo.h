//
//  YoutubePrefsInfo.h
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YoutubeRWData.h"
#import "YoutubeAuth.h"
@interface YoutubePrefsInfo : NSViewController{
    __weak IBOutlet NSTextField *clientId;
    __weak IBOutlet NSTextField *clientSecret;
    __weak IBOutlet NSTextField *accessToken;
    __weak IBOutlet NSTextField *refreshToken;
    YoutubeAuth *youtubeAuth;
    YoutubeRWData *youtubeRWD;
}

@end
