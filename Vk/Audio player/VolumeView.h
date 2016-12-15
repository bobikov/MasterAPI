//
//  VolumeView.h
//  vkapp
//
//  Created by sim on 13.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VolumeView : NSViewController{
    
    __weak IBOutlet NSSlider *volume;
    double volumeLevel;
}
@property(nonatomic, readwrite)NSDictionary *recivedDataForVolume;
@end
