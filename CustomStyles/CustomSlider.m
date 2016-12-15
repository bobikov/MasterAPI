//
//  CustomSlider.m
//  vkapp
//
//  Created by sim on 06.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomSlider.h"

@implementation CustomSlider
@synthesize changing;
//
-(void)awakeFromNib{
    self.knobImage = [NSImage imageNamed:@"bar.png"];
}

-(NSRect)knobRectFlipped:(BOOL)flipped {
    
    if (NSEqualRects(NSZeroRect, self.controlView.bounds)) {
        return NSZeroRect;
    }
    
    double progress = ([self doubleValue]+2 - [self minValue]) / ([self maxValue] - [self minValue]);
    
    NSRect rect = (NSRect) {
        .size = NSMakeSize(3,8),
        .origin = NSMakePoint(floor((NSWidth(self.controlView.bounds) - [self knobThickness]) * progress),
                              5)
    };
    
    return rect;
}
-(CGFloat)knobThickness{
    return 5.0;
}
//- (NSRect)knobRectFlipped:(BOOL)flipped {
//    CGFloat knobCenterPosition = roundf(size.width * self.floatValue / self.maxValue);
//    // knob should always be entirely visible
//    knobCenterPosition = MIN(MAX(knobCenterPosition, roundf(KNOB_WIDTH / 2) + KNOB_INSET), size.width - (roundf(KNOB_WIDTH / 2) + KNOB_INSET));
//    return  NSMakeRect(knobCenterPosition - roundf(KNOB_WIDTH / 2), 0, KNOB_WIDTH, self.cellSize.height);
//}
- (void)drawKnob:(NSRect)knobRect
{
    
    knobRect.size = NSMakeSize(3, 8);
    _knobImage.size=NSMakeSize(3, 8);
    knobRect.origin.y=5;
//    NSBezierPath *path = [NSBezierPath bezierPathWithRect:knobRect];
//    [[NSColor redColor]set];
//    [path fill];
    [_knobImage drawAtPoint:NSMakePoint(knobRect.origin.x, knobRect.origin.y) fromRect:self.controlView.bounds operation:NSCompositeSourceOver fraction:1.0];
}
//- (void)drawBarInside:(NSRect)rect flipped:(BOOL)flipped{
//    [super drawBarInside:rect flipped:flipped];
//    NSBezierPath *thePath = [NSBezierPath bezierPath];
//    [thePath setLineWidth:0.5];
//    NSColor *barBorderColor = [NSColor colorWithRed:0.60 green:20 blue:0.5 alpha:1.0];
//    [thePath moveToPoint:NSMakePoint(20,20)];
//    [thePath appendBezierPath:[NSBezierPath bezierPathWithRoundedRect:rect xRadius:2 yRadius:2]];
////    [[NSColor redColor] set];
//    [barBorderColor set];
//    [thePath stroke];
//    [thePath fill];
//}



@end
