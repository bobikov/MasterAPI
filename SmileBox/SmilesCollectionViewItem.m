//
//  SmilesCollectionViewItem.m
//  MasterAPI
//
//  Created by sim on 29.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "SmilesCollectionViewItem.h"

@interface SmilesCollectionViewItem ()

@end

@implementation SmilesCollectionViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
     [self createTrackingArea];
//   self.view.wantsLayer=YES;
//    self.view.layer.masksToBounds=YES;
//      self.view.layer.backgroundColor=[[NSColor whiteColor]CGColor];
//   
    
//    _smileItem.layer.masksToBounds=YES;
//    _smileItem.layer.cornerRadius=2;
   
}
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        [self setSelected:NO];
    }
}
- (void)createTrackingArea
{
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.view.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp owner:self userInfo:nil];
    [self.view addTrackingArea:_trackingArea];
    
    NSPoint mouseLocation = [self.view.window mouseLocationOutsideOfEventStream];
    mouseLocation = [self.view convertPoint: mouseLocation
                                   fromView: nil];
    
    //    if (NSPointInRect(mouseLocation, self.view.bounds))
    //    {
    //        [self mouseEntered: nil];
    //    }
    //    else
    //    {
    //        [self mouseExited: nil];
    //    }
}
-(void)mouseEntered:(NSEvent *)theEvent{
   [[NSCursor pointingHandCursor]set];
//    _smileItem.wantsLayer=YES;
//    _smileItem.layer.masksToBounds=YES;
//    _smileItem.layer.cornerRadius=3;
//    _smileItem.layer.backgroundColor=[[NSColor grayColor]CGColor];
//    _smileItem.backgroundColor=[NSColor colorWithRed:0.20 green:0.50 blue:0.70 alpha:0.6];
}
-(void)mouseExited:(NSEvent *)theEvent{
      [[NSCursor arrowCursor]set];
//    _smileItem.wantsLayer=NO;
//    _smileItem.layer.masksToBounds=NO;
//    _smileItem.backgroundColor=[NSColor whiteColor];
}
@end
