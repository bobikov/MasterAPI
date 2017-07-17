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
-(NSImage*)imageSaturation:(NSURL*)imageURL saturation:(NSNumber*)saturation brightness:(NSNumber*)brightness contrast:(NSNumber*)contrast{
    __block NSCIImageRep *rep;
    __block CIImage *ciImage;
    __block CIFilter *filter;
    __block CIImage *outputCIImage;
    __block CIContext *context;
    __block NSImage *nsImage;
    ciImage = [CIImage imageWithContentsOfURL:imageURL];
    filter = [CIFilter filterWithName:@"CIColorControls" withInputParameters:@{@"inputImage":ciImage,@"inputSaturation" :saturation,@"inputBrightness":brightness,@"inputContrast":contrast}];
    outputCIImage = filter.outputImage;
    context = [CIContext contextWithOptions:nil];
    ciImage = [CIImage imageWithCGImage:[context createCGImage:outputCIImage fromRect:ciImage.extent]];
    rep = [NSCIImageRep imageRepWithCIImage:ciImage];
    nsImage = [[NSImage alloc] initWithSize:rep.size];
    [nsImage addRepresentation:rep];
    return nsImage;
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
@end
