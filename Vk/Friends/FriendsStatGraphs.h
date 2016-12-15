//
//  FriendsStatGraphs.h
//  vkapp
//
//  Created by sim on 18.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>

@interface FriendsStatGraphs : NSView{
    NSBezierPath *path;
    CGPathRef pathRef;
    NSMutableArray *pathRects;
    NSMutableArray *pathRefs;
    CGContextRef ctx ;
    NSRect pathRect;
    NSInteger selectedPathIndex;
    NSMutableArray *countryArray;
    NSMutableArray *countryArrayFinal;
    BOOL isSelectedBar;
    NSInteger xOffset;
    NSInteger totalCountItems;
    double itemHeight;
    NSColor *gray1;
    NSColor *gray2;
    NSColor *strokeColor;
    NSMutableArray *countryNames;
     NSArray *sortedArray;
    NSRect pathRectForOver;
}
@property (nonatomic, readwrite) NSMutableArray *receivedData;
@property(nonatomic)NSTrackingArea *trackingArea;

@end
