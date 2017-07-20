//
//  NSImage+ImageEffects.h
//  MasterAPI
//
//  Created by sim on 16/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
CF_ASSUME_NONNULL_BEGIN
@interface NSImage (ImageEffects)
- (NSImage*)blurImage:(NSURL*)imageURL  :(nullable NSData*)data withBottomInset:(CGFloat)inset blurRadius:(CGFloat)radiusl;
-(NSImage*)imageSaturation:(NSURL*)imageURL data:(nullable NSData*)imageData saturation:(NSNumber*)saturation brightness:(NSNumber*)brightness contrast:(NSNumber*)contrast inputEV:(NSNumber*)inputEV mono:(BOOL)mono;
-(NSImage*)imageExposure:(NSData*)imageData  inputEV:(NSNumber*)inputEV;
-(NSImage*)monochromeImage:(NSURL*)imageURL color:(CIColor*)color intensity:(NSNumber*)intensity;
-(NSImage*)imageWithTriangulars:(NSURL*)imageURL scale:(NSNumber*)scale center:(CIVector*)center vertexAngle:(NSNumber*)vertexAngle;
-(NSImage *)monoImage:(NSURL*)imageURL;

CF_ASSUME_NONNULL_END
@end
