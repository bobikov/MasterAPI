//
//  FollowsInstagramCell.h
//  MasterAPI
//
//  Created by sim on 04.12.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FollowsInstagramCell : NSTableCellView
@property (weak) IBOutlet NSImageView *profilePic;
@property (weak) IBOutlet NSTextField *fullName;
@property (weak) IBOutlet NSTextField *username;

@end
