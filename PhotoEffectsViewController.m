//
//  PhotoEffectsViewController.m
//  MasterAPI
//
//  Created by sim on 17/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import "PhotoEffectsViewController.h"
#import "NSImage+ImageEffects.h"
#import "SYFlatButton+ButtonsStyle.h"
#import <Vivid/YUCIFilterConstructor.h>
#import <Vivid/YUCIRGBToneCurve.h>
#import "JPNG.h"
#import <Vivid/YUCICLAHE.h>
#import <Vivid/YUCITriangularPixellate.h>

@interface PhotoEffectsViewController ()

@end

@implementation PhotoEffectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    effectedImage = [[NSImage alloc]init];
    originalImage = [[NSImage alloc]initWithContentsOfURL:_originalImageURLs[0]];
    ciEffectedImage = [[CIImage alloc]init];
    controlsData = [NSMutableDictionary dictionaryWithDictionary:@{@"saturation":@1, @"brightness":@0, @"contrast":@1}];
     ;
    yuciiMageView.wantsLayer=YES;
    
    yuciiMageView.imageContentMode=YUCIImageViewContentModeDefault;
    yuciiMageView.renderer=YUCIImageRenderingSuggestedRenderer();
    
    self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
    SYFlatButton *flatBut = [[SYFlatButton alloc]init];
    [flatBut simpleWithBlackStorkes:(SYFlatButton*)acceptBut];
//    metalPreview = [[YUCIImageView alloc]initWithFrame:previewImage.frame];

  
//    [self.view addSubview:metalPreview];
    
     [self setImagePreview:originalImage];
    
}

- (void)viewDidAppear{
    self.view.window.titleVisibility=NSWindowTitleHidden;
    self.view.window.titlebarAppearsTransparent = YES;
    self.view.window.styleMask|=NSFullSizeContentViewWindowMask;
    self.view.window.movableByWindowBackground=NO;
    self.view.window.movable=YES;
    self.view.wantsLayer=YES;
    self.view.layer.masksToBounds=YES;
    self.view.layer.cornerRadius=3;
    self.view.layer.backgroundColor=[[NSColor whiteColor]CGColor];
    [self.view.window standardWindowButton:NSWindowMiniaturizeButton].hidden=YES;
    [self.view.window standardWindowButton:NSWindowZoomButton].hidden=YES;
    [self.view.window standardWindowButton:NSWindowCloseButton].hidden=NO;
}

- (void)setImagePreview:(NSImage*)image{
//    previewImage.image = image;

    yuciiMageView.image = [CIImage imageWithContentsOfURL:_originalImageURLs[0]];
    
    previewImage.hidden=YES;
}

- (IBAction)saturation:(id)sender {
//    NSLog(@"%f", saturationControl.doubleValue);
    [self updateWithEffects];
}

- (IBAction)brightness:(id)sender {
    [self updateWithEffects];
}

- (IBAction)contrast:(id)sender {
    [self updateWithEffects];
}
- (IBAction)sharpnessAdjust:(id)sender {
    [self updateWithEffects];
}

- (IBAction)imageWithTriangles:(id)sender {
//    if(makeTriangles.state){
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
//            effectedImage = [effectedImage imageWithTriangulars:_originalImageURLs[0] scale:@50 center:[CIVector vectorWithX:10 Y:10 Z:60] vertexAngle:@30];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                previewImage.image = effectedImage;
//            });
//        });
//    }else{
//        [self refresh];
//    }
    [self updateWithEffects];
}

- (IBAction)monoImage:(id)sender {
    [self updateWithEffects];
}

- (IBAction)blurImage:(id)sender {
//    if(makeBlur.state){
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
//            effectedImage = [effectedImage blurImage:_originalImageURLs[0] :nil withBottomInset:3 blurRadius:5];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                previewImage.image = effectedImage;
//            });
//        });
//    }else{
//        [self refresh];
//    }
    [self updateWithEffects];
}
- (IBAction)exposureAdjust:(id)sender {
    [self updateWithEffects];
}


- (IBAction)refreshToOriginal:(id)sender {
    [self refresh];
}
- (IBAction)claheImage:(id)sender {
    
    [self updateWithEffects];
}

- (void)refresh{
    previewImage.image = originalImage;
    saturationControl.doubleValue=[controlsData[@"saturation"] doubleValue];
    brightnessControl.doubleValue=[controlsData[@"brightness"]doubleValue];
    contrastControl.doubleValue=[controlsData[@"contrast"]doubleValue];
}

- (void)updateWithEffects{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
//        ciEffectedImage = [self imageSaturation:_originalImageURLs[0] data:nil saturation:[NSNumber numberWithDouble:saturationControl.doubleValue] brightness:[NSNumber numberWithDouble:brightnessControl.doubleValue] contrast:[NSNumber numberWithDouble:contrastControl.doubleValue ]inputEV:[NSNumber numberWithDouble:exposure.doubleValue] mono:checkMono.state sharpness:[NSNumber numberWithDouble:sharpnessControl.doubleValue]];
//         dispatch_async(dispatch_get_main_queue(), ^{
//             previewImage.image = effectedImage;
    
    yuciiMageView.image=[self imageSaturation:_originalImageURLs[0]  saturation:[NSNumber numberWithDouble:saturationControl.doubleValue] brightness:[NSNumber numberWithDouble:brightnessControl.doubleValue] contrast:[NSNumber numberWithDouble:contrastControl.doubleValue ]inputEV:[NSNumber numberWithDouble:exposure.doubleValue] mono:checkMono.state sharpness:[NSNumber numberWithDouble:sharpnessControl.doubleValue] toneCurve:makeToneCurve?@[[CIVector vectorWithX:0.2 Y:0.2],[CIVector vectorWithX:0.6 Y:0.6 ],[CIVector vectorWithX:1 Y:1.5]]:@[] clahe:makeClahe.state?@{@"clip":@5, @"tile":[CIVector vectorWithX:12 Y:12 Z:12]}:@{} triangles:@{@"scale":@50, @"center":[CIVector vectorWithX:10 Y:10 Z:60],@"vertex":@30} blur:makeBlur.state];
//         });
//    });
  
}

