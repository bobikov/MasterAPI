//
//  AppsPreferencesMainContainerController.h
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppsPreferencesMainContainerController : NSViewController{
    NSViewController *currentController;
    NSViewController *vkController;
    NSViewController *youtubeController;
    NSViewController *twitterController;
    NSViewController *tumblrController;
    NSViewController *instaController;
}
//@property(nonatomic)NSViewController *vkController;

@end
