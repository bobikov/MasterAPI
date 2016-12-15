//
//  YoutubeVideoPlayerController.h
//  MasterAPI
//
//  Created by sim on 14.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
@interface YoutubeVideoPlayerController : NSViewController
@property (weak) IBOutlet WebView *webView;
@property(nonatomic,readwrite) NSDictionary *receivedData;
@end
