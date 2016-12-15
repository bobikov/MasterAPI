//
//  VolumeView.m
//  vkapp
//
//  Created by sim on 13.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "VolumeView.h"

@interface VolumeView ()

@end

@implementation VolumeView

- (void)viewDidLoad {
    [super viewDidLoad];
    volume.doubleValue = [_recivedDataForVolume[@"c_volume"] doubleValue];

}
- (IBAction)volumeAction:(id)sender {
    volumeLevel = volume.doubleValue;
    NSDictionary *volumeData = @{@"volume":@(volumeLevel)};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"audioVolume" object:nil userInfo:volumeData];
}

@end
