//
//  addDocsByOwnerController.h
//  MasterAPI
//
//  Created by sim on 17.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface addDocsByOwnerController : NSViewController{
    
    __weak IBOutlet NSPopUpButton *userGroupsByAdmin;
    __weak IBOutlet NSProgressIndicator *progressBar;
    NSMutableArray *userGroupsByAdminData;
    NSString *targetOwner;
}
@property(nonatomic, readwrite)NSMutableArray *receivedData;
@property(nonatomic)appInfo *app;
@end
