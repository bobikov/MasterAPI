//
//  VideoShowCollectionView.m
//  MasterAPI
//
//  Created by sim on 21.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "VideoShowCollectionView.h"

@implementation VideoShowCollectionView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
//-(void)rightMouseDown:(NSEvent *)theEvent
//{
//    
//    NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
//    [theMenu insertItemWithTitle:@"Move item to the end" action:@selector(MoveItemToTheEnd) keyEquivalent:@"" atIndex:0];
//    [theMenu insertItemWithTitle:@"TestMethod" action:@selector(TestMethod) keyEquivalent:@"" atIndex:1];
//    
//    [NSMenu popUpContextMenu:theMenu withEvent:theEvent forView:self];
//    
//   return [super rightMouseDown:theEvent];
//    
//}
//-(void)MoveItemToTheEnd{
//    NSLog(@"%@", [self selectionIndexPaths]);
//}
//
//-(void)TestMethod{
//    NSLog(@"Honk");
//}
@end
