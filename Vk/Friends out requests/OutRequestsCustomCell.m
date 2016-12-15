//
//  OutRequestsCustomCell.m
//  vkapp
//
//  Created by sim on 29.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "OutRequestsCustomCell.h"

@implementation OutRequestsCustomCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(void)awakeFromNib{
    
    _photo.wantsLayer=YES;
    _photo.layer.masksToBounds = YES;
    _photo.layer.cornerRadius = 80/2;
}

@end
