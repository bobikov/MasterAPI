
//
//  CustomSlider.h
//  vkapp
//
//  Created by sim on 06.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomSlider : NSSliderCell
@property float x;
@property NSImage *knobImage;
@property BOOL changing;

@end
