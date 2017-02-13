//
//  KBButtonCell.m
//  CustomButtons
//
//  Created by Kyle Bock on 11/2/12.
//  Copyright (c) 2012 Kyle Bock. All rights reserved.
//

#import "KBButtonCell.h"
#import "NSColor+ColorExtensions.h"
#import <NSColor-HexString/NSColor+HexString.h>
@implementation KBButtonCell

- (void)setKBButtonType:(BButtonType)type {
    [[NSGraphicsContext currentContext] saveGraphicsState];
    kbButtonType = type;
    [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (NSColor*)getColorForButtonType {
    switch (kbButtonType) {
        case BButtonTypeDefault:
            return [NSColor colorWithCalibratedRed:0.85f green:0.85f blue:0.85f alpha:1.00f];
            break;
        case BButtonTypePrimary:
            return [NSColor colorWithCalibratedRed:0.00f green:0.33f blue:0.80f alpha:1.00f];
            break;
        case BButtonTypeInfo:
            return [NSColor colorWithCalibratedRed:0.18f green:0.59f blue:0.71f alpha:1.00f];
            break;
        case BButtonTypeSuccess:
            return [NSColor colorWithCalibratedRed:0.32f green:0.64f blue:0.32f alpha:1.00f];
            break;
        case BButtonTypeWarning:
            return [NSColor colorWithCalibratedRed:0.97f green:0.58f blue:0.02f alpha:1.00f];
            break;
        case BButtonTypeDanger:
            return [NSColor colorWithCalibratedRed:0.74f green:0.21f blue:0.18f alpha:1.00f];
            break;
        case BButtonTypeInverse:
            return [NSColor colorWithCalibratedRed:0.13f green:0.13f blue:0.13f alpha:1.00f];
        case BButtonTypeSimple:
            return  [NSColor colorWithCalibratedRed:0.99f green:0.99f blue:0.99f alpha:1.00f];
            break;
    }
}
-(NSRect)getInsetedRect:(NSRect)frame{
   
    switch (kbButtonType) {
        case BButtonTypeDefault:
            return  NSInsetRect(frame, 1.0f, 1.0f);
            break;
        case BButtonTypePrimary:
            return  NSInsetRect(frame, 1.0f, 1.0f);
            break;
        case BButtonTypeInfo:
            return  NSInsetRect(frame, 1.0f, 1.0f);
            break;
        case BButtonTypeSuccess:
            return  NSInsetRect(frame, 1.0f, 1.0f);
            break;
        case BButtonTypeWarning:
            return  NSInsetRect(frame, 1.0f, 1.0f);
            break;
        case BButtonTypeDanger:
            return  NSInsetRect(frame, 1.0f, 1.0f);
            break;
        case BButtonTypeInverse:
            return  NSInsetRect(frame, 1.0f, 1.0f);
        case BButtonTypeSimple:
            return  NSInsetRect(frame, 1.0f, 1.0f);
    }

}
- (void)drawBezelWithFrame:(NSRect)frame inView:(NSView *)controlView
{
    NSGraphicsContext* ctx = [NSGraphicsContext currentContext];
    
    // corner radius
    CGFloat roundedRadius = 3.0f;
    
    NSColor *color = [self getColorForButtonType];
    
    // Draw darker overlay if button is pressed
    if([self isHighlighted]) {
        [ctx saveGraphicsState];
        if(kbButtonType==BButtonTypeSimple){
               roundedRadius=10;
            [[NSBezierPath bezierPathWithRoundedRect:[self getInsetedRect:frame]
                                             xRadius:roundedRadius
                                             yRadius:roundedRadius] setClip];
            NSShadow * shadow = [[NSShadow alloc] init];
            shadow.shadowOffset=NSMakeSize(0, -1);
            [shadow setShadowColor:[NSColor darkGrayColor]];
            [shadow setShadowBlurRadius:1.0];
            [shadow set];
            NSGradient* bgGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                      [NSColor colorWithWhite:0.68 alpha:1], 0.0f,
                                      [NSColor colorWithWhite:0.70 alpha:1], 1.0f,
                                      nil];
            [bgGradient drawInRect:[self getInsetedRect:frame] angle:90.0f];
            [ctx restoreGraphicsState];
//            NSRectFill(frame);
                  return;
        }else{
            [[NSBezierPath bezierPathWithRoundedRect:frame
                                             xRadius:roundedRadius
                                             yRadius:roundedRadius] setClip];
            [[color darkenColorByValue:0.12f] setFill];
            NSRectFillUsingOperation(frame, NSCompositeSourceOver);
            [ctx restoreGraphicsState];
                  return;
        }
  
    }
    if(kbButtonType!=BButtonTypeSimple){
        // create background color
        [ctx saveGraphicsState];
        [[NSBezierPath bezierPathWithRoundedRect:frame
                                         xRadius:roundedRadius
                                         yRadius:roundedRadius] setClip];
        [[color darkenColorByValue:0.12f] setFill];
        NSRectFillUsingOperation(frame, NSCompositeSourceOver);
        [ctx restoreGraphicsState];
        
        
        //draw inner button area
        [ctx saveGraphicsState];
        
        NSBezierPath* bgPath = [NSBezierPath bezierPathWithRoundedRect:[self getInsetedRect:frame] xRadius:roundedRadius yRadius:roundedRadius];
        [bgPath setClip];
        
        NSColor* topColor = [color lightenColorByValue:0.12f];
        
        // gradient for inner portion of button
        NSGradient* bgGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                  topColor, 0.0f,
                                  color, 1.0f,
                                  nil];
         [bgGradient drawInRect:[bgPath bounds] angle:90.0f];
        [ctx restoreGraphicsState];
    }else{
        roundedRadius=10;
        [ctx saveGraphicsState];
        NSBezierPath *stroke = [NSBezierPath bezierPathWithRoundedRect:[self getInsetedRect:frame] xRadius:roundedRadius yRadius:roundedRadius];
      
        stroke.lineWidth=0;
//        [[NSColor colorWithWhite:0.70 alpha:1]setFill];
//        [[NSColor colorWithWhite:0.66 alpha:1]setStroke];
//        [stroke fill];
        [stroke setClip];
        NSShadow * shadow = [[NSShadow alloc] init];
        shadow.shadowOffset=NSMakeSize(0, -1);
        [shadow setShadowColor:[NSColor whiteColor]];
        [shadow setShadowBlurRadius:1.0];
        [shadow set];
        
        NSGradient* bgGradient = [[NSGradient alloc] initWithColorsAndLocations:
                                  [NSColor colorWithWhite:0.88 alpha:1], 0.0f,
                                  [NSColor colorWithWhite:0.70 alpha:1], 1.0f,
                                  nil];
        [bgGradient drawInRect:[self getInsetedRect:frame] angle:90.0f];
//        [stroke stroke];
     
        
//        [[NSColor colorWithCalibratedRed:0.00f green:0.33f blue:0.80f alpha:1.00f] setFill];
//        NSRectFillUsingOperation(frame, NSCompositeSourceOver);
        
        [ctx restoreGraphicsState];
        
        
//        [ctx saveGraphicsState];
//        NSBezierPath *bgPath = [NSBezierPath bezierPathWithRoundedRect:[self getInsetedRect:frame] xRadius:roundedRadius yRadius:roundedRadius];
//        [bgPath setClip];
//        [color setFill];
//        NSRectFillUsingOperation(frame, NSCompositeSourceOver);
//        [ctx restoreGraphicsState];
    }
       
    
    

}

- (NSRect) drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    NSGraphicsContext* ctx = [NSGraphicsContext currentContext];
    
    [ctx saveGraphicsState];
    NSMutableAttributedString *attrString = [title mutableCopy];
    [attrString beginEditing];
    NSColor *titleColor;
    if ([[self getColorForButtonType] isLightColor]) {
        titleColor = [NSColor blackColor];
    } else {
        titleColor = [NSColor whiteColor];
    }
    if(kbButtonType==BButtonTypeSimple){
        titleColor = [NSColor colorWithWhite:0.99 alpha:1];
    }
    [attrString addAttribute:NSForegroundColorAttributeName value:titleColor range:NSMakeRange(0, [[self title] length])];
    [attrString addAttribute:NSBaselineOffsetAttributeName value:@0 range:NSMakeRange(0, [[self title]length])];
    [attrString endEditing];
    NSRect r = [super drawTitle:attrString withFrame:frame inView:controlView];
    
    // 5) Restore the graphics state
    [ctx restoreGraphicsState];
    
    return r;
}
-(void)mouseEntered:(NSEvent *)event{
    NSLog(@"AAAAA");
}
@end
