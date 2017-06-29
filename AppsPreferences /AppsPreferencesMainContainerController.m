//
//  AppsPreferencesMainContainerController.m
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "AppsPreferencesMainContainerController.h"
#import <QuartzCore/QuartzCore.h>
@interface AppsPreferencesMainContainerController ()

@end

@implementation AppsPreferencesMainContainerController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Third" bundle:nil];
    NSStoryboard *story2 = [NSStoryboard storyboardWithName:@"Second" bundle:nil];
    vkController = [story instantiateControllerWithIdentifier:@"vkPrefs"];
    youtubeController = [story instantiateControllerWithIdentifier:@"youtubePrefs"];
    twitterController = [story instantiateControllerWithIdentifier:@"twitterPrefs"];
    tumblrController = [story instantiateControllerWithIdentifier:@"tumblrPrefs"];
    instaController = [story instantiateControllerWithIdentifier:@"instaPrefs"];
    
    vkSetupController = [story2 instantiateControllerWithIdentifier:@"VKLoginViewController"];
    youtubeSetupController  = [story2 instantiateControllerWithIdentifier:@"YoutubeLoginViewController"];
    twitterSetupController  = [story2 instantiateControllerWithIdentifier:@"TwitterLoginView"];
    tumblrSetupController = [story2 instantiateControllerWithIdentifier:@"TumblrLoginViewController"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeAppsSelector:) name:@"AppsPrefsSelect" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeSetupAppsSelector:) name:@"AppsSetupPrefsSelect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeBackToInfo:) name:@"backToInfo" object:nil];
}
-(void)observeBackToInfo:(NSNotification*)obj{
    if([obj.userInfo[@"name"] isEqual:@"vkontakte"]){
        [self switchControllers:vkController];
    }
    else if([obj.userInfo[@"name"] isEqual:@"youtube"]){
        [self switchControllers:youtubeController];
    }
    else if([obj.userInfo[@"name"] isEqual:@"twitter"]){
        [self switchControllers:twitterController];
    }
    else if([obj.userInfo[@"name"] isEqual:@"tumblr"]){
        [self switchControllers:tumblrController];
    }
}
-(void)observeAppsSelector:(NSNotification*)notification{
//    NSLog(@"%@", notification.userInfo[@"item"]);
    if ([notification.userInfo[@"item"]  isEqual: @"Vkontakte"]){
//        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :photoCopyView ];
        [self switchControllers:vkController];
    }
    else if([notification.userInfo[@"item"]  isEqual: @"Youtube"]){
        //        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :photoCopyView ];
        [self switchControllers:youtubeController];
    }
    else if([notification.userInfo[@"item"]  isEqual: @"Twitter"]){
        //        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :photoCopyView ];
        [self switchControllers:twitterController];
    }
    else if([notification.userInfo[@"item"]  isEqual: @"Tumblr"]){
        //        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :photoCopyView ];
        [self switchControllers:tumblrController];
    }
    else if([notification.userInfo[@"item"]  isEqual: @"Instagram"]){
        //        [self setCurrentSelectedMain:notification.userInfo[@"currentSelectorName"] :photoCopyView ];
        [self switchControllers:instaController];
    }
}
-(void)observeSetupAppsSelector:(NSNotification*)notification{
    
    if([notification.userInfo[@"name"] isEqual:@"vkontakte"]){
        [self switchControllers:vkSetupController];
    }
    else if([notification.userInfo[@"name"] isEqual:@"youtube"]){
        [self switchControllers:youtubeSetupController];
    }
    else if([notification.userInfo[@"name"] isEqual:@"twitter"]){
        [self switchControllers:twitterSetupController];
    }
    else if([notification.userInfo[@"name"] isEqual:@"tumblr"]){
        [self switchControllers:tumblrSetupController];
    }
}
-(void)switchControllers:(NSViewController*)controller{
//    NSLog(@"Switch");
    //    [self removeChildViewControllerAtIndex:0];
    //    [coolCon removeFromParentViewController];
    //    [coolCon.view removeFromSuperview];
    if ([self.childViewControllers count]>0){
        
        [self removeChildViewControllerAtIndex:0];
        [currentController removeFromParentViewController];
        [currentController.view removeFromSuperview];
        
    }
    else{
        
        
    }
    currentController = controller;
    [self displayContentController:controller];
}
- (void) displayContentController:(NSViewController *)content {
    
    [self addChildViewController:content];
    content.view.frame = self.view.bounds;
//    NSView *view = content.view;
//    content.view.translatesAutoresizingMaskIntoConstraints = NO;
    //        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[view]-|" options:NSLayoutFormatAlignAllBaseline metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    
    
   
    CATransition *transition = [CATransition animation];
    transition.duration = 0.15;
    transition.removedOnCompletion=YES;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    content.view.wantsLayer=YES;
    [content.view.layer addAnimation:transition forKey:nil];
//    content.view.layer add
//    [NSView transitionWithView:self.view duration:0.5
//                           options:NSViewAnimationFadeInEffect //change to whatever animation you like
//                        animations:^ { [self.view addSubview:content.view]; }
//                        completion:nil];
    [self.view addSubview:content.view];
    
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[view]-0-|" options:NSLayoutFormatAlignAllTrailing metrics:nil views:NSDictionaryOfVariableBindings(view)]];
//    //    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-[view(==%f)]-|",content.view.frame.size.height] options:NSLayoutFormatAlignAllTrailing metrics:nil views:NSDictionaryOfVariableBindings(view)]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:NSLayoutFormatAlignAllTrailing metrics:nil views:NSDictionaryOfVariableBindings(view)]];
    //
    
}

@end
