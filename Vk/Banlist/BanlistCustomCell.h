//
//  BanlistCustomCell.h
//  vkapp
//
//  Created by sim on 01.06.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BanlistCustomCell : NSTableCellView

@property (weak) IBOutlet NSTextField *userCountry;
@property (weak) IBOutlet NSTextField *fullName;
@property (weak) IBOutlet NSImageView *onlineStatus;
@property (weak) IBOutlet NSTextField *city;
@property (weak) IBOutlet NSTextField *lastSeen;
@property (weak) IBOutlet NSImageView *userPhoto;
@property (weak) IBOutlet NSTextField *bdate;
@property (weak) IBOutlet NSTextField *status;
@property (weak) IBOutlet NSTextField *deactivated;
@property (weak) IBOutlet NSTextField *sex;
@property (weak) IBOutlet NSImageView *blacklisted;

@end
