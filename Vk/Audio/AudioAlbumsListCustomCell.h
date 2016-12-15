//
//  AudioAlbumsListCustomCell.h
//  MasterAPI
//
//  Created by sim on 14.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AudioAlbumsListCustomCell : NSTableCellView
@property (weak) IBOutlet NSTextField *itemTitle;

@property (weak) IBOutlet NSButton *deleteItem;
@property (weak) IBOutlet NSButton *editItem;
@property (weak) IBOutlet NSTextField *time;
@property(nonatomic)NSTrackingArea *trackingArea;
@end
