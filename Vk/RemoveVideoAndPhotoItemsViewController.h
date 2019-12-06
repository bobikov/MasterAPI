//
//  RemoveVideoAndPhotoItemsViewController.h
//  MasterAPI
//
//  Created by sim on 12.01.17.
//  Copyright © 2017 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface RemoveVideoAndPhotoItemsViewController : NSViewController{
    
   
    __weak IBOutlet NSTextField *titleLabel;
    __weak IBOutlet NSProgressIndicator *progressBar;
    __weak IBOutlet NSTextField *progressLabel;
    NSInteger currentRemovedItem;
    appInfo *app;
}
@property(nonatomic)NSString *itemType;
@property(nonatomic)NSString *mediaType;
@property(nonatomic)NSArray *receivedData;
@end
