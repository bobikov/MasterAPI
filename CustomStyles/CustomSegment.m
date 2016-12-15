//
//  CustomSegment.m
//  vkapp
//
//  Created by sim on 10.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomSegment.h"

@implementation CustomSegment

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
    int i=0;
    NSInteger count=[self segmentCount];
    NSRect segmentFrame=cellFrame;
    
    for(i=0; i<count; i++) {
        segmentFrame.size.width=[self widthForSegment:i];
        [NSGraphicsContext saveGraphicsState];
        // Make sure that segment drawing is not allowed to spill out into other segments
        NSBezierPath* clipPath = [NSBezierPath bezierPathWithRect: segmentFrame];
        [clipPath addClip];
        [self drawSegment:i inFrame:segmentFrame withView:controlView];
        [NSGraphicsContext restoreGraphicsState];
        segmentFrame.origin.x+=segmentFrame.size.width;
    }
    
//    _lastDrawRect=cellFrame;
}

-(void)drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView *)controlView{
    
//     float radius = 4.0;
//    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:8 yRadius:8];
     NSBezierPath *path = [NSBezierPath bezierPath];
   
    NSColor* bgColr;
//    if (segment%2) {
//        bgColr = [NSColor blackColor];
//    }
//    else {
    
//    }
//    
//    [bgColr setFill];
//    [NSBezierPath fillRect:frame];
    
    int minX = NSMinX(frame);
    int midX = NSMidX(frame);
    int maxX = NSMaxX(frame);
    int minY = NSMinY(frame);
    int midY = NSMidY(frame);
    int maxY = NSMaxY(frame);
    
    NSPoint leftBottomPoint = NSMakePoint(minX, maxY);
    NSPoint leftMiddlePoint = NSMakePoint(minX + deltaXfromLeftAndRight, midY);
    NSPoint topMiddlePoint = NSMakePoint(midX, minY);
    NSPoint rightMiddlePoint = NSMakePoint(maxX - deltaXfromLeftAndRight, midY);
    NSPoint rightBottomPoint = NSMakePoint(maxX, maxY);
    

    // Start to construct border path
    
    // move path to left bottom point
    [path moveToPoint:leftBottomPoint];
    
    // left bottom to left middle
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX + deltaXfromLeftAndRight, maxY) toPoint:leftMiddlePoint radius:0.0];
    
    // left middle to top middle
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX+10 + deltaXfromLeftAndRight, minY) toPoint:topMiddlePoint radius:4.0];
    
    // top middle to right middle
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX-10 - deltaXfromLeftAndRight, minY) toPoint:rightMiddlePoint radius:4.0];
    
    // right middle to right bottom
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX - deltaXfromLeftAndRight, maxY) toPoint:rightBottomPoint radius:0.0];
    
    //left bottom to right bottom -- line
    [path lineToPoint:leftBottomPoint];
    
//    [path setLineWidth:frame.size.width];
    [path setClip];

//    [path setClip];
//    [[NSColor blackColor] setStroke];
    [path setLineWidth:1];
   
    bgColr = [NSColor grayColor];
//     [NSBezierPath fillRect:frame];
    NSColor *gray1 = [NSColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
    NSColor *gray2 = [NSColor colorWithRed:0.90  green:0.90 blue:0.90 alpha:1.0];
    if(segment==self.selectedSegment){
        bgColr = gray1;
        
        
    }
    else{
         bgColr = gray2;
    }
//
    [bgColr setFill];
    [NSBezierPath fillRect:frame];
    [path setLineWidth:1];
    [[NSColor grayColor] set];
    [path stroke];
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSColor whiteColor], NSForegroundColorAttributeName,
                                    [NSFont fontWithName:@"Avenir-Medium" size:12.0f], NSFontAttributeName,
                                    nil];
    
    NSRect rect;
    rect.size = [[self title] sizeWithAttributes:attributesDict];
    rect.origin.x = roundf( NSMidX(frame) - rect.size.width / 2 );
    rect.origin.y = roundf( NSMidY(frame) - rect.size.height / 2 );
    [[self title] drawInRect:rect withAttributes:attributesDict];
}

@end
