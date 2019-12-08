//
//  DialogsListCustomCellView.m
//  vkapp
//
//  Created by sim on 26.04.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "DialogsListCustomCellView.h"
#import <PocketSVG/PocketSVG.h>
#import <BOString/BOString.h>
#import <NSColor+HexString.h>
@implementation DialogsListCustomCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
- (void)awakeFromNib{
    [self createTrackingArea];
//    self.wantsLayer=YES;
//    self.layer.masksToBounds=YES;
//    self.removeDialogButton.wantsLayer=YES;
//    self.removeDialogButton.layer.masksToBounds=YES;
//    self.removeDialogButton.layer.cornerRadius=7;
    //hide the button first
    [self.removeDialogButton setHidden:YES];

    
//    NSString *s = @"\U0000E681";
//    self.removeDialogButton.attributedTitle=[s bos_makeString:^(BOStringMaker *make) {
//        make.font([NSFont fontWithName:@"Pe-icon-7-stroke" size:16]);
//        make.foregroundColor([NSColor colorWithHexString:@"5179FF"]);
//        
//    }];
//    self.removeDialogButton.title = s;
}
- (void)createTrackingArea{
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
    
    NSPoint mouseLocation = [[self window] mouseLocationOutsideOfEventStream];
    mouseLocation = [self convertPoint: mouseLocation
                              fromView: nil];
   
//    if (NSPointInRect(mouseLocation, [self bounds]))
//    {
//        [self mouseEntered: nil];
//        
//    }
//    else
//    {
//        [self mouseExited: nil];
//    }
}
- (void)mouseEntered:(NSEvent *)theEvent{
    
//    self.removeDialogButton.title = [NSString stringWithFormat:@"Order %@", self.textField.stringValue];
    [self.removeDialogButton setHidden:NO];
//    [self.layer setBackgroundColor:[[NSColor grayColor]CGColor]];
//    NSLog(@"Entered '%@'", self.textField.stringValue);
}

- (void)mouseExited:(NSEvent *)theEvent{
    [self.removeDialogButton setHidden:YES];
//    [self.layer setBackgroundColor:[[NSColor whiteColor]CGColor]];
//    NSLog(@"Exited '%@'", self.textField.stringValue);
}

-(void)ShowUserInfo{
    NSLog(@"Show info");
}
-(void)OpenInBrowserUserPage{
    NSLog(@"Open in browser");
}
@end
