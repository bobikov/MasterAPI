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
    border = [CALayer layer];
    backG = [CALayer layer];
    self.wantsLayer=YES;
     border.backgroundColor = [[NSColor lightGrayColor]CGColor];
    border.frame = NSMakeRect(0, self.frame.size.height - 1.0, self.frame.size.width, 1.0);
//    [self.view.layer addSublayer:backG];
    [self.layer addSublayer:border];
    
}

-(void)layoutSublayersOfLayer:(CALayer *)layer{
    [super layoutSublayersOfLayer:layer];
     border.frame=NSMakeRect(0, self.frame.size.height - 1.0, self.frame.size.width, 1.0);
}
@end
