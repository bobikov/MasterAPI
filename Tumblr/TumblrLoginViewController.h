//
//  TumblrLoginViewController.h
//  MasterAPI
//
//  Created by sim on 29/06/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TumblrRWData.h"
#import "TumblrAuth.h"
@interface TumblrLoginViewController : NSViewController{
    
    __weak IBOutlet NSTextField *consumerKey;
    __weak IBOutlet NSTextField *consumerSecret;
    __weak IBOutlet NSButton *removeAndAddButton;
    __weak IBOutlet NSButton *resetTokenButton;
    __weak IBOutlet NSProgressIndicator *progress;
    TumblrRWData *RWData;
    TumblrAuth *TAuth;
}

@end
