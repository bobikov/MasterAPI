//
//  ShowDocViewController.h
//  vkapp
//
//  Created by sim on 09.08.16.
//  Copyright © 2016 sim. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
@interface ShowDocViewController : NSViewController{
    
 
}
@property (weak) IBOutlet AVPlayerView *mainPlayer;
@property (nonatomic, readwrite) NSDictionary *receivedData;
@end
