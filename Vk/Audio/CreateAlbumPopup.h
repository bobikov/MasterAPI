//
//  CreateAlbumPopup.h
//  vkapp
//
//  Created by sim on 18.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface CreateAlbumPopup : NSViewController{
    
    __weak IBOutlet NSTextField *newAlbumName;
    __weak IBOutlet NSButton *createButton;
    __weak IBOutlet NSPopUpButton *userGroupsByAdmin;
    NSMutableArray *userGroupsByAdminData;
}
@property(nonatomic)appInfo *app;
@property(nonatomic,readwrite)NSString *ownerSelectedInAudioMainContainer;
@property (weak) IBOutlet NSButton *multiple;
@property(nonatomic,readwrite)NSString *owner;
@end
