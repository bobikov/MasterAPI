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
@interface TwitterLoginViewController : NSViewController{
    
    __weak IBOutlet NSTextField *consumerKey;
    __weak IBOutlet NSTextField *consumerSecret;
    TwitterAuth *twitAuth;
    TwitterClient *twitClient;
    NSString *tempToken;
    NSString *tempTokenSecret;
}
@property (weak) IBOutlet WebView *webView;

@end
