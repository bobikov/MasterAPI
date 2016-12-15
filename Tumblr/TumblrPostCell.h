//
//  TumblrPostCell.h
//  MasterAPI
//
//  Created by sim on 18.10.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TumblrPostCell : NSTableCellView

@property (weak) IBOutlet NSButton *postPhoto;
@property (weak) IBOutlet NSTextField *caption;
@property(nonatomic)NSTrackingArea *trackingArea;
@end
