//
//  VKCaptchaHandler.h
//  MasterAPI
//
//  Created by sim on 16.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@interface VKCaptchaHandler : NSObject
@property(nonatomic, readwrite) NSImage *img;
@property(nonatomic, readwrite) NSString *code;
@property(nonatomic, readwrite) NSView *mainView;
@property(nonatomic, readwrite) NSImageView *image;
@property(nonatomic, readwrite) NSTextField *enterCode;
-(id)handleCaptcha:(id)img;
-(id)readCode;
@end
