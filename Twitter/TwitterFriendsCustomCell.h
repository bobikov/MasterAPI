//
//  TwitterFriendsCustomCell.h
//  MasterAPI
//
//  Created by sim on 11.09.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TwitterFriendsCustomCell : NSTableCellView
@property (weak) IBOutlet NSImageView *photo;
@property (weak) IBOutlet NSTextField *name;
@property (weak) IBOutlet NSTextField *location;

@property (weak) IBOutlet NSTextField *desc;
@property (weak) IBOutlet NSButton *follow;

@end
