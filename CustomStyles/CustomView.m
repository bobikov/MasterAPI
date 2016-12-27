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
     bgColr = [NSColor lightGrayColor];
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    
    //    if (segment%2) {
    //        bgColr = [NSColor blackColor];
    //    }
    //    else {
    
    //    }
    //
    //    [bgColr setFill];
    //    [NSBezierPath fillRect:frame];
    
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
    
    
    // Start to construct border path
    
    // move path to left bottom point
    [path moveToPoint:leftBottomPoint];
    
    // left bottom to left middle
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX + deltaXfromLeftAndRight, minY) toPoint:leftMiddlePoint radius:0.0];
    
    // left middle to top middle
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX-0 + deltaXfromLeftAndRight, maxY) toPoint:topMiddlePoint radius:4.0];
    
    // top middle to right middle
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX-0 - deltaXfromLeftAndRight, maxY) toPoint:rightMiddlePoint radius:4.0];
    
    // right middle to right bottom
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX - deltaXfromLeftAndRight, minY) toPoint:rightBottomPoint radius:0.0];
    
    //left bottom to right bottom -- line
    [path lineToPoint:leftBottomPoint];
    
    //    [path setLineWidth:frame.size.width];
    [path setClip];
    
    //    [path setClip];
    //    [[NSColor blackColor] setStroke];
    [path setLineWidth:1];
    
   
    //     [NSBezierPath fillRect:frame];
    NSColor *gray1 = [NSColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
    NSColor *gray2 = [NSColor colorWithRed:0.90  green:0.90 blue:0.90 alpha:1.0];
//    if(segment==self.selectedSegment){
//        bgColr = gray1;
//        
//        
//    }
//    else{
//        bgColr = gray2;
//    }
    //
    [bgColr setFill];
    [NSBezierPath fillRect:dirtyRect];
    [path setLineWidth:1];
    [[NSColor grayColor] set];
    [path stroke];
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSColor whiteColor], NSForegroundColorAttributeName,
                                    [NSFont fontWithName:@"Avenir-Medium" size:12.0f], NSFontAttributeName,
                                    nil];
    
//    NSRect rect;
//    rect.size = [[self title] sizeWithAttributes:attributesDict];
//    rect.origin.x = roundf( NSMidX(frame) - rect.size.width / 2 );
//    rect.origin.y = roundf( NSMidY(frame) - rect.size.height / 2 );
//    [[self title] drawInRect:rect withAttributes:attributesDict];

}
-(void)setSelectedBackground{
    bgColr = [NSColor whiteColor];
    [self setNeedsDisplay:YES];
}
-(void)setUnselectedBackground{
    bgColr = [NSColor lightGrayColor];
    [self setNeedsDisplay:YES];
}
@end
