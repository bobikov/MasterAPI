//
//  ViewController.h
//  vkapp
//
//  Created by sim on 19.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "keyHandler.h"
#import "TwitterRWData.h"
#import "YoutubeRWData.h"
#import "TumblrRWData.h"
#import "InstagramRWD.h"
@interface ViewController : NSViewController{
    
    __weak IBOutlet NSSegmentedControl *ApiSourceSelector;
}
@property(nonatomic)keyHandler *VKKeyHandler;
@property(nonatomic)TwitterRWData *twitterRWD;
@property(nonatomic)YoutubeRWData *youtubeRWD;
@property(nonatomic)TumblrRWData *tumblrRWD;
@property(nonatomic)InstagramRWD *instaRWD;
@end

