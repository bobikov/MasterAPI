//
//  FriendsTabbarViewController.m
//  vkapp
//
//  Created by sim on 11.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "FriendsTabbarViewController.h"

@interface FriendsTabbarViewController ()

@end

@implementation FriendsTabbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    

}
- (IBAction)tabBarAction:(id)sender {
//    NSLog(@"%@", tabBar.title);
     NSLog(@"%lu", [[tabBarsWrap subviews]count]);
}

@end
