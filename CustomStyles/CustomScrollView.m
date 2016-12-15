//
//  CustomScrollView.m
//  MasterAPI
//
//  Created by sim on 26.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "CustomScrollView.h"

@implementation CustomScrollView
-(void)awakeFromNib{
 
  
}
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
   
    // Drawing code here.
}
- (void)tile {
    [super tile];
//    self.wantsLayer=YES;
//    self.layer.masksToBounds=YES;
//    self.contentView.wantsLayer=YES;
//    self.contentView.layer.masksToBounds=YES;
//    [[self contentView] setFrame:NSMakeRect(1, 1, self.frame.size.width-2, self.frame.size.height-2)];
//     [[self contentView] setFrame:[self bounds]];
    NSRect scrollViewFrame = [[self contentView] frame];
    scrollViewFrame.size.width = self.frame.size.width-3;
    [[self contentView] setFrame:scrollViewFrame];
}
@end
