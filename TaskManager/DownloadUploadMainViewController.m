//
//  DownloadUploadMainViewController.m
//  MasterAPI
//
//  Created by sim on 02.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "DownloadUploadMainViewController.h"

@interface DownloadUploadMainViewController ()

@end

@implementation DownloadUploadMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateProgressState:) name:@"UpdateProgressState" object:nil];
}
-(void)updateProgressState:(NSNotification*)notification{
    dispatch_async(dispatch_get_main_queue(),^{
        progressBar.maxValue=[notification.userInfo[@"maxData"] intValue];
        progressBar.doubleValue=[notification.userInfo[@"dataSent"] intValue];
    });
   
}
@end
