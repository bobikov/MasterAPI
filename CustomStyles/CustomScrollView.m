//
//  CustomScrollView.m
//  MasterAPI
//
//  Created by sim on 26.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomScrollView.h"

@implementation CustomScrollView
-(void)awakeFromNib{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(redrawLine:) name:@"redrawBorderLine" object:nil];

}
-(void)redrawLine:(NSNotification*)notification{
    int x = [notification.userInfo[@"rect"] rectValue].origin.x;
    int y = [notification.userInfo[@"rect"] rectValue].origin.y;

    secPointFirstBorder = NSMakePoint(minX, x);
    [self setNeedsDisplay:YES];
}
- (void)drawRect:(NSRect)dirtyRect {
     [super drawRect:dirtyRect];
   [NSGraphicsContext saveGraphicsState];
    NSBezierPath *path = [NSBezierPath bezierPath];
 
    firstPointFirstBorder = NSMakePoint(minX, minY);
    secPointFirstBorder = NSMakePoint(maxX, minY);
    minX = NSMinX(dirtyRect);
    maxX = NSMaxX(dirtyRect);
    maxY = NSMaxY(dirtyRect);
    minY = NSMinY(dirtyRect);
    
    [[NSColor blackColor] set];
    [path setLineWidth:5.0];
//    [path setWindingRule:NSEvenOddWindingRule];
//    [path setClip];
    [path moveToPoint:firstPointFirstBorder];
    [path appendBezierPathWithArcFromPoint:firstPointFirstBorder toPoint:secPointFirstBorder radius:0.0];

    [path stroke];
   [NSGraphicsContext restoreGraphicsState];
    
}

@end
