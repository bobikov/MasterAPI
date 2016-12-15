//
//  CreateNewAlbumController.h
//  vkapp
//
//  Created by sim on 03.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface CreateNewAlbumController : NSViewController{
    
    __weak IBOutlet NSTextField *newAlbumTitleField;
    __weak IBOutlet NSButton *radioFriends;
    __weak IBOutlet NSButton *radioAll;
    __weak IBOutlet NSButton *radioNobody;
    __weak IBOutlet NSBox *radioBox;
}
@property(nonatomic)appInfo *app;
@property(nonatomic) NSDictionary *receivedDataForNewAlbum;
@end
