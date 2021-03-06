//
//  CustomView.m
//  vkapp
//
//  Created by sim on 12.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomView.h"
#import <Quartz/Quartz.h>
@implementation CustomView
-(void)awakeFromNib{
//    bgColr = [NSColor colorWithWhite:0.82 alpha:1.0];
    bgColr = [NSColor darkGrayColor];
    borderColor = [NSColor colorWithWhite:0.6 alpha:1.0];
    
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSBezierPath *path = [NSBezierPath bezierPath];
    int minX = NSMinX(dirtyRect)+10;
    int midX = NSMidX(dirtyRect);
    int maxX = NSMaxX(dirtyRect)-10;
    int minY = NSMinY(dirtyRect);
    int midY = NSMidY(dirtyRect);
    int maxY = NSMaxY(dirtyRect);
   
    NSPoint leftBottomPoint = NSMakePoint(minX-10, minY);
    
    NSPoint leftMiddlePoint = NSMakePoint(minX+5 + deltaXfromLeftAndRight, midY);
    
    NSPoint topMiddlePoint = NSMakePoint(midX, maxY);
    
    NSPoint rightMiddlePoint = NSMakePoint(maxX+3 - deltaXfromLeftAndRight, midY);
    NSPoint rightBottomPoint = NSMakePoint(maxX+10, minY);

    [path moveToPoint:leftBottomPoint];

    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX + deltaXfromLeftAndRight, minY) toPoint:leftMiddlePoint radius:selected ? 14.0 : 10.0];
    
    // left middle to top middle
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX+8 + deltaXfromLeftAndRight, maxY) toPoint:topMiddlePoint radius:14.0];
    
    // top middle to right middle
   
//    NSPoint point = NSMakePoint(maxX+6, minY+5);
//    NSPoint point2 = NSMakePoint(maxX+6, minY+5);
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX - deltaXfromLeftAndRight, maxY) toPoint:rightMiddlePoint radius:14.0];
//    [path appendBezierPathWithPoints:&rightMiddlePoint count:1];
//    [path appendBezierPathWithPoints:&point count:1];
    // right middle to right bottom
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX+8 - deltaXfromLeftAndRight, minY) toPoint:rightBottomPoint radius:selected ? 14.0 : 10.0];
    
    //left bottom to right bottom -- line
    //[path lineToPoint:leftBottomPoint];
    //    [path setLineWidth:frame.size.width];
    
    
    [path setClip];

    [path setLineWidth:2];


    [bgColr setFill];
    
    
    
    
    [NSBezierPath fillRect:dirtyRect];
    if (selected){
    
//        [bgGradient drawInRect:dirtyRect angle:90];
        
        
    }else{
//         [bgGradient drawInRect:dirtyRect angle:90];
        
    }
    [borderColor set];
    [path stroke];
    

}

-(void)setSelectedBackground{
    
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bounds;
    gradient.startPoint = CGPointZero;
    gradient.endPoint = CGPointMake(1, 1);
    
//    gradient.colors = [NSArray arrayWithObjects:(id)[[NSColor colorWithRed:34.0/255.0 green:211/255.0 blue:198/255.0 alpha:1.0] CGColor],(id)[[NSColor colorWithRed:145/255.0 green:72.0/255.0 blue:203/255.0 alpha:1.0] CGColor], nil];
//    [self.layer addSublayer:gradient];
//    gradient.colors =@[(id)[[NSColor colorWithWhite:0.87 alpha:1.0]CGColor], (id)[[NSColor colorWithWhite:0.92 alpha:1.0]CGColor]];
//    [self.layer addSublayer:gradient];
//    bgColr = [NSColor windowBackgroundColor];
//    bgGradient =[[NSGradient alloc]initWithColors:@[[NSColor colorWithWhite:0.87 alpha:1.0], [NSColor colorWithWhite:0.92 alpha:1.0]]];
    bgGradient = [[NSGradient alloc] initWithColorsAndLocations:
                  [NSColor  colorWithWhite:0.92 alpha:1.0],0.0,
                  [NSColor colorWithWhite:0.99 alpha:1.0],1.1,
     nil];
    selected = YES;
    [self setNeedsDisplay:YES];
}
-(void)setUnselectedBackground{
//    bgColr = [NSColor colorWithWhite:0.82 alpha:1.0];
    bgGradient = [[NSGradient alloc] initWithColorsAndLocations:
//                  [NSColor  colorWithWhite:0.70 alpha:1.0],0.0,
//                  [NSColor  colorWithWhite:0.75 alpha:1.0],0.1,
                  [NSColor  colorWithWhite:0.78 alpha:1.0],0.0,
                  [NSColor colorWithWhite:0.82 alpha:1.0],1.1,
                  nil];
    selected = NO;
    [self setNeedsDisplay:YES];
}
@end
