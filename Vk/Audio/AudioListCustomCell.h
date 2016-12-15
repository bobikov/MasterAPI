//
//  AudioListCustomCell.h
//  MasterAPI
//
//  Created by sim on 16.11.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AudioListCustomCell : NSTableCellView
@property (weak) IBOutlet NSButton *editItem;
@property (weak) IBOutlet NSButton *deleteItem;
@property (weak) IBOutlet NSButton *addItem;
@property (weak) IBOutlet NSTextField *itemTitle;
@property (weak) IBOutlet NSTextField *time;

@property (weak) IBOutlet NSButton *restore;

@property(nonatomic)NSTrackingArea *trackingArea;
@end
