//
//  MyTableRowView.m
//  MasterAPI
//
//  Created by sim on 06/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "MyTableRowView.h"
#import <NSColor+HexString.h>
@implementation MyTableRowView
- (id)init
{
    if (!(self = [super init])) return nil;
    return self;
}
- (void)drawSelectionInRect:(NSRect)dirtyRect {
    if (self.selectionHighlightStyle !=    NSTableViewSelectionHighlightStyleNone) {
        NSRect selectionRect = NSInsetRect(self.bounds, 2.5, 2.5);
//        [[NSColor colorWithCalibratedWhite:.65 alpha:1.0] setStroke];
//        [[NSColor colorWithHexString:@"F0F2F5"] setFill];
        [[NSColor colorWithHexString:@"CDCDC1"] setFill];
        [[NSColor colorWithHexString:@"8B8B83"] setStroke];
//        [[NSColor colorWithHexString:@"4682B4"] setStroke];
//        [[NSColor colorWithCalibratedWhite:.82 alpha:1.0] setFill];
        NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect
                                                                      xRadius:6 yRadius:6];
        [selectionPath fill];
        [selectionPath stroke];
    }
}
@end
