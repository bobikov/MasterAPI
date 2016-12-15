//
//  followingCustomCell.h
//  MasterAPI
//
//  Created by sim on 09.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface followingCustomCell : NSTableCellView
@property (weak) IBOutlet NSTextField *desc;
@property (weak) IBOutlet NSTextField *name;
@property (weak) IBOutlet NSTextField *ftitle;
@property (weak) IBOutlet NSImageView *avatar;
@property (weak) IBOutlet NSTextField *updated;


@end
