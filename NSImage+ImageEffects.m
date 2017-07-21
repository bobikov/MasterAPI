//
//  NSImage+ImageEffects.m
//  MasterAPI
//
//  Created by sim on 16/07/17.
//  Copyright © 2017 sim. All rights reserved.
//
#import <CoreImage/CoreImage.h>
#import "NSImage+ImageEffects.h"
#import <Vivid/YUCITriangularPixellate.h>
@implementation NSImage (ImageEffects)

- (NSImage*)blurImage:(NSURL*)imageURL :(nullable NSData*)data withBottomInset:(CGFloat)inset blurRadius:(CGFloat)radius{
    CIImage *ciImage;
    if(data == nil){
        ciImage = [CIImage imageWithContentsOfURL:imageURL];
    }
    else{
        ciImage = [CIImage imageWithData:data];
    }
    NSCIImageRep *rep = [NSCIImageRep imageRepWithCIImage:ciImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:ciImage forKey:kCIInputImageKey];
    [filter setValue:@(radius) forKey:kCIInputRadiusKey];
    CIImage *outputCIImage = filter.outputImage;
    CIContext *context = [CIContext contextWithOptions:nil];
    ciImage = [CIImage imageWithCGImage:[context createCGImage:outputCIImage fromRect:ciImage.extent]];
    rep = [NSCIImageRep imageRepWithCIImage:ciImage];
    NSImage *nsImage = [[NSImage alloc]initWithSize:rep.size];
    [nsImage addRepresentation:rep];
    return  nsImage;
}
-(CIImage*)imageSaturation:(NSURL*)imageURL data:(nullable  NSData*)imageData saturation:(NSNumber*)saturation brightness:(NSNumber*)brightness contrast:(NSNumber*)contrast inputEV:(NSNumber*)inputEV mono:(BOOL)mono sharpness:(nonnull NSNumber *)sharpness{
    __block NSCIImageRep *rep;
    __block CIImage *ciImage;
    __block CIFilter *filterSaturation;
    __block CIImage *outputCIImage;
    __block CIFilter *exposureFilter;
    __block CIFilter *monoFilter;
    __block CIFilter *sharpFilter;
    __block CIContext *context;
    __block NSImage *nsImage;
    if(imageData == nil){
        ciImage = [CIImage imageWithContentsOfURL:imageURL];
    }else{
        ciImage = [CIImage imageWithData:imageData];
    }
    filterSaturation = [CIFilter filterWithName:@"CIColorControls" withInputParameters:@{@"inputImage":ciImage,@"inputSaturation" :saturation,@"inputBrightness":brightness,@"inputContrast":contrast}];
    exposureFilter = [CIFilter filterWithName:@"CIExposureAdjust" withInputParameters:@{@"inputImage":filterSaturation.outputImage, @"inputEV":inputEV}];
    monoFilter = [CIFilter filterWithName:@"CIPhotoEffectMono" withInputParameters:@{@"inputImage":exposureFilter.outputImage}];
    sharpFilter = [CIFilter filterWithName:@"CISharpenLuminance" withInputParameters:@{@"inputImage":mono ? monoFilter.outputImage : exposureFilter.outputImage,@"inputSharpness":sharpness}];
    outputCIImage = sharpFilter.outputImage;
    context = [CIContext contextWithOptions:nil];
    ciImage = [CIImage imageWithCGImage:[context createCGImage:outputCIImage fromRect:ciImage.extent]];
    rep = [NSCIImageRep imageRepWithCIImage:ciImage];
    nsImage = [[NSImage alloc] initWithSize:rep.size];
    [nsImage addRepresentation:rep];
    return ciImage;
}
-(NSImage*)monochromeImage:(NSURL *)imageURL color:(CIColor *)color intensity:(NSNumber *)intensity{
    __block NSCIImageRep *rep;
    __block CIImage *ciImage;
    __block CIFilter *filter;
    __block CIImage *outputCIImage;
    __block CIContext *context;
    __block NSImage *nsImage;
    ciImage = [CIImage imageWithContentsOfURL:imageURL];
    filter = [CIFilter filterWithName:@"CIColorMonochrome" withInputParameters:@{@"inputImage":ciImage,@"inputColor":color, @"inputIntensity":intensity}];
    outputCIImage = filter.outputImage;
    context = [CIContext contextWithOptions:nil];
    ciImage = [CIImage imageWithCGImage:[context createCGImage:outputCIImage fromRect:ciImage.extent]];
    rep = [NSCIImageRep imageRepWithCIImage:ciImage];
    nsImage = [[NSImage alloc] initWithSize:rep.size];
    [nsImage addRepresentation:rep];
    return nsImage;
}
-(NSImage*)monoImage:(NSURL *)imageURL{
    NSCIImageRep *rep;
    CIImage *ciImage;
    CIFilter *filter;
    CIImage *outputCIImage;
    CIContext *context;
    NSImage *nsImage;
    
    ciImage = [CIImage imageWithContentsOfURL:imageURL];
    filter = [CIFilter filterWithName:@"CIPhotoEffectMono" withInputParameters:@{@"inputImage":ciImage}];
    outputCIImage = filter.outputImage;
    context = [CIContext contextWithOptions:nil];
    ciImage = [CIImage imageWithCGImage:[context createCGImage:outputCIImage fromRect:ciImage.extent]];
    rep = [NSCIImageRep imageRepWithCIImage:ciImage];
    nsImage = [[NSImage alloc] initWithSize:rep.size];
    [nsImage addRepresentation:rep];
    
    
    return nsImage;
}
-(NSImage*)imageWithTriangulars:(NSURL*)imageURL scale:(NSNumber*)scale center:(CIVector*)center vertexAngle:(NSNumber*)vertexAngle{
    NSCIImageRep *rep;
    CIImage *ciImage;
    YUCITriangularPixellate *filter;
    CIImage *outputCIImage;
    CIContext *context;
    NSImage *nsImage;
    
    ciImage = [CIImage imageWithContentsOfURL:imageURL];
    filter = [[YUCITriangularPixellate alloc]init];
    
    [filter setInputImage:ciImage];
    [filter setInputCenter:center];
    [filter setInputScale:scale];
    [filter setInputVertexAngle:vertexAngle];
    
    
    outputCIImage = filter.outputImage;
    context = [CIContext contextWithOptions:nil];
    ciImage = [CIImage imageWithCGImage:[context createCGImage:outputCIImage fromRect:ciImage.extent]];
    rep = [NSCIImageRep imageRepWithCIImage:ciImage];
    nsImage = [[NSImage alloc] initWithSize:rep.size];
    [nsImage addRepresentation:rep];
    return nsImage;
}
-(NSImage*)imageExposure:(NSData *)imageData inputEV:(NSNumber *)inputEV{
    NSCIImageRep *rep;
    CIImage *ciImage;
    CIFilter *filter;
    CIImage *outputCIImage;
    CIContext *context;
    NSImage *nsImage;
    
    ciImage = [CIImage imageWithData:imageData];
    filter = [CIFilter filterWithName:@"CIExposureAdjust" withInputParameters:@{@"inputImage":ciImage,@"inputEV":inputEV}];
    outputCIImage = filter.outputImage;
    context = [CIContext contextWithOptions:nil];
    ciImage = [CIImage imageWithCGImage:[context createCGImage:outputCIImage fromRect:ciImage.extent]];
    rep = [NSCIImageRep imageRepWithCIImage:ciImage];
    nsImage = [[NSImage alloc] initWithSize:rep.size];
    [nsImage addRepresentation:rep];
    return nsImage;
}
@end
