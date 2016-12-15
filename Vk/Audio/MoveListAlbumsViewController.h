//
//  MoveListAlbumsViewController.h
//  vkapp
//
//  Created by sim on 19.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
@interface MoveListAlbumsViewController : NSViewController{
    
    __weak IBOutlet NSTableView *albumsList;
    NSMutableArray *albumsListData;
}
@property(nonatomic)appInfo *app;
@property(nonatomic, readwrite) NSMutableArray *recivedAudioTracksData;
@property(nonatomic, readwrite) NSMutableArray *recivedAlbumsData;
@property(nonatomic,readwrite)NSString *owner;
@end
