//
//  FriendsStatGraphs.m
//  vkapp
//
//  Created by sim on 18.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "FriendsStatGraphs.h"

@implementation FriendsStatGraphs
-(void)awakeFromNib{
    _receivedData = [[NSMutableArray alloc]init];
    countryNames = [[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGraphsData:) name:@"friendsGraphsData" object:nil];
    countryArray = [[NSMutableArray alloc]init];
    countryArrayFinal = [[NSMutableArray alloc]init];
    pathRects = [[NSMutableArray alloc]init];
    pathRefs = [[NSMutableArray alloc]init];
    xOffset=2;
    unselectedBarColor = [NSColor colorWithRed:0.25  green:0.45 blue:0.55 alpha:1.0];
    selectedBarColor = [NSColor colorWithRed:0.25  green:0.45 blue:0.60 alpha:1.0];
    strokeColor = [NSColor colorWithRed:0.20  green:0.70 blue:0.80 alpha:1.0];
}
-(void)loadGraphsData:(NSNotification *)notification{
    _receivedData = notification.userInfo[@"data"] ;
     totalCountItems = [_receivedData count];
}
-(void)drawRect:(NSRect)dirtyRect{
    if(!isSelectedBar){
        [self drawStatBars];
    }
    [self setBarSelected];
   }
-(void)setBarSelected{
    NSPoint mouseLocation = [self.window mouseLocationOutsideOfEventStream];
    mouseLocation = [self convertPoint: mouseLocation fromView: nil];
    isSelectedBar=YES;
    for(NSValue *i in pathRects){
        if (NSPointInRect(mouseLocation, [i rectValue])){
            [selectedBarColor setFill];
            [strokeColor setStroke];
            
            selectedPathIndex = [pathRects indexOfObject:i];
            [[pathRefs objectAtIndex:selectedPathIndex] fill];
            [[pathRefs objectAtIndex:selectedPathIndex] stroke];
            [self drawSelectedBarExtLabel];
//
        }else{
            [unselectedBarColor setFill];
//            [[NSColor blackColor] setStroke];
            selectedPathIndex = [pathRects indexOfObject:i];
            [[pathRefs objectAtIndex:selectedPathIndex] fill];
            //[[pathRefs objectAtIndex:selectedPathIndex] stroke];

        }
    }

}
-(void)drawStatBars{
//    countryNames = [NSArray arrayWithObjects:@"Россия", @"Украина", @"Беларусь", @"Казахстан", @"США", @"Турция", @"none", @"Ирак", @"Польша", nil];
    for(NSDictionary *i in _receivedData){
        NSString *name =  [i[@"country"] isEqual:@""] ? @"none" : i[@"country"];
        if(![countryNames containsObject:name]){
            [countryNames addObject:name];
        }
    }
    for (NSDictionary *i in _receivedData){
        [countryArray addObject:[i[@"country"] isEqual:@""]?@"none":i[@"country"]];
    }
//    NSLog(@"%@", countryArray);
    NSCountedSet *countCountrySet = [[NSCountedSet alloc]initWithArray:countryArray];
    
    for(NSString *a in countryNames){
        if([countCountrySet countForObject:a]>0)
            [countryArrayFinal addObject:@{@"country":a, @"count":[NSNumber numberWithInteger:[countCountrySet countForObject:a]]}];
    }
 
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"count"
                                                 ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
   
    sortedArray = [countryArrayFinal sortedArrayUsingDescriptors:sortDescriptors];
//       NSLog(@"%@", sortedArray);
    //        [countryArrayFinal sortedArrayUsingSelector:@selector(compare:)]
    for (NSDictionary *i in sortedArray ){
        itemHeight = round(([i[@"count"] doubleValue] / totalCountItems) * self.frame.size.height);
//              NSLog(@"ITEM HEIGHT %f", [i[@"count"] doubleValue]);
        //      self.frame = NSMakeRect(0, 0, (100+5)*3, self.frame.size.height);
        pathRect = NSMakeRect(xOffset, 2, (self.frame.size.width/[sortedArray count])-2, itemHeight);
        pathRectForOver = NSMakeRect(xOffset, 2, (self.frame.size.width/[sortedArray count])-2, self.frame.size.height-20);
        _trackingArea = [[NSTrackingArea alloc] initWithRect:pathRectForOver options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp owner:self userInfo:nil];
        [self addTrackingArea:_trackingArea];
        path = [NSBezierPath bezierPathWithRoundedRect:pathRect xRadius:2 yRadius:2];
        
        path.lineWidth=2;
        
        [[NSColor blackColor] setStroke];
        //            [path stroke];
        [unselectedBarColor setFill];
        [path fill];
        
        //            [path closePath];
        [pathRects addObject:[NSValue valueWithRect:pathRectForOver]];
        [pathRefs addObject:path];
        
        xOffset+=(self.frame.size.width/[countryArrayFinal count])+0;
        
    }
}
-(void)drawSelectedBarExtLabel{
    NSRect nameOfCountryRectLabel = NSMakeRect(4, self.frame.size.height-20, 120, 15);
    NSBezierPath *patnameOfCountryPathLabel = [NSBezierPath bezierPathWithRoundedRect:nameOfCountryRectLabel xRadius:2 yRadius:2];
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle alloc]init];
    textStyle.alignment = NSTextAlignmentCenter;
    NSDictionary* textFontAttributes = @{NSFontAttributeName: [NSFont fontWithName: @"Helvetica" size: 12], NSForegroundColorAttributeName: [NSColor whiteColor], NSParagraphStyleAttributeName: textStyle};
    
    patnameOfCountryPathLabel.lineWidth=2;
    
    [[NSColor blackColor] setStroke];
    [patnameOfCountryPathLabel fill];
    [[NSString stringWithFormat:@"%@ %@",   [sortedArray[selectedPathIndex][@"country"] isEqual:@"none"] ? @"Неизвестно" : sortedArray[selectedPathIndex][@"country"], sortedArray[selectedPathIndex][@"count"]] drawInRect:nameOfCountryRectLabel withAttributes:textFontAttributes];
}
-(void)mouseEntered:(NSEvent *)theEvent{
 
    [self setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)theEvent{

    [self setNeedsDisplay:YES];

}

@end
