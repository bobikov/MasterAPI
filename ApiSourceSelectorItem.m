//
//  ApiSourceSelectorItem.m
//  MasterAPI
//
//  Created by sim on 27.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import "ApiSourceSelectorItem.h"
#import "CustomView.h"
@interface ApiSourceSelectorItem ()

@end

@implementation ApiSourceSelectorItem

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self createTrackingArea];
}
- (void)createTrackingArea
{
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.view.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInActiveApp owner:self userInfo:nil];
  
    [self.view addTrackingArea:_trackingArea];
    
    NSPoint mouseLocation = [self.view.window mouseLocationOutsideOfEventStream];
    mouseLocation = [self.view convertPoint: mouseLocation
                                   fromView: nil];
    
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.alignment=NSTextAlignmentCenter;
    if(selected){
        NSLog(@"SSSSS");
        //        if(self.highlightState==0){
        //            self.view.layer.backgroundColor=[[NSColor whiteColor] CGColor];
        //        }
        //        else if(self.highlightState==1){
        //            self.view.layer.backgroundColor=[[NSColor blueColor] CGColor];
        
//        NSAttributedString *attrTitle = [[NSAttributedString alloc]initWithString:_sourceName.stringValue attributes:@{NSForegroundColorAttributeName:[NSColor whiteColor], NSParagraphStyleAttributeName:paragraphStyle}];
        
//        _sourceName.attributedStringValue=attrTitle;
//        self.view.layer.backgroundColor = [[NSColor blueColor]CGColor];
        CustomView *view = (CustomView*)self.view;
//        view.layer.backgroundColor=[[NSColor whiteColor] CGColor];
        [view setSelectedBackground];
        
        self.view.frame = NSMakeRect(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height+3);
       
        //            self.view.layer.backgroundColor=[[NSColor colorWithCalibratedRed:0.30 green:0.70 blue:0.90 alpha:0.8]CGColor];
        //            self.view.layer.borderColor=[[NSColor colorWithCalibratedRed:0.10 green:0.60 blue:0.90 alpha:1.0]CGColor];
        //            self.view.layer.borderWidth=2;
        //        }
        //        else if(self.highlightState==2){
        //            self.view.layer.backgroundColor=[[NSColor redColor] CGColor];
        //        }
    }
    else{
        self.view.frame = NSMakeRect(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height-3);
        NSAttributedString *attrTitle = [[NSAttributedString alloc]initWithString:_sourceName.stringValue attributes:@{NSForegroundColorAttributeName:[NSColor blackColor],NSParagraphStyleAttributeName:paragraphStyle}];
//        _sourceName.attributedStringValue=attrTitle;
//        self.view.layer.backgroundColor=[[NSColor windowBackgroundColor] CGColor];
         CustomView *view = (CustomView*)self.view;
//        view.layer.backgroundColor=[[NSColor windowFrameColor] CGColor];
        [view setUnselectedBackground];
        
//        self.view.layer.borderColor=[[NSColor clearColor]CGColor];
//        self.view.layer.borderWidth=0;
    }
}

@end
