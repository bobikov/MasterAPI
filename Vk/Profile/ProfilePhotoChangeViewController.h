//
//  ProfilePhotoChangeViewController.h
//  vkapp
//
//  Created by sim on 23.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "ViewControllerMenuItem.h"
@interface ProfilePhotoChangeViewController : NSViewController{
    NSString *serverUrl;
    NSString *filePath;
    __weak IBOutlet NSButton *removeOld;
    __weak IBOutlet NSImageView *currentPhoto;
    __weak IBOutlet NSTextField *intervalField;
    __weak IBOutlet NSButton *checkRepeat;
    __weak IBOutlet NSTextField *filePathLabel;
    __weak IBOutlet NSProgressIndicator *progressSpin;
    __weak IBOutlet NSProgressIndicator *progressUploadBar;
    NSString *server;
    NSString *hash;
    NSString *photo;
    NSString *baseURL;
    NSString *owner;
    __weak IBOutlet NSPopUpButton *userGroupsByAdminPopup;
    NSMutableArray *userGroupsByAdminData;
      ViewControllerMenuItem *viewControllerItem;
   
    __weak IBOutlet NSButton *uploadByURLCheck;
    __weak IBOutlet NSTextField *fieldWithURL;
}
@property(nonatomic)appInfo *app;
@property (nonatomic, strong)NSURLSession *backgroundSession;
typedef void(^OnComplete)(NSData *data);
-(void)getServerUrl:(NSString *)ownerId completion:(OnComplete)completion;

@end
