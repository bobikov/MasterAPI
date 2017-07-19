//
//  PrefsContentController.m
//  MasterAPI
//
//  Created by sim on 19/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "PrefsContentController.h"

@interface PrefsContentController ()

@end

@implementation PrefsContentController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    story = [NSStoryboard storyboardWithName:@"Third" bundle:nil];
    contrAppsPrefs = [story instantiateControllerWithIdentifier:@"appPrefs"];
    contrGeneral  = [story instantiateControllerWithIdentifier:@"GeneralPrefsController"];
    contrGeneral.preferredContentSize = contrGeneral.view.frame.size;
    contrAppsPrefs.preferredContentSize = contrAppsPrefs.view.frame.size;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(switchPrefsViews:) name:@"SwitchPrefsViews" object:nil];
//    [self.view.window setContentView:contrAppsPrefs.view];
    currentView = contrAppsPrefs.view;
    [self switchViews:@"Tokens"];
//    [self.view addSubview:currentView];
}

-(void)switchPrefsViews:(NSNotification *)obj{
    [self switchViews:obj.userInfo[@"name"] ];
}
-(void)switchViews:(id)name{
    oldView = currentView;
    [currentView removeFromSuperview];
    if([name isEqualToString:@"Tokens"]){
        currentView = contrAppsPrefs.view;
        currentViewRect = contrAppsPrefs.view.frame;
        currentViewRect.size.height+=80;
    }
    else if([name isEqualToString:@"General"]){
        currentView = contrGeneral.view;
        currentViewRect = contrGeneral.view.frame;
        currentViewRect.size.height+=80;
    }

    mainWindow = self.view.window.windowController.window ;
    windowRect = mainWindow.frame;
    NSLog(@"%f", windowRect.size.height);
    NSLog(@"%f", currentViewRect.size.height);
    NSLog(@"%f", windowRect.origin.y);
    float deltaHeights = windowRect.size.height - currentViewRect.size.height;
   

    windowRect.origin.y = windowRect.origin.y + deltaHeights;
    windowRect.size.height = currentViewRect.size.height;
    windowRect.size.width = currentViewRect.size.width;
    

    
    [mainWindow setFrame:windowRect display:YES animate:YES];
    [self.view addSubview:currentView];
    NSLog(@"%@", name);
    NSLog(@"%@", mainWindow);
    NSLog(@"%@", currentView);
    NSLog(@"%f %f", windowRect.size.height, windowRect.size.width);
}

@end
