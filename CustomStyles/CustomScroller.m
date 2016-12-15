//
//  CustomScroller.m
//  MasterAPI
//
//  Created by sim on 26.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomScroller.h"

@implementation CustomScroller

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [[NSColor clearColor] set];
//    [[NSColor whiteColor]set];
//    [[NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:0.0] set];
    NSRectFill(dirtyRect);
 
    // Call NSScroller's drawKnob method (or your own if you overrode it)
    [self drawKnob];
}

@end
