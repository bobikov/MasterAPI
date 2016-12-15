//
//  followersCustomCell.h
//  MasterAPI
//
//  Created by sim on 09.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface followersCustomCell : NSTableCellView
@property (weak) IBOutlet NSTextField *url;
@property (weak) IBOutlet NSTextField *name;
@property (weak) IBOutlet NSImageView *avatar;

@end
