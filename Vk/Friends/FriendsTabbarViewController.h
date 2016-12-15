//
//  FriendsTabbarViewController.h
//  vkapp
//
//  Created by sim on 11.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FriendsTabbarViewController : NSViewController{
     __weak IBOutlet NSSegmentedControl *segment;
    __weak IBOutlet NSButton *tabBar;
    __weak IBOutlet NSBox *tabBarsWrap;

    __weak IBOutlet NSButton *superButton;
   
 
}

@end
