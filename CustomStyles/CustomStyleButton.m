//
//  CustomStyleButton.m
//  vkapp
//
//  Created by sim on 29.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomStyleButton.h"

@implementation CustomStyleButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    NSBezierPath *path = [NSBezierPath bezierPath];
    NSColor* bgColr;
    int minX = NSMinX(dirtyRect);
    int midX = NSMidX(dirtyRect);
    int maxX = NSMaxX(dirtyRect);
    int minY = NSMinY(dirtyRect);
    int midY = NSMidY(dirtyRect);
    int maxY = NSMaxY(dirtyRect);
    
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
    
    //        [path setLineWidth:dirtyRect.size.width];
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
//            bgColr = [NSColor grayColor];
    [bgColr setFill];
    [NSBezierPath fillRect:dirtyRect];
    [path setLineWidth:1];
    [[NSColor grayColor] set];
    [path stroke];
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSColor whiteColor], NSForegroundColorAttributeName,
                                    [NSFont fontWithName:@"Avenir-Medium" size:12.0f], NSFontAttributeName,
                                    nil];
    
    NSRect rect;
    rect.size = [[self title] sizeWithAttributes:attributesDict];
    rect.origin.x = roundf( NSMidX([self bounds]) - rect.size.width / 2 );
    rect.origin.y = roundf( NSMidY([self bounds]) - rect.size.height / 2 );
    [[self title] drawInRect:rect withAttributes:attributesDict];
    NSImageView *imageView = [[NSImageView alloc]initWithFrame:NSMakeRect(NSMaxX([self bounds])-30, 5, 15, 15)];
    NSImage *image = [NSImage imageNamed:NSImageNameCaution];
    [imageView setImage:image];
//    if(self.state==1){

    [image drawInRect:imageView.frame];
    [imageView setAction:@selector(imageClick:)];
  


    

        
//    }
//    else{
    
//    }
  
    
}
-(void)imageClick:(NSEvent *)theEvent{
    NSLog(@"Close");
}
//- (BOOL)wantsUpdateLayer{
//    
//    return YES;
//}

//- (void) updateLayer{
////    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
////    [style setAlignment:NSCenterTextAlignment];
////    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSColor blackColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];
////    NSAttributedString *attrString = [[NSAttributedString alloc]initWithString:@"tab" attributes:attrsDictionary];
////    [self setAttributedTitle:attrString];
////    NSBezierPath *path = [NSBezierPath bezierPathWithRect:NSMakeRect(0, 0, 100, 10)];
////    self.wantsLayer=YES;
//    self.layer.frame = NSMakeRect(0, 0, 100, 30);
////
////    self.layer.cornerRadius=5;
////    self.layer.masksToBounds = YES;
////
//    NSColor *myColor1 = [NSColor colorWithSRGBRed:0.103 green:0.80 blue:100 alpha:1.0f];
//    NSColor *myColor2 = [NSColor colorWithSRGBRed:0.103 green:0.60 blue:100 alpha:1.0f];
////
//    if([self.cell isHighlighted]){
//          [self.layer setBackgroundColor:[myColor2 CGColor]];
//    }
//    else{
//         [self.layer setBackgroundColor: [myColor1 CGColor] ];
//    }
//    
//    
//}

@end
