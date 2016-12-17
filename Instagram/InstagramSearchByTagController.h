//
//  InstagramSearchByTagController.h
//  MasterAPI
//
//  Created by sim on 16.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface InstagramSearchByTagController : NSViewController{
    
    __weak IBOutlet NSScrollView *postsListScroll;
    __weak IBOutlet NSClipView *postsListClip;
}

@end
