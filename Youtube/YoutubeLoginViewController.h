//
//  YoutubeLoginViewController.h
//  MasterAPI
//
//  Created by sim on 28/06/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YoutubeRWData.h"
#import "YoutubeAuth.h"
@interface YoutubeLoginViewController : NSViewController{
    
    __weak IBOutlet NSTextField *clientId;
    __weak IBOutlet NSTextField *clientSecret;
    __weak IBOutlet NSProgressIndicator *progress;
    YoutubeRWData *RWData;
    __weak IBOutlet NSButton *removeAndAddButton;
    YoutubeAuth *youtubeAuth;
}

@end
