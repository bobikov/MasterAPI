//
//  PhotoSliderViewController.h
//  vkapp
//
//  Created by sim on 04.06.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "PhotoCaptionView.h"
@interface PhotoSliderViewController : NSViewController{
    
    
    __weak IBOutlet NSImageView *photoView;
    __weak IBOutlet NSButton *prevPhoto;
    __weak IBOutlet NSButton *nextPhoto;
    NSInteger currentIndex;
    NSMutableArray *data;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    NSTrackingArea *photoCaptionTrackingArea;
      NSTrackingArea *photoCaptionTrackingArea2;
//    __weak IBOutlet NSLayoutConstraint *photoViewWidthConstr;
//    __weak IBOutlet NSLayoutConstraint *photoViewHeightConst;
    __weak IBOutlet NSButton *showCaptionBut;
    PhotoCaptionView *photoCaptionPopoverView;
}
@property (weak) IBOutlet NSLayoutConstraint *photoViewWidthConstr;
@property (weak) IBOutlet NSLayoutConstraint *photoViewHeightConst;
@property(nonatomic)appInfo *app;
@end
