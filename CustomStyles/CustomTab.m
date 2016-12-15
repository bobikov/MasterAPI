//
//  CustomTab.m
//  vkapp
//
//  Created by sim on 11.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomTab.h"

@implementation CustomTab
-(void)awakeFromNib{
//    [self setImage: [NSImage imageNamed:NSImageNameBonjour]];
//    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
//    [style setAlignment:NSCenterTextAlignment];
//    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
//    NSAttributedString *attrString = [[NSAttributedString alloc]initWithString:@"tab" attributes:attrsDictionary];
//    [self setAttributedTitle:attrString];
   
}

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{

//    [[self image]drawInRect:NSMakeRect(50, 5, 15, 15)];
    [super drawWithFrame:cellFrame inView:controlView];
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSColor* bgColr;
    int minX = NSMinX(cellFrame);
    int midX = NSMidX(cellFrame);
    int maxX = NSMaxX(cellFrame);
    int minY = NSMinY(cellFrame);
    int midY = NSMidY(cellFrame);
    int maxY = NSMaxY(cellFrame);
    
    NSPoint leftBottomPoint = NSMakePoint(minX, maxY);
    NSPoint leftMiddlePoint = NSMakePoint(minX + 2, midY);
    NSPoint topMiddlePoint = NSMakePoint(midX, minY);
    NSPoint rightMiddlePoint = NSMakePoint(maxX - 2, midY);
    NSPoint rightBottomPoint = NSMakePoint(maxX, maxY);
    
    
    // Start to construct border path
    
    // move path to left bottom point
    [path moveToPoint:leftBottomPoint];
    
    // left bottom to left middle
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX + 2, maxY) toPoint:leftMiddlePoint radius:0.0];
    
    // left middle to top middle
    [path appendBezierPathWithArcFromPoint:NSMakePoint(minX+10 + 2, minY) toPoint:topMiddlePoint radius:5.0];
    
    // top middle to right middle
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX-10 - 2, minY) toPoint:rightMiddlePoint radius:5.0];
    
    // right middle to right bottom
    [path appendBezierPathWithArcFromPoint:NSMakePoint(maxX - 2, maxY) toPoint:rightBottomPoint radius:0.0];
    
    //left bottom to right bottom -- line
    //    [path lineToPoint:leftBottomPoint];
    
    //        [path setLineWidth:cellFrame.size.width];
    //    [path setClip];
    
  
    [path setClip];
  
    NSColor *gray1 = [NSColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0];
    NSColor *gray2 = [NSColor colorWithRed:0.90  green:0.90 blue:0.90 alpha:1.0];
    if(self.state==1){
        
        bgColr = gray2;
         [self setTitle:@"On"];
    }
    else{
        bgColr = gray1;
         [self setTitle:@"Off"];
    }

    [bgColr setFill];
    [NSBezierPath fillRect:cellFrame];
    [path setLineWidth:1];
    [[NSColor grayColor] set];
    [path stroke];
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSColor whiteColor], NSForegroundColorAttributeName,
                                    [NSFont fontWithName:@"Avenir-Medium" size:12.0f], NSFontAttributeName,
                                    nil];
    
    NSRect rect;
    rect.size = [[self title] sizeWithAttributes:attributesDict];
    rect.origin.x = roundf( NSMidX(cellFrame) - rect.size.width / 2 );
    rect.origin.y = roundf( NSMidY(cellFrame) - rect.size.height / 2 );
    [[self title] drawInRect:rect withAttributes:attributesDict];
   
    
}
//-(void)drawImage:(NSImage *)image withFrame:(NSRect)frame inView:(NSView *)controlView{
//    [super drawImage:image withFrame:frame inView:controlView];
//    image = [NSImage imageNamed:NSImageNameBonjour];
//    [image drawInRect:frame];
//}
//-(void)setTitle:(NSString *)title{
//    title si
//}
@end
