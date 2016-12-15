//
//  AddAudiosViewController.h
//  MasterAPI
//
//  Created by sim on 16.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "VKCaptchaHandler.h"
@interface AddAudiosViewController : NSViewController{
    
    __weak IBOutlet NSPopUpButton *userGroupsByAdmin;
    __weak IBOutlet NSProgressIndicator *progressBar;
    NSString *owner;
    NSMutableArray *userGroupsByAdminData;
    int offsetAddAudios;
    BOOL stopFlag;
    BOOL next;
}


@property(nonatomic,readwrite)NSMutableArray *receivedData;
@property(nonatomic,readwrite)appInfo *app;
@property(nonatomic, readwrite)VKCaptchaHandler *captchaHandle;
@end
