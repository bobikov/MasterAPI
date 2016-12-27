//
//  CustomScrollView.h
//  MasterAPI
//
//  Created by sim on 26.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CustomScrollView : NSScrollView{
    NSPoint firstPointFirstBorder;
    NSPoint secPointFirstBorder;
    NSPoint firstPointSecBorder;
    NSPoint secPointSecBorder;
    int minX;
    int maxX;
    int maxY;
    int minY;
}

@end
