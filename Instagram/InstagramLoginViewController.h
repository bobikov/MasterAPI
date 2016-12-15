//
//  InstagramLoginViewController.h
//  MasterAPI
//
//  Created by sim on 04.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "InstagramAuth.h"
#import "InstagramRWD.h"
@interface InstagramLoginViewController : NSViewController{
       InstagramAuth *instaAuth;
    __weak IBOutlet NSTextField *clientId;
    __weak IBOutlet NSTextField *clientSecret;
    
    InstagramRWD *instaRWD;
}
@property (weak) IBOutlet WebView *webView;

@end
