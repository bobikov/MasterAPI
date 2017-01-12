//
//  CustomVideoCollectionItem.h
//  vkapp
//
//  Created by sim on 26.05.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "appInfo.h"
#import "ShowNamesController.h"
@interface CustomVideoCollectionItem : NSCollectionViewItem{
    
    NSDictionary *selectedObject;
    NSString *albumToUploadTo;
    NSArray *filesForUpload;
    NSString *ownerId;
    NSMenu *theDropdownContextMenu;
}
@property (weak) IBOutlet NSButton *moveToAlbum;

@property (weak) IBOutlet NSImageView *albumCover;
@property (weak) IBOutlet NSTextField *textLabel;
@property(nonatomic)NSTrackingArea *trackingArea;
@property (weak) IBOutlet NSButton *removeItem;
@property (weak) IBOutlet NSTextField *countLabel;
@property (nonatomic)appInfo *app;
@property (weak) IBOutlet NSButton *attachAlbum;
@property (weak) IBOutlet NSButton *addURL;


@end
