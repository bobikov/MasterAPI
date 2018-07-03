//
//  ProgressViewController.h
//  MasterAPI
//
//  Created by sim on 06/06/18.
//  Copyright © 2018 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"

@interface ProgressViewController : NSViewController{
    
    __weak IBOutlet NSTextField *proccessLabel;
    
     BOOL captchaOpened, stopped;
    NSString *url;
    NSInteger offset_counter;
    __weak IBOutlet NSTextField *titleLabel;
}
@property NSInteger total;
@property NSInteger current;
@property NSMutableArray *items;
@property appInfo *app;
@property NSString *photoId;
@property NSString *ownerId;
//extern unlikeBlock ulike(NSString *captcha_sid, NSString *captcha_img, NSInteger offset, unlikeBlock handler);
@property(nonatomic,readwrite) BOOL savePhotoToSaved;
@end
