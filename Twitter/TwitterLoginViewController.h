//
//  TwitterLoginViewController.h
//  MasterAPI
//
//  Created by sim on 05.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "TwitterAuth.h"
#import "TwitterClient.h"
#import "TwitterRWData.h"
#import "TwitterAuth.h"
@interface TwitterLoginViewController : NSViewController{
    
    __weak IBOutlet NSTextField *consumerKey;
    __weak IBOutlet NSTextField *consumerSecret;

    __weak IBOutlet NSButton *resetTokenButton;
    __weak IBOutlet NSButton *removeAndAddButton;
    __weak IBOutlet NSProgressIndicator *progress;
    TwitterAuth *twitAuth;
    TwitterClient *twitClient;
    NSString *tempToken;
    NSString *tempTokenSecret;
    TwitterRWData *RWData;
    TwitterAuth *twitterAuth;
}
@property (weak) IBOutlet WebView *webView;

@end
