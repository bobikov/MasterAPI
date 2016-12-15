//
//  AudioAlbumRemoveViewController.h
//  vkapp
//
//  Created by sim on 19.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface AudioAlbumRemoveViewController : NSViewController{
    
    __weak IBOutlet NSProgressIndicator *progressSpin;
    __weak IBOutlet NSTableView *albumsList;
    
    __weak IBOutlet NSComboBox *ownerList;
    
    __weak IBOutlet NSComboBox *removeTrackInAlbum;
    __weak IBOutlet NSButton *removeButton;
    NSMutableArray *albumsListData;
}
@property (nonatomic) appInfo *app;

@end
