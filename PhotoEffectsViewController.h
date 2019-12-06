//
//  PhotoEffectsViewController.h
//  MasterAPI
//
//  Created by sim on 17/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreImage/CoreImage.h>
#import <YUCIImageView/YUCIImageView.h>
#import <MetalPetal/MetalPetal.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@interface PhotoEffectsViewController : NSViewController  <MTKViewDelegate>   {
    
    __weak IBOutlet NSSlider *saturationControl;
    __weak IBOutlet NSButton *acceptBut;
    __weak IBOutlet NSSlider *contrastControl;
    __weak IBOutlet NSSlider *brightnessControl;
    __weak IBOutlet NSButton *checkMono;
    __weak IBOutlet NSImageView *previewImage;
    __weak IBOutlet NSButton *makeTriangles;
    __weak IBOutlet NSButton *makeBlur;
    __weak IBOutlet NSSlider *sharpnessControl;
    __weak IBOutlet YUCIImageView *yuciiMageView;
   
    __weak IBOutlet MTKView *renderView;
    

    
     MTIContext *rContext;
    __weak IBOutlet NSSlider *exposure;
    NSImage *effectedImage;
    CIImage *ciEffectedImage;
    NSMutableDictionary *controlsData;
    NSImage *originalImage;
    NSWindow *mainWindow;
    CIContext *context;
    NSImage *_image;
    __weak IBOutlet NSButton *makeToneCurve;
    NSData *imageData;
    CIImage *ciImageC;
    __weak IBOutlet NSButton *makePixelate;
    __weak IBOutlet NSButton *makeClahe;
    NSImageView *imageView;
    double pixelScale;
    
    __weak IBOutlet NSSlider *pixeleteScale;
}
@property(nonatomic)NSArray* originalImageURLs;
@property(nonatomic)BOOL profilePhoto;
@property(nonatomic)BOOL vkStory;
@end
