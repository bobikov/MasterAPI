//
//  NSImage+ImageEffects.h
//  MasterAPI
//
//  Created by sim on 16/07/17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
CF_ASSUME_NONNULL_BEGIN
@interface NSImage (ImageEffects){
    
}
- (NSImage*)blurImage:(NSURL*)imageURL :(nullable NSData*)data withBottomInset:(CGFloat)inset blurRadius:(CGFloat)radiusl;
CF_ASSUME_NONNULL_END
@end
