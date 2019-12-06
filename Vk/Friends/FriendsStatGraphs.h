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

    NSMutableArray
        *pathRects,
        *pathRefs,
        *countryNames,
        *countryArray,
        *countryArrayFinal;
    CGContextRef
        ctx,
        pathRef;
    NSRect
        pathRect,
        pathRectForOver;
    NSInteger
        selectedPathIndex,
        xOffset,
        totalCountItems;
 
    NSColor
        *unselectedBarColor,
        *selectedBarColor,
        *strokeColor;
    

     NSArray *sortedArray;
    
    BOOL isSelectedBar;
    double itemHeight;
    
}
@property (nonatomic, readwrite) NSMutableArray *receivedData;
@property(nonatomic)NSTrackingArea *trackingArea;

@end
