//
//  OutRequestsCustomCell.h
//  vkapp
//
//  Created by sim on 29.07.16.
//  Copyright © 2016 sim. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OutRequestsCustomCell : NSTableCellView
@property (weak) IBOutlet NSImageView *photo;
@property (weak) IBOutlet NSTextField *status;
@property (weak) IBOutlet NSTextField *fullName;
@property (weak) IBOutlet NSTextField *city;
@property (weak) IBOutlet NSTextField *country;
@property (weak) IBOutlet NSTextField *lastSeen;
@property (weak) IBOutlet NSImageView *online;
@property (weak) IBOutlet NSButton *profile;
@property (weak) IBOutlet NSTextField *bdate;
@property (weak) IBOutlet NSTextField *sex;
@property (weak) IBOutlet NSImageView *verified;

@end
