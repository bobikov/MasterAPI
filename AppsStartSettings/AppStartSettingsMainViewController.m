//
//  AppStartSettingsMainViewController.m
//  MasterAPI
//
//  Created by sim on 13.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "AppStartSettingsMainViewController.h"

@interface AppStartSettingsMainViewController ()

@end

@implementation AppStartSettingsMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _VKKeyHandler = [[keyHandler alloc]init];
    _twitterRWD = [[TwitterRWData alloc]init];
    _youtubeRWD = [[YoutubeRWData alloc]init];
    _tumblrRWD = [[TumblrRWData alloc]init];
    instaRWD = [[InstagramRWD alloc]init];
    if (![_VKKeyHandler VKTokensEcxistsInCoreData]){
        VKStatusLabel.stringValue = @"OFF";
    }else{
        VKStatusLabel.stringValue = @"ON";
    }
   if(![_twitterRWD TwitterTokensEcxistsInCoreData]){
       TwitterStatusLabel.stringValue=@"OFF";
   }else{
       TwitterStatusLabel.stringValue=@"ON";
   }
    if(![_youtubeRWD YoutubeTokensEcxistsInCoreData]){
        YoutubeStatusLabel.stringValue=@"OFF";
    }else{
        YoutubeStatusLabel.stringValue=@"ON";
    }
    if(![_tumblrRWD TumblrTokensEcxistsInCoreData]){
        TumblrStatusLabel.stringValue=@"OFF";
    }else{
        TumblrStatusLabel.stringValue=@"ON";
    }
    if(![instaRWD InstagramTokensEcxistsInCoreData]){
        InstagramStatusLabel.stringValue=@"OFF";
    }else{
        InstagramStatusLabel.stringValue=@"ON";
    }
}

@end
