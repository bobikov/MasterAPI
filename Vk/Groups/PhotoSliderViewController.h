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
#import "SYFlatButton+ButtonsStyle.h"
#import "NIKFontAwesomeButton.h"
@interface PhotoSliderViewController : NSViewController{
    __weak IBOutlet NSImageView *photoView;
    __weak IBOutlet NSButton *prevPhoto;
    __weak IBOutlet NSButton *nextPhoto;
    NSInteger currentIndex;
   
    __weak IBOutlet NSProgressIndicator *progressSpin;
    NSTrackingArea *photoCaptionTrackingArea;
    NSTrackingArea *photoCaptionTrackingArea2;
//    __weak IBOutlet NSLayoutConstraint *photoViewWidthConstr;
//    __weak IBOutlet NSLayoutConstraint *photoViewHeightConst;
  
    __weak IBOutlet NIKFontAwesomeButton *userLikeBut;
    __weak IBOutlet SYFlatButton *likesCount;
    __weak IBOutlet NSButton *showCaptionBut;
    PhotoCaptionView *photoCaptionPopoverView;
    NSWindow *superWindow;
}
@property (weak) IBOutlet NSLayoutConstraint *photoViewWidthConstr;
@property (weak) IBOutlet NSLayoutConstraint *photoViewHeightConst;
@property(nonatomic)appInfo *app;
@property (nonatomic) NSMutableArray *data;
@end
