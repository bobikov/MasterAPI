//
//  CustomMenuItemView.m
//  MasterAPI
//
//  Created by sim on 06.12.16.
//  Copyright © 2016 sim. All rights reserved.
//
#define menuItem ([self enclosingMenuItem])
#import "CustomMenuItemView.h"

@implementation CustomMenuItemView

- (void) drawRect: (NSRect) rect {
    BOOL isHighlighted = [menuItem isHighlighted];
    if (isHighlighted) {
        [[NSColor selectedMenuItemColor] set];
//        [[NSColor whiteColor] setStroke];

        [NSBezierPath fillRect:rect];
        NSVisualEffectView *ff = [[NSVisualEffectView alloc]init];
        [ff setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
//        [ff setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
     
        [_nameField addSubview:ff positioned:NSWindowBelow relativeTo:_nameField];
//        _photo.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        NSAttributedString *textString = [[NSAttributedString alloc]initWithString:_nameField.stringValue attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSBackgroundColorAttributeName:[NSColor clearColor],NSBackgroundColorDocumentAttribute:[NSColor clearColor]}];
            _nameField.attributedStringValue=textString;
        
        NSVisualEffectView *ff2 = [[NSVisualEffectView alloc]init];
        [ff2 setMaterial:NSVisualEffectMaterialLight];
        [ff2 setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        [ff2 setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameVibrantLight]];
        [_photo addSubview:ff2 positioned:NSWindowBelow relativeTo:_photo];
     
      
    } else {
        
        NSAttributedString *textString = [[NSAttributedString alloc]initWithString:_nameField.stringValue attributes:@{NSForegroundColorAttributeName:[NSColor blackColor]}];
        _nameField.attributedStringValue=textString;
//        [super drawRect: rect];
    }
}
- (void)mouseUp:(NSEvent*) event
{
    NSMenu *menu = self.enclosingMenuItem.menu;
    [menu cancelTracking];
    [menu performActionForItemAtIndex:[menu indexOfItem:self.enclosingMenuItem]];
}
-(BOOL)allowsVibrancy{
    return YES;
}
- (NSImage *)_cornerMask
{
    CGFloat radius = 40.0;
    CGFloat dimension = 2 * radius + 1;
    NSSize size = NSMakeSize(dimension, dimension);
    NSImage *image = [NSImage imageWithSize:size flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
        NSBezierPath *bezierPath = [NSBezierPath bezierPathWithRoundedRect:dstRect xRadius:radius yRadius:radius];
        [[NSColor blackColor] set];
        [bezierPath fill];
        return YES;
    }];
    image.capInsets = NSEdgeInsetsMake(radius, radius, radius, radius);
    image.resizingMode = NSImageResizingModeStretch;
    return image;
}

- (NSImage *)cornerMask
{
    return [self _cornerMask];
}
@end
