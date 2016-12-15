//
//  CustomView.m
//  vkapp
//
//  Created by sim on 12.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomView.h"

@implementation CustomView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
   
    NSColor *bgColor = [NSColor grayColor];
    // Drawing background color of Tab bar view.
    [bgColor set];
    NSRect rect = [self frame];
    rect.origin = NSZeroPoint;
    NSRectFill(rect);
    
    
    // Draw tab list control
    NSBezierPath *tabListControlPath = [NSBezierPath bezierPath];
//    NSRect tabListRect = [self rectForTabListControl];
//    tabListRect = NSIntegralRect(tabListRect);
    int maxY = NSMaxY(dirtyRect);
    int minY = NSMinY(dirtyRect);
    int minX = NSMinX(dirtyRect);
    int maxX = NSMaxX(dirtyRect);
    int midX = NSMidX(dirtyRect);
    
    NSPoint p1 = NSMakePoint(midX, minY);
    NSPoint p2 = NSMakePoint(minX, maxY);
    NSPoint p3 = NSMakePoint(maxX, maxY);
    
    [tabListControlPath moveToPoint:p1];
    [tabListControlPath lineToPoint:p2];
    [tabListControlPath lineToPoint:p3];
    [tabListControlPath lineToPoint:p1];
    //[[self smallControlColor] set];
    // Use tab active back ground color to set tab list triangle
    [[NSColor grayColor]set];
    [tabListControlPath fill];
    
    // Drawing bottom border line
    NSPoint start = NSMakePoint(0, 1);
    NSPoint end = NSMakePoint(NSMaxX(rect), 1);
    [NSBezierPath setDefaultLineWidth:2.0];
    [[NSColor grayColor] set];
    [NSBezierPath strokeLineFromPoint:start toPoint:end];
}

@end
