//
//  VKPrefsInfo.h
//  MasterAPI
//
//  Created by sim on 14.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "keyHandler.h"
@interface VKPrefsInfo : NSViewController{
    
    __weak IBOutlet NSTextField *appId;
    __weak IBOutlet NSTextField *appTitle;
    __weak IBOutlet NSTextField *appVersion;
    __weak IBOutlet NSTextField *appToken;
}
@property(nonatomic)keyHandler *VKInfoHandler;
@end