- (IBAction)acceptEffects:(id)sender {
    NSCIImageRep *rep2 = [NSCIImageRep imageRepWithCIImage:ciImageC];
    [rep2 setColorSpaceName:NSDeviceRGBColorSpace];
    NSDictionary* imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1] forKey:NSImageCompressionFactor];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]initWithCIImage:ciImageC];
//    [rep setColorSpaceName:NSDeviceRGBColorSpace];
//    [rep setBitsPerSample:8];
//    [rep setAlpha:NO];
//    [rep setOpaque:NO];
    _image = [[NSImage alloc]initWithSize:[rep2 size]];
    
    [_image addRepresentation:rep2];
    
//    imageData = [rep representationUsingType:NSJPEGFileType properties:imageProps];
    imageData =[_image TIFFRepresentation];
//    imageData = CGImageJPNGRepresentation([context createCGImage:ciEffectedImage fromRect:ciEffectedImage.extent], 1.0);
    
    if(_profilePhoto){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadProfilePhotoWithEffects" object:nil  userInfo:@{@"photo":[_image TIFFRepresentation]}];
        
    }
    else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UploadPhotoToAlbumWithEffects" object:nil  userInfo:@{@"photo":imageData}];
        
    }
    [self dismissController:self];
   
}
- (IBAction)toneCurveAdjust:(id)sender {
    [self updateWithEffects];
}


-(CIImage*)imageSaturation:(NSURL*)imageURL  saturation:(NSNumber*)saturation brightness:(NSNumber*)brightness contrast:(NSNumber*)contrast inputEV:(NSNumber*)inputEV mono:(BOOL)mono sharpness:(nonnull NSNumber *)sharpness toneCurve:(NSArray*)toneCurve clahe:(NSDictionary*)clahe triangles:(NSDictionary*)triangles blur:(BOOL)blur{
    
    CIImage *ciImage;
    CIFilter *filterSaturation;
    CIImage *outputCIImage;
    CIFilter *exposureFilter;
    CIFilter *monoFilter;
    CIFilter *sharpFilter;
    YUCIRGBToneCurve *toneCurveFilter;
    YUCICLAHE *claheFilter;
    YUCITriangularPixellate *trianglesFilter;
    CIFilter *blurFilter;
    
    trianglesFilter = [[YUCITriangularPixellate alloc]init];
    toneCurveFilter = [[YUCIRGBToneCurve alloc]init];
    claheFilter = [[YUCICLAHE alloc]init];
    
    
    ciImage = [CIImage imageWithContentsOfURL:_originalImageURLs[0]];
    
    
    filterSaturation = [CIFilter filterWithName:@"CIColorControls" withInputParameters:@{@"inputImage":ciImage,@"inputSaturation" :saturation,@"inputBrightness":brightness,@"inputContrast":contrast}];
    outputCIImage = filterSaturation.outputImage;
    
    exposureFilter = [CIFilter filterWithName:@"CIExposureAdjust" withInputParameters:@{@"inputImage":outputCIImage, @"inputEV":inputEV}];
    
    outputCIImage = exposureFilter.outputImage;
    monoFilter = [CIFilter filterWithName:@"CIPhotoEffectMono" withInputParameters:@{@"inputImage":outputCIImage}];
    outputCIImage = mono ? monoFilter.outputImage : outputCIImage;
    
    [toneCurveFilter setInputImage:outputCIImage];
    [toneCurveFilter setInputRGBCompositeControlPoints:toneCurve];
    outputCIImage = makeToneCurve.state ? toneCurveFilter.outputImage : outputCIImage;
    
    sharpFilter = [CIFilter filterWithName:@"CISharpenLuminance" withInputParameters:@{@"inputImage":outputCIImage, @"inputSharpness":sharpness}];
    outputCIImage = sharpFilter.outputImage;
    
    
    [claheFilter setInputImage:outputCIImage];
    [claheFilter setInputClipLimit:clahe[@"limit"]];
    [claheFilter setInputTileGridSize:clahe[@"tile"]];
    outputCIImage = makeClahe.state ? claheFilter.outputImage : outputCIImage;

    [trianglesFilter setInputImage:outputCIImage];
    [trianglesFilter setInputCenter:triangles[@"center"]];
    [trianglesFilter setInputScale:triangles[@"scale"]];
    [trianglesFilter setInputVertexAngle:triangles[@"vertex"]];
    outputCIImage = makeTriangles.state ? trianglesFilter.outputImage : outputCIImage;
    
    blurFilter = [CIFilter filterWithName:@"CIGaussianBlur" withInputParameters:@{@"inputImage":outputCIImage, @"inputRadius":@5}];
    outputCIImage = blur ? blurFilter.outputImage : outputCIImage;
                  
    context = [CIContext contextWithOptions:nil];
    ciEffectedImage = outputCIImage;
    ciImageC = [CIImage imageWithCGImage:[context createCGImage:outputCIImage fromRect:ciImage.extent format:kCIFormatARGB8 colorSpace:CGColorSpaceCreateWithName(kCGColorSpaceSRGB)]];
    
    return outputCIImage;
}

@end
