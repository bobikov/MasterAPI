//
//  CustomView.h
//  vkapp
//
//  Created by sim on 12.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#define deltaXfromLeftAndRight 2
@interface CustomView : NSView{
    NSColor* bgColr;
    NSColor *borderColor;
    BOOL selected;

    BOOL loaded;
}
-(void)setUnselectedBackground;
-(void)setSelectedBackground;

@end
