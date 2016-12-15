//
//  FriendsCustomCellView.m
//  vkapp
//
//  Created by sim on 26.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "FriendsCustomCellView.h"

@implementation FriendsCustomCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(void)awakeFromNib{
//    _photo.wantsLayer=YES;
//    _photo.layer.masksToBounds=YES;
//    _photo.layer.cornerRadius = 80/2;
}
- (IBAction)profileAction:(id)sender {
//    NSStoryboard *story = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
//    NSViewController *popuper = [story instantiateControllerWithIdentifier:@"profilePopup"];
//
//    CGRect rect=CGRectMake(20, 0, 500, 30);
//    
//    [popuper presentViewController:popuper asPopoverRelativeToRect:rect ofView:self preferredEdge:NSRectEdgeMinY behavior:NSPopoverBehaviorTransient];
}

@end
