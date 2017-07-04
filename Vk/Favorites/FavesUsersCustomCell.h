//
//  FavesUsersCustomCell.h
//  vkapp
//
//  Created by sim on 24.08.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "KBButton.h"
@interface FavesUsersCustomCell : NSTableCellView
@property (weak) IBOutlet NSTextField *fullName;
@property (weak) IBOutlet NSImageView *online;
@property (weak) IBOutlet NSTextField *status;
@property (weak) IBOutlet NSTextField *country;
@property (weak) IBOutlet NSTextField *city;
//@property (weak) IBOutlet KBButton *profile;
@property (weak) IBOutlet NSButton *profile;
@property (weak) IBOutlet NSTextField *lastSeen;
@property (weak) IBOutlet NSTextField *bdate;
@property (weak) IBOutlet NSImageView *photo;
@property (weak) IBOutlet NSTextField *sex;
@property (weak) IBOutlet NSTextField *deactivatedStatus;
@property (weak) IBOutlet NSImageView *verified;
@property (weak) IBOutlet NSImageView *blacklisted;


@end
