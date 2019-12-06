//
//  EditVideoPhotoAlbumViewController.h
//  MasterAPI
//
//  Created by sim on 04.02.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface EditVideoPhotoAlbumViewController : NSViewController{
    
    __weak IBOutlet NSTextField *titleField;
    __weak IBOutlet NSTextField *descField;
    __weak IBOutlet NSButton *saveButton;
    appInfo *app;
}
@property(nonatomic)NSDictionary *receivedData;
@property(nonatomic)NSString *mediaType;
@end
