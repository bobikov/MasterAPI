//
//  TumblrPostCell.m
//  MasterAPI
//
//  Created by sim on 18.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "TumblrPostCell.h"

@implementation TumblrPostCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
}

-(void)awakeFromNib{
    [self createTrackingArea];
}
-(void)createTrackingArea{
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.postPhoto.frame options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
    
    NSPoint mouseLocation = [self.window mouseLocationOutsideOfEventStream];
    mouseLocation = [self convertPoint: mouseLocation
                              fromView: nil];
    
    if (NSPointInRect(mouseLocation, self.bounds))
    {
        [self mouseEntered: nil];
    }
    else
    {
        [self mouseExited: nil];
    }
}
- (void)mouseEntered:(NSEvent *)theEvent{
    
    [[NSCursor pointingHandCursor]set];
 
    
    
    
}

- (void)mouseExited:(NSEvent *)theEvent{
//      [[NSCursor currentCursor]set];

    
}
@end
