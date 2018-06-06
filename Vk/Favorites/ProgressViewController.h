//
//  ProgressViewController.h
//  MasterAPI
//
//  Created by sim on 06/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "VKCaptchaHandler.h"
@interface ProgressViewController : NSViewController{
    
    __weak IBOutlet NSTextField *proccessLabel;
    VKCaptchaHandler *captchaHandler;
     BOOL captchaOpened, stopped;
    NSString *url;
    int offset_counter;
}
@property NSInteger total;
@property NSInteger current;
@property NSMutableArray *items;
@property appInfo *app;

//extern unlikeBlock ulike(NSString *captcha_sid, NSString *captcha_img, NSInteger offset, unlikeBlock handler);
@end
