//
//  PhotoEffectsViewController.h
//  MasterAPI
//
//  Created by sim on 17/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PhotoEffectsViewController : NSViewController{
    
    __weak IBOutlet NSSlider *saturationControl;
    __weak IBOutlet NSButton *acceptBut;
    __weak IBOutlet NSSlider *contrastControl;
    __weak IBOutlet NSSlider *brightnessControl;
    __weak IBOutlet NSButton *checkMono;
    __weak IBOutlet NSImageView *previewImage;
    __weak IBOutlet NSButton *makeTriangles;
    __weak IBOutlet NSButton *makeBlur;
    
    __weak IBOutlet NSSlider *exposure;
    NSImage *effectedImage;
    NSMutableDictionary *controlsData;
    NSImage *originalImage;
    NSWindow *mainWindow;
}
@property(nonatomic)NSArray* originalImageURLs;
@property(nonatomic)BOOL profilePhoto;
@end
