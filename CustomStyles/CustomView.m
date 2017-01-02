//
//  CustomView.m
//  vkapp
//
//  Created by sim on 12.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomView.h"

@implementation CustomView
-(void)awakeFromNib{
    bgColr = [NSColor colorWithWhite:0.82 alpha:1.0];
    borderColor = [NSColor colorWithWhite:0.6 alpha:1.0];
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSBezierPath *path = [NSBezierPath bezierPath];
    int minX = NSMinX(dirtyRect);
    int midX = NSMidX(dirtyRect);
    int maxX = NSMaxX(dirtyRect);
    int minY = NSMinY(dirtyRect);
    int midY = NSMidY(dirtyRect);
    int maxY = NSMaxY(dirtyRect);

    NSPoint leftBottomPoint = NSMakePoint(minX, minY);
    NSPoint leftMiddlePoint = NSMakePoint(minX + deltaXfromLeftAndRight, midY);
    NSPoint topMiddlePoint = NSMakePoint(midX, maxY);
    NSPoint rightMiddlePoint = NSMakePoint(maxX - deltaXfromLeftAndRight, midY);
    NSPoint rightBottomPoint = NSMakePoint(maxX, minY);

     [path moveToPoint:leftBottomPoint];

    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX + deltaXfromLeftAndRight, minY) toPoint:leftMiddlePoint radius:0.0];
    
    // left middle to top middle
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX-0 + deltaXfromLeftAndRight, maxY) toPoint:topMiddlePoint radius:2.0];
    
    // top middle to right middle
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX-0 - deltaXfromLeftAndRight, maxY) toPoint:rightMiddlePoint radius:2.0];
    
    // right middle to right bottom
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX - deltaXfromLeftAndRight, minY) toPoint:rightBottomPoint radius:0.0];
    
    //left bottom to right bottom -- line
//    [path lineToPoint:leftBottomPoint];
    
    //    [path setLineWidth:frame.size.width];
    [path setClip];

    [path setLineWidth:2];

    [bgColr setFill];
    [NSBezierPath fillRect:dirtyRect];
  
    [borderColor set];
    [path stroke];
}

-(void)setSelectedBackground{
    bgColr = [NSColor windowBackgroundColor];
    selected = YES;
    [self setNeedsDisplay:YES];
}
-(void)setUnselectedBackground{
    bgColr = [NSColor colorWithWhite:0.82 alpha:1.0];
    selected = NO;
    [self setNeedsDisplay:YES];
}
@end
