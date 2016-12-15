//
//  AudioListCustomCell.m
//  MasterAPI
//
//  Created by sim on 16.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "AudioListCustomCell.h"

@implementation AudioListCustomCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
//    _editItem.hidden=YES;
//    _deleteItem.hidden=YES;
    
//    [self createTrackingArea];
}
-(void)awakeFromNib{
    _editItem.hidden=YES;
    _deleteItem.hidden=YES;
    //
    [self createTrackingArea];
}
- (void)createTrackingArea
{
    
    _trackingArea = [[NSTrackingArea alloc] initWithRect:NSMakeRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width-20, self.frame.size.height) options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp owner:self userInfo:nil];
    //     _trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
    
    NSPoint mouseLocation = [self.window mouseLocationOutsideOfEventStream];
    mouseLocation = [self convertPoint: mouseLocation
                              fromView: nil];
    
//    if (NSPointInRect(mouseLocation, self.bounds))
//    {
//        [self mouseEntered: nil];
//    }
//    else
//    {
//        [self mouseExited: nil];
//    }
}
-(void)mouseEntered:(NSEvent *)theEvent{
    
    //    if([self accessibilityIndex]!=1 || [self accessibilityIndex]!=0){
    _editItem.hidden=NO;
    _deleteItem.hidden=NO;
    //    }
}
-(void)mouseExited:(NSEvent *)theEvent{
    _editItem.hidden=YES;
    _deleteItem.hidden=YES;
}

@end
