//
//  CustomTextField.m
//  vkapp
//
//  Created by sim on 27.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(NSSize)intrinsicContentSize
{
    if ( ![self.cell wraps] ) {
        return [super intrinsicContentSize];
    }
    
    NSRect frame = [self frame];
    
    CGFloat width = frame.size.width;
    
    // Make the frame very high, while keeping the width
    frame.size.height = CGFLOAT_MAX;
    
    // Calculate new height within the frame
    // with practically infinite height.
    CGFloat height = [self.cell cellSizeForBounds: frame].height;
    
    return NSMakeSize(width, height);
}

// you need to invalidate the layout on text change, else it wouldn't grow by changing the text
- (void)textDidChange:(NSNotification *)notification
{
    [super textDidChange:notification];
    [self invalidateIntrinsicContentSize];
}
@end
