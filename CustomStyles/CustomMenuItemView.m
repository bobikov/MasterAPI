//
//  CustomMenuItemView.m
//  MasterAPI
//
//  Created by Константин on 09.12.2019.
//  Copyright © 2019 sim. All rights reserved.
//

#define menuItem ([self enclosingMenuItem])
//#define backgroundColor ([NSColor clearColor])
//define trackingArea ([[NSTrackingArea alloc] initWithRect:self.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingCursorUpdate) owner:self userInfo:nil])
#import "CustomMenuItemView.h"

@implementation CustomMenuItemView
-(void)awakeFromNib{
    backgroundColor = [NSColor clearColor];
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    if ([[self enclosingMenuItem] isHighlighted]) {
        [backgroundColor set];
    } else {
        [backgroundColor set];
    }
    NSRectFill(dirtyRect);
}

-(void)mouseEntered:(NSEvent *)event{
    backgroundColor = [NSColor selectedMenuItemColor];
    self.needsDisplay=YES;
    NSLog(@"Mouse entered");
}
- (void)mouseExited:(NSEvent *)event{
    backgroundColor = [NSColor clearColor];
    self.needsDisplay=YES;
}

- (void)mouseUp:(NSEvent*) event
{
    NSMenu *menu = self.enclosingMenuItem.menu;
    [menu cancelTracking];
    
    [menu performActionForItemAtIndex:[menu indexOfItem:self.enclosingMenuItem]];
}
- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

-(BOOL)allowsVibrancy{
    return YES;
}
-(void)updateTrackingAreas{
    for (NSTrackingArea *i in [self trackingAreas]){
        [self removeTrackingArea:i];
        NSLog(@"%@", i);
    };
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc]initWithRect:self.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingCursorUpdate) owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];


}
//- (void)viewDidMoveToWindow {
//    [[self window] becomeKeyWindow];
//}
//- (NSImage *)_cornerMask
//{
//    CGFloat radius = 40.0;
//    CGFloat dimension = 2 * radius + 1;
//    NSSize size = NSMakeSize(dimension, dimension);
//    NSImage *image = [NSImage imageWithSize:size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
//        NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:dstRect xRadius:radius yRadius:radius];
//        [[NSColor blackColor] set];
//        [bezierPath fill];
//        return YES;
//    }];
//    image.capInsets = NSEdgeInsetsMake(radius, radius, radius, radius);
//    image.resizingMode = NSImageResizingModeStretch;
//    return image;
//}
//
//- (NSImage *)cornerMask
//{
//    return [self _cornerMask];
//}

@end
